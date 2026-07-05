# Active-Directory-Security-Auditor

Script PowerShell automatisant l'audit de sécurité d'un domaine Active Directory.

## 📋 Fonctionnalités
- **Audit des comptes :** Détection automatique des comptes désactivés, inactifs (> 90j) ou avec l'option `PasswordNeverExpires` activée.
- **Gestion des privilèges :** Inventaire des membres du groupe "Domain Admins".
- **Détection d'intrusion :** Analyse des tentatives de connexion échouées (Event ID 4625) sur les dernières 24h.
- **Reporting :** Génération d'un rapport textuel propre et structuré.

## 🚀 Utilisation
1. Ouvrir PowerShell en tant qu'**Administrateur**.
2. S'assurer que le module `ActiveDirectory` est installé.
3. Lancer le script : `.\AuditAD.ps1`
4. Le rapport est généré dans `C:\Audit\`.

## 🛠 Prérequis
- Droits d'administration sur le domaine.
- Accès aux journaux d'événements (Security Logs).
