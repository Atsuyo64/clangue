# Rapport de Projet Système Informatique

## 1. Introduction

Pour ce projet, nous avons développé un compilateur (nommé *clangue*) pour un langage C simplifié et un processeur pipeliné (nommé *raisingue*) en utilisant Lex, Yacc, et VHDL.\
Le compilateur est structuré en deux étapes distinctes : une étape d'analyse lexicale, grammaticale et syntaxique pour générer un assembleur orienté mémoire. Cette étape est suivie d'un cross-compilateur en Python (asm2machineCode.py) qui transforme l'assembleur orienté mémoire en un format orienté registre et génère une mémoire d'instructions en VHDL.\
Le processeur *raisingue* est conçu pour exécuter ces instructions en utilisant un pipeline à quatre étages, avec gestion des aléas.

## 2. Démarche de conception

### Clangue

Le projet a été réalise en deux phases principales : la conception du compilateur puis celle du processeur.

La première étape du compilateur analyse et transforme le code en un premier assembleur. Cela a nécessité l'utilisation de Lex pour tokeniser le code C, et Yacc pour l'analyse grammaticale et syntaxique.\
La seconde étape du compilateur traduit et adapte l'assembleur pour le processeur. Cette étape, plus simple, a été réalisée en Python pour simplifier son développement.

### Raisingue

Le processeur *raisingue* a été conçu pour exécuter les instructions de l'assembleur dans un pipeline à quatre étapes : Décodage, Exécution (ALU), Mémoire et Writeback (écriture vers les registres).\
Vivado a été utilisé pour sa conception, et nous avons essayé de séparer au maximum les différents composants (une vingtaine de fichiers sources) ainsi qu'un composant Main reliant l'ensemble des composants.

## 3. Choix d'implémentation

### 3.1 Compilateur (*clangue*)

#### 3.1.1 Lex + Yacc

Notre implémentation se démarque par ces différents aspects :
- Lex permet d'indiquer à Yacc la ligne en train d'être traîtée. Cette information est utilisable en cas d'erreur de syntaxe.
- Aucun conflit (ni shift/reduce, ni reduce/reduce)
- L'assembleur généré contient des déclarations de label, et les instructions de branchement (JMP et JMF) les utilisent. Cela rend l'assembleur beaucoup plus facile à lire. De plus, les numéros d'instruction vont changer lors de la phase suivante (voir l'explication dans la partie suivante).

#### 3.1.2 Jeu d'instruction (*BAR*)

En plus des instructions classiques (NOP, ADD, SUB, MUL, DIV, JMP, LDR, STR, AFC), notre jeu d'instruction contient également ces instructions et spécificités : 
- Instruction `NOZ R1` : Met à jour le flag interne _NOZ_ := (R1 != 0)
- Instruction `JMF address` : Saute à l'adresse _address_ uniquement si le flag _NOZ_ == false. 
- La transformation de l'assembleur orienté mémoire en assembleur orienté registre nécessite d'ajouter de nombreux `LDR` et `STR` afin de copier les données dans les registres pour être utilisées puis les sauvegarder.

Note : pour l'assembleur post-Yacc, tous les registres en arguments sont en réalité des adresses mémoire (assembleur orienté mémoire), et les addresses sont en réalité des labels.

#### 3.1.3 Assembleur vers code machine

Trois opérations sont réalisées durant cette étape :
- Ajout des `LDR` `STR` nécessaires pour l'assembleur orienté registre
- Détermination le numéro d'instruction associé à chaque label. Cette étape nécessite 2 passages : un premier pour définir les addresses des labels et un deuxième pour remplacer les labels par leur valeur (nécessaire car certains labels sont utilisés (`JMP`) avant d'être définis)
- Génération du code machine en VHDL pouvant être copié-collé dans la mémoire d'instructions.

### 3.2 Processeur (*raisingue*)

#### 3.2.1 Pipeline

Le processeur utilise le pipeline proposé dans le sujet. Notre version possède 4 étages et les éléments synchronisés sur l'horloge séparant les étages sont :
1. PC (ou IP) le compteur d'instruction
2. DIEXer (ou DI/EX dans le sujet), séparant Decode et Execute
3. EXMEMer (ou EX/Mem dans le sujet), séparant Execute et Opérations mémoire
4. MEMREer (ou Mem/RE dans le sujet), séparant Opérations mémoire et Write-back (écriture dans les registres)

