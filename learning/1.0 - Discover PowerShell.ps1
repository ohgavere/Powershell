# Nettoyer l'écran avant tout
cls

# Afficher la valeur de l'attribut [length] d'un objet
# (ici notre objet est la chaîne de caractère "toto"
# la longueur de cette chaîne est de 4 caractères.
### ==> Donc cette commande retourne la valeur [4]
"toto".length

# Voir les fonctions et attributs d'un objet
"toto" | Get-Member ;

# Get-help [nom de la commande]
# permet d'obtenir de l'aide pour une commande donnée
#Get-help Get-Member 

# rajouter le paramètre [-Online] ouvre 
# un navigateur qui affiche l'aide pour cette commande.
# Dans ce cas-ci, Get-Help Get-Member ne trouve pas les fichiers sur la machine
# Donc on rajoute -Online

#Get-help Get-Member -Online

# Commande qui affiche les les éléments enfants du dossier courants
# ==> Equivalent de la commande [DIR]
    ### MAIS ### c'est un ALIAS de la commande [GCI]
#Get-ChildItem

# Pour voir tous les alias qui existent : 
#Get-Alias

# La commande Child-Item peut être paramétrée 
# pour un dossie spécifique (par exemple)
#Get-ChildItem -Path C:\Windows

# Affiche toutes les commandes
#Get-Command

# Affiche toutes les commandes du type [alias]
#Get-Command -CommandType Alias

#Pour créer un alias d'une commande : 
# (ici on crée la commande [gci2] qui effectue la commande [gci]
# C'est donc un alias d'un alias d'une commande
New-Alias -Name gci2 gci

# On peut maintenant utiliser le nouvel alias :
#gci2

# Ensuite si on ne le veut plus, il faut le supprimer : 
Remove-Item alias:gci2

#--------------------------------------

# Créer une variable
$myVar = Get-ExecutionPolicy

# Imprimer du texte à l'écran avec 
# le contenu de la variable créée juste avant
ECHO "`n`n`rLa police d'exécution est : $myVar "

# Cette variable est un objet comme les autres, 
# on peut donc acceder a ses propriétés : 
$longueur = $myVar.length
ECHO "`n`n`tLa longueur de ma variable est : $longueur"


## Afficher les PROCESSUS en cours d'exécution sur la machine
#Get-Process | Format-Table
#Get-Process | Format-Wide
#Get-Process | Format-List


## Afficher TOUS les SERVICES sur la machine
# Get-Service

## Afficher les SERVICES en cours d'exécution sur la machine
Get-Service | where {$_.Status -eq "running"} | Format-Table 

## RECUPERER les SERVICES en cours d'exécution sur la machine
### ET ==> on exporte le résultat dans un fichier
Get-Service | where {$_.Status -eq "running"} | Format-Table >> C:\Users\Administrator\Desktop\essai.txt


#--------------------------------------


# La police d'exécution bloque par défaut l'exécution de script
# Cela permet de "garantir" une dcertaine sécurité d'exécution
# On peut voir et modifier la police d'exécution actuelle avec : 
#Get-ExecutionPolicy
#Set-ExecutionPolicy






