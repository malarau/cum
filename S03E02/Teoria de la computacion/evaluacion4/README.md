## Implementación de un Intérprete de una Máquina de Turing en Python

### Caso:

$` L = { a^nb^n | n ∈ N } `$

### Input: data.txt

```
4 3
- a b
0 a - d 1
0 b - q -1
2 a - q -1
2 b - i 3
0 - a q -1
1 a a d 1
1 b b d 1
2 - a q -1
1 - - i 2
3 a a i 3
3 b b i 3
3 - - d 0
2
abaaabb
aaabbb
```

### Output:

```
Estados: 4
Símbolos (3): -  a  b
           -            a            b      
--- + --------------------------------------
 0  |  a   q  -1  | -   d   1  | -   q  -1  
 1  |  -   i   2  | a   d   1  | b   d   1  
 2  |  a   q  -1  | -   q  -1  | -   i   3  
 3  |  -   d   0  | a   i   3  | b   i   3  
Casos disponibles: 2

Cinta de entrada para el caso 1:
        | a | b | a | a | a | b | b |
          ^
        La cinta queda:
        | - | - | a | a | a | b | - | - |
              ^
        Posición del cabezal: 1
        [La cadena no es aceptada]

Cinta de entrada para el caso 2:
        | a | a | a | b | b | b |
          ^
        La cinta queda:
        | - | - | - | a | - | - | - |
                      ^
        Posición del cabezal: 3
        [La cadena es aceptada]
```
