#  Notes pour les fonctions
On part du principe que les symboles dev et var temporraires sont toutes stockées en bas.

Table des symboles = reflète la mémoire (et son espace mémoire (possède le nom `a`), ressemble à la pile de l'exécution (contient la valeur de `a`) 
/= la mémoire du code de la fonction
-> Table des fonctions contient les addresses du code associées aux noms des fonctions.

int/void ? j'ai pas écouté

```c
int f1(int a, zint b) {
  int c;
  return 8;
}
```
TS (va contenir) : 

val ret, a, b, @ret, c, var_temp
| @ | content |
| - | ------- |
| 5 | vt |
| 4 | c |
| 3 | @ret |
| 2 | b |
| 1 | a |
| 0 | #val ret |

```asm
AFC 5 8
COP 0 5
RET 3 --- instruction à inventer 
```

```yacc
F: tINT tID
  {ts_add("#val_ret"); fs_add($2);}
  (Arg)
  {ts_add("@ret"}
  Body
  {ts_flush}

Call: tID ( {ts_add_tmp ; $2 = |ts|; inc_depth} Params) {//variable temporaire pour la valeur de retour de la fonction et chacun des paramètres crée une variable temporaire}
      {ts_add_tmp; AFC ...; INC $2; JMP f1; DEC $2;ts_depiler_tout_sauf_; dec_depth_vtn_ret}
```
```asm
  INC 6
28:
  AFC 9
  INC 6
  JMP F1
31:
  DEC 6
```

```c
void f2 (int d) {
  int e;
  int f;
  int g;
  g = f1(e,f);
}
```

| @ | content |
| - | ------- |
| 9 | vt/@ret |
| 8 | vt/f |
| 7 | vt/e |
| 6 | vt/#val_ret = 0 du tableau précédent |
| 5 | g |
| 4 | f |
| 3 | e |
| 2 | @ret |
| 1 | d |
| 0 | #val ret |

offset global : base pointer (pointe toujours sur la première case)
instructions INC/DEC