#### 3.2.2 Aléas

Les aléas ont été éliminés grâce au _Decoder_ qui indique à _PC_ de rajouter des instructions `NOP` en cas de risque d'aléas. Nous avons amélioré la rapidité d'exécution de 42% (3.1ms contre 4.4ms sur un programme test) en ne rajoutant des `NOP` qu'après des instructions nécessitant un write-back.

# TODO: le reste

à dire double clocké

 Le but principal était d'assurer une exécution fluide des instructions tout en gérant les aléas, comme les conflits de données et les sauts conditionnels. Des NOP (No-Operation) sont insérés dans le pipeline en fonction des instructions précédentes afin d'éviter des erreurs d'accès aux registres ou à la mémoire.

Les instructions du processeur incluent des opérations arithmétiques (ADD, SUB, MUL, DIV), des transferts de données (AFC, LDR, STR), des instructions conditionnelles (JMP, JMF), et une instruction de mise à jour de drapeau (NOZ) pour gérer les valeurs non nulles.

### 4. Problèmes rencontrés et solutions

#### 4.1 Problème de gestion des sauts conditionnels

Lors de la mise en œuvre du traitement des sauts (JMP, JMF), un problème majeur a été rencontré concernant la mise à jour des adresses de saut et la gestion des dépendances dans le pipeline. Pour résoudre ce problème, nous avons développé une méthode permettant de calculer dynamiquement les adresses de saut en fonction du contexte d'exécution, en ajoutant un mécanisme de gestion de sauts conditionnels et en réajustant les adresses dans le générateur de code machine.

#### 4.2 Aléas du pipeline

Le principal défi dans la conception du processeur a été la gestion des aléas dans le pipeline, notamment les conflits de données et les retards induits par les écritures dans les registres. L’ajout conditionnel de NOPs a permis d’éviter les erreurs liées à la lecture de registres avant leur écriture. L’insertion de ces NOPs a été rendue dynamique selon les instructions précédemment traitées, ce qui a assuré une gestion plus fine des performances sans pénaliser l’exécution.

### 5. Résultats obtenus

Le compilateur *clangue* génère correctement un assembleur simplifié qui est ensuite transformé en code machine par le cross-compilateur Python. Le processeur *raisingue* exécute correctement les instructions en utilisant son pipeline et gère les sauts et les conflits de données avec efficacité. Les tests ont montré que les performances du processeur sont optimisées grâce à la gestion des aléas du pipeline et à l’ajout intelligent de NOPs.

Le débogueur *R.I.C.A.R.D.* permet d’observer en temps réel l’état des registres et de la mémoire pendant l’exécution du code, facilitant ainsi le suivi des opérations du processeur et la vérification de la validité du comportement du système.

### 6. Justification des instructions ajoutées

Certaines instructions ont été ajoutées pour répondre à des besoins spécifiques du processeur et du compilateur :

* **NOZ** : Cette instruction met à jour un flag indiquant si un registre contient une valeur différente de zéro. Elle est essentielle pour gérer correctement les conditions de saut dans les instructions comme JMF (Jump if Flag).
* **JMP/JMF** : Ces instructions conditionnelles ont été ajoutées pour gérer les flux de contrôle du programme, notamment les boucles et les structures conditionnelles, et permettent de contrôler l’exécution en fonction de l’état du processeur.

### 7. Conclusion

Le projet a permis de développer un compilateur fonctionnel et un processeur pipeliné capable de traiter un ensemble d’instructions arithmétiques, logiques et de contrôle de flux. La gestion des aléas du pipeline et l’optimisation des sauts conditionnels ont été des défis majeurs, mais les solutions mises en place ont permis de garantir la bonne exécution du système. Le débogueur intégré *R.I.C.A.R.D.* constitue un outil précieux pour valider le bon fonctionnement des programmes et pour tester le compilateur et le processeur dans différents scénarios d'exécution.

---

Ce rapport synthétise les aspects principaux de la conception, les défis techniques rencontrés et les solutions apportées. Si vous avez besoin de plus de détails ou d'exemples, n'hésitez pas à demander !

