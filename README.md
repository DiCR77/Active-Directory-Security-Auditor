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
- 
## 📊 Aperçu du rapport
Voici un exemple de ce que génère le script :

## 📊 Aperçu du rapport
Voici un exemple de ce que génère le script :

```text
--- CONTEXTE DE L'AUDIT ---
Date : 07/05/2026 09:00:00
Domaine : lab.local
Nombre total d'utilisateurs : 12
--------------------------

Résumé : 6 comptes présentent une anomalie.
--- DÉTAILS DES COMPTES À RISQUE ---
==========================================================================
Nom d'utilisateur         | Motifs de l'alerte
--------------------------------------------------------------------------
Administrator             | PasswordNeverExpires
Jean Dupont               | PasswordNeverExpires, Inactif
Marie Curie               | Désactivé
Compte Test               | Désactivé, Inactif, PasswordNeverExpires
Service_Print             | Inactif
Guest_Local               | Désactivé, Inactif
==========================================================================

--- ADMINISTRATEURS ---
==========================================================================
Nom d'utilisateur
--------------------------------------------------------------------------
Administrator
Jean Dupont
==========================================================================

--- ALERTE : ADMINISTRATEURS INACTIFS ( > 90j ) ---
ATTENTION : L'admin Jean Dupont est inactif depuis le 01/01/2026

--- ALERTE : TENTATIVES DE CONNEXION ÉCHOUÉES (24h) ---
Tentative échouée pour : Administrator
Tentative échouée pour : root_hacker

--- RECOMMANDATIONS DE SÉCURITÉ ---
1. Comptes inactifs : Désactiver ou supprimer les comptes n'ayant pas été utilisés depuis plus de 90 jours.
2. PasswordNeverExpires : Désactiver cette option sur les comptes utilisateurs.
3. Tentatives échouées : Identifier l'adresse IP source et configurer une stratégie de blocage (GPO/IP).
==========================================================================
