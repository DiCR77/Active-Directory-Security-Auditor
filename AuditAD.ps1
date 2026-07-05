# 1. DÉFINITION DES VARIABLES
$RapportPath = "C:\Audit\Rapport_Audit_$(Get-Date -Format 'yyyyMMdd').txt"
$DateLimite = (Get-Date).AddDays(-90)
$Yesterday = (Get-Date).AddDays(-1)

# 2. CONTEXTE DE L'AUDIT
"--- CONTEXTE DE L'AUDIT ---" | Out-File $RapportPath -Encoding UTF8
"Date : $(Get-Date)" | Out-File $RapportPath -Append -Encoding UTF8
"Domaine : $(Get-ADDomain | Select-Object -ExpandProperty DNSRoot)" | Out-File $RapportPath -Append -Encoding UTF8
"Nombre total d'utilisateurs : $(@(Get-ADUser -Filter *).Count)" | Out-File $RapportPath -Append -Encoding UTF8
"--------------------------`n" | Out-File $RapportPath -Append -Encoding UTF8

# 3. ANALYSE DES COMPTES À RISQUE
$ComptesRisque = Get-ADUser -Filter * -Properties Enabled, PasswordNeverExpires, LastLogonDate | 
    Where-Object { 
        $_.Enabled -eq $false -or 
        $_.PasswordNeverExpires -eq $true -or 
        ($_.LastLogonDate -lt $DateLimite) -or 
        ($_.LastLogonDate -eq $null) 
    } | Where-Object { $_.SamAccountName -ne "Guest" -and $_.SamAccountName -ne "krbtgt" }

"Résumé : $($ComptesRisque.Count) comptes présentent une anomalie." | Out-File $RapportPath -Append -Encoding UTF8
"--- DÉTAILS DES COMPTES À RISQUE ---"

$Resultats = foreach ($User in $ComptesRisque) {
    $Motif = @()
    if ($User.Enabled -eq $false) { $Motif += "Désactivé" }
    if ($User.PasswordNeverExpires -eq $true) { $Motif += "PasswordNeverExpires" }
    if ($null -eq $User.LastLogonDate -or $User.LastLogonDate -lt $DateLimite) { $Motif += "Inactif" }
    [PSCustomObject]@{ Name = $User.Name; Motifs = $Motif -join ", " }
}
# Affichage propre et aligné
"--- DÉTAILS DES COMPTES À RISQUE ---" | Out-File $RapportPath -Append -Encoding UTF8
"==========================================================================" | Out-File $RapportPath -Append -Encoding UTF8
"{0,-25} | {1,-40}" -f "Nom d'utilisateur", "Motifs de l'alerte" | Out-File $RapportPath -Append -Encoding UTF8
"--------------------------------------------------------------------------" | Out-File $RapportPath -Append -Encoding UTF8

foreach ($User in $Resultats) {
    "{0,-25} | {1,-40}" -f $User.Name, $User.Motifs | Out-File $RapportPath -Append -Encoding UTF8
}
"==========================================================================" | Out-File $RapportPath -Append -Encoding UTF8

# 4. ANALYSE DES ADMINS
"`n--- ADMINISTRATEURS ---" | Out-File $RapportPath -Append -Encoding UTF8
"==========================================================================" | Out-File $RapportPath -Append -Encoding UTF8
"{0,-25}" -f "Nom d'utilisateur" | Out-File $RapportPath -Append -Encoding UTF8
"--------------------------------------------------------------------------" | Out-File $RapportPath -Append -Encoding UTF8
Get-ADGroupMember -Identity "Domain Admins" | ForEach-Object {
    "{0,-25}" -f $_.Name | Out-File $RapportPath -Append -Encoding UTF8
}
"==========================================================================" | Out-File $RapportPath -Append -Encoding UTF8

# 5. ALERTE ADMINS INACTIFS
"`n--- ALERTE : ADMINISTRATEURS INACTIFS ( > 90j ) ---" | Out-File $RapportPath -Append -Encoding UTF8
$Admins = Get-ADGroupMember -Identity "Domain Admins" | Get-ADUser -Properties LastLogonDate
foreach ($Admin in $Admins) {
    if ($null -eq $Admin.LastLogonDate -or $Admin.LastLogonDate -lt $DateLimite) {
        "ATTENTION : L'admin $($Admin.Name) est inactif depuis le $($Admin.LastLogonDate)" | Out-File $RapportPath -Append -Encoding UTF8
    }
}

# 6. ALERTE BRUTE FORCE (24H)
"`n--- ALERTE : TENTATIVES DE CONNEXION ÉCHOUÉES (24h) ---" | Out-File $RapportPath -Append -Encoding UTF8
$Echecs = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$Yesterday} -ErrorAction SilentlyContinue
if ($Echecs) {
    foreach ($e in $Echecs) {
        $xml = [xml]$e.ToXml()
        $User = $xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }
        "Tentative échouée pour : $($User.'#text')" | Out-File $RapportPath -Append -Encoding UTF8
    }
} else {
    "Aucune tentative d'intrusion détectée." | Out-File $RapportPath -Append -Encoding UTF8
}

Write-Host "Audit terminé avec succès dans $RapportPath" -ForegroundColor Green
"`n--- RECOMMANDATIONS DE SÉCURITÉ (EXEMPLES D'ACTIONS) ---" | Out-File $RapportPath -Append -Encoding UTF8
"1. Comptes inactifs : Désactiver ou supprimer les comptes n'ayant pas été utilisés depuis plus de 90 jours." | Out-File $RapportPath -Append -Encoding UTF8
"2. PasswordNeverExpires : Désactiver cette option sur les comptes utilisateurs pour renforcer la politique de mot de passe." | Out-File $RapportPath -Append -Encoding UTF8
"3. Tentatives échouées : Si le nombre d'échecs augmente, identifier l'adresse IP source et configurer une stratégie de blocage (GPO/IP)." | Out-File $RapportPath -Append -Encoding UTF8
"==========================================================================" | Out-File $RapportPath -Append -Encoding UTF8
