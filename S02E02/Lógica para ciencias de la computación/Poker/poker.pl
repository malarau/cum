/*
5.Genere una base de conocimiento, tal que almacene un mazo de cartas de poker en orden, un predicado que permita barajar el mazo y otro que informe al usuario la información sobre su mano. Las opciones de juego son: Escalera real, Escalera de color, Poker, Full house, Color, Escalera, Tercia, Doble par, Par y Carta más alta.
*/

% Idea original de sistema de cartas y sistema de valores:
% https://github.com/MyMEng/BlackJack
suits(♦).
suits(♥).
suits(♠).
suits(♣).
% Idea de MyMEng
ranks(  ace).
ranks(    2).
ranks(    3).
ranks(    4).
ranks(    5).
ranks(    6).
ranks(    7).
ranks(    8).
ranks(    9).
ranks(   10).
ranks( jack).
ranks(queen).
ranks( king).

card(R,S):- ranks(R), suits(S).

mazo(X):- findall(card(R,S), card(R, S), X).

jugar:-
    mazo(Mazo),
    menu(Mazo).

%valor(Valor, card(jack,♥)).
valor(Value, card( R, S )) :-
	( S = ♣; S = ♦; S = ♥; S = ♠ ), !,
	( R = ace   -> ( Value is 14 ; Value is 1 )
	; R = jack  -> Value is 11
	; R = queen -> Value is 12
	; R = king  -> Value is 13
	; otherwise -> Value is R
	).

%color(Color, card(jack,♥)).
color(Color, card(R,S)):-
	card(R,S) = card(R, Color).

% Simplemente remueve una por una y genera una mano.
mano(Mazo, Mano, NuevoMazo):-
    remover(Flop1, Mazo      , NuevoMazo1),
    remover(Flop2, NuevoMazo1, NuevoMazo2),
    remover(Flop3, NuevoMazo2, NuevoMazo3),
    remover(Turn , NuevoMazo3, NuevoMazo4),
    remover(River, NuevoMazo4, NuevoMazo),
    append([Flop1, Flop2, Flop3], [Turn, River], Mano).

remover(X, [X|Cola], Cola).

menu(Mazo):-
    nl, nl,
    write('> Menú principal '), nl,
    write('1.- Barajar, robar cartas y probar suerte.'), nl,
    write('0.- Salir.'), nl,
    write('Selecciona una opción: '), read(Opcion),
    accion(Opcion, Mazo).

accion(Opcion, Mazo):-
    (
        Opcion == 1,
        barajar(Mazo, MazoMezcladoUnaVez),
        barajar(MazoMezcladoUnaVez, MazoMezcladoDosVeces),
        mano(MazoMezcladoDosVeces, Mano, NuevoMazo),
        jugarMano(Mano),
        append(NuevoMazo, Mano ,MazoCompleto),
        menu(MazoCompleto)
    );
    Opcion == 0, true.

jugarMano(Mano):- nl,
    ordenAsc(Mano, ManoOrdenada),
    revisarSiApuestoTodo(ManoOrdenada, Resultado), nl,
    % Traducir a texto de vuelta!
    write('Mano ordenada: '), nl,
    traducirATexto(ManoOrdenada, ManoOrdenadaEnTexto),
    write(ManoOrdenadaEnTexto), nl,
    write('Y el resultado es... '), write(Resultado), nl.

% https://www.swi-prolog.org/pldoc/man?predicate=sort/4
ordenAsc(Lista, ListaOrdenada):-
    traducirANumeros(Lista, NuevaListaConNumeros),
    sort(0, @=<, NuevaListaConNumeros, ListaOrdenada).

% traducirANumeros([card(5,♥),card(10,♦),card(jack,♥),card(king,♥),card(queen,♥)],NuevaLista).
traducirANumeros([C1,C2,C3,C4,C5], NuevaLista):-
    mapANumeros(T1,C1),
    mapANumeros(T2,C2),
    mapANumeros(T3,C3),
    mapANumeros(T4,C4),
    mapANumeros(T5, C5), % Valores de letras a numeros!
    NuevaLista = [T1,T2,T3,T4,T5].

%mapANumeros(Valor, card(jack,♥)).
mapANumeros(card(Value,S), card(R,S)) :-
	( S = ♣; S = ♦; S = ♥; S = ♠ ), !,
	( R = ace   -> ( Value is 14 ; Value is 1 )
	; R = jack  -> Value is 11
	; R = queen -> Value is 12
	; R = king  -> Value is 13
	; otherwise -> Value is R
	).

%traducirATexto([card(7,♥),card(ace,♦),card(ace,♥),card(8,♦),card(2,♦)],NuevaLista).
traducirATexto([C1,C2,C3,C4,C5], NuevaLista):-
    mapATexto(T1,C1),
    mapATexto(T2,C2),
    mapATexto(T3,C3),
    mapATexto(T4,C4),
    mapATexto(T5, C5), % Valores de letras a numeros!
    NuevaLista = [T1,T2,T3,T4,T5].

%mapATexto(Valor, card(11,♥)).
mapATexto(card(Value,S), card(R,S)) :-
	( S = ♣; S = ♦; S = ♥; S = ♠ ), !,
	( (R is 1; R = 14)   -> ( Value = "ace" )
	; R is 11  -> Value = "jack"
	; R is 12 -> Value = "queen"
	; R is 13  -> Value = "king"
	; otherwise -> Value is R
	).

barajar(Mazo, MazoMezclado):-
    dividir(Pila1, Pila2, Mazo), % Realiza una mezcla.
    mezclar(Pila1, Pila2, MazoMezclado).

contarCartas([], 0).

contarCartas([_|C], N):- contarCartas(C, M), N is M+1.

dividir(Pila1, Pila2, Mazo):-
    contarCartas(Mazo, TotalCartas),
    Mitad is TotalCartas/2,
    dividir_(Pila1, Pila2, Mazo, Mitad).

dividir_(Pila1, Pila2, Mazo, Mitad) :-
   length(Pila1,Mitad),      % Me dice el largo de Pila1 en Mitad... O lo que busco, establecer el largo de Pila1, diciendo su tamaño jeje.
   append(Pila1,Pila2,Mazo).  % Ya sé el tamaño de Pila1 y Mazo está completo. Para que sea verdadero, pone [Mitad] elementos en Pila1 y el resto (que sería la otra mitad) en Pila2. Trucazo.

% Tomo cada pila y la barajo normalmente
% O sea, hago ese juego de manos, donde van entrando intercaladas.
mezclar(Pila1, Pila2, Mazo):-
    random(0, 2, PilaEscogida),
    mezclar(Mazo, [], Pila1, Pila2, PilaEscogida).

% Primero la primera carta del montón P1
mezclar(Mazo, MazoMezclado, [P1_Cabeza|P1_Cola], [P2_Cabeza|P2_Cola], 0):-
    append(MazoMezclado, [P1_Cabeza], Mezcla1), % Primero la primera carta del montón P1
    append(Mezcla1, [P2_Cabeza], Mezcla2), % Luego la primera carta del montón P2
    random(0, 2, PilaEscogida),
    mezclar(Mazo, Mezcla2, P1_Cola, P2_Cola, PilaEscogida).

% Primero la primera carta del montón P2
mezclar(Mazo, MazoMezclado, [P1_Cabeza|P1_Cola], [P2_Cabeza|P2_Cola], 1):-
    append(MazoMezclado, [P2_Cabeza], Mezcla1), % Al revés, primero P2, luego P1.
    append(Mezcla1, [P1_Cabeza], Mezcla2),
    random(0, 2, PilaEscogida),
    mezclar(Mazo, Mezcla2, P1_Cola, P2_Cola, PilaEscogida).

% El montón P1 ya no tiene cartas disponibles!
mezclar(Mazo, MM, [], [P2_Cabeza|P2_Cola], Random) :-
    append(MM, [P2_Cabeza], O),
    mezclar(Mazo, O, [], P2_Cola, Random). % El mismo random, para terminar ese montón.

% El montón P2 ya no tiene cartas disponibles!
mezclar(Out, Em, [P1_Cabeza|P1_Cola], [], Random) :-
    append(Em, [P1_Cabeza], O),
    mezclar(Out, O, P1_Cola, [], Random).% El mismo random, para terminar ese montón.

mezclar(Mazo, Mazo, [], [], _):- !. % Ya no quedan cartas en los montones!

% Posibles posibilidades probables de ocurrir probablemente:
%
 % Escalera real
 % Escalera de color
 % Poker
 % Full house
 % Color
 % Escalera
 % Tío
 % Doble par
 % Par
 % Carta más alta.

revisarSiApuestoTodo(Mano, Resultado):-
    (
        (escaleraReal(Mano), Resultado = "ESCALERA REEAAAAAAAAAAAAAAAAAAAAL PAPÁ!! NO ME IMPORTA NAAAAAAAAAAADA CARAJOOO");
        (escaleraColor(Mano), Resultado = "Escalera a colooooooooooor!!");
        (poker(Mano), Resultado = "Poker papaaaaá!");
        (fullHouse(Mano), Resultado = "Full house!");
        (color(Mano), Resultado = "Color!... O flor.");
        (escalera(Mano), Resultado = "Escalera!");
        (trio(Mano), Resultado = "Trio!");
        (doblePar(Mano), Resultado = "Doble Par!");
        (par(Mano), Resultado = "Dobles!");
        (cartaAlta(Mano, CartaAlta), string_concat('Carta Alta: ', CartaAlta, Resultado))
    ).

%cartaAlta([card(2,♦),card(4,♥),card(4,♦),card(5,♦),card(11,♥)],CartaAlta).
cartaAlta([_,_,_,_,C5], CartaAlta):-
    mapATexto(card(R,S),C5),
    string_concat(R, " de ", CA1),
    string_concat(CA1, S, CartaAlta).

%par([card(2,♦),card(4,♥),card(4,♦),card(5,♦),card(10,♥)]).
par([C1,C2,C3,C4,C5]):-
    mismoNumero(C1,C2);
    mismoNumero(C2,C3);
    mismoNumero(C3,C4);
    mismoNumero(C4,C5).

%doblePar([card(2,♦),card(2,♥),card(4,♦),card(10,♦),card(10,♥)]).
doblePar([C1,C2,C3,C4,C5]):-
    mismoNumero(C1,C2), (mismoNumero(C3, C4); mismoNumero(C4,C5));
    mismoNumero(C2,C3), mismoNumero(C4,C5).

%trio([card(4,♦),card(4,♥),card(4,♦),card(5,♦),card(10,♥)]).
trio([C1,C2,C3,C4,C5]):-
    mismoNumero(C1,C2,C3);
    mismoNumero(C2,C3,C4);
    mismoNumero(C3,C4,C5).

%escalera([card(4,♦),card(5,♥),card(6,♦),card(7,♦),card(8,♥)]).
escalera([C1,C2,C3,C4,C5]):-
    valor(V1, C1),valor(V2, C2),valor(V3, C3),valor(V4, C4),valor(V5, C5),
    (
        (V1 is (V2-1), V2 is (V3-1), V3 is (V4-1), V4 is (V5-1));
        (V1 is 2, V2 is 3, V3 is 4, V4 is 5, V5 is 14) % Y si hay un Ace en C5? Entonces:[A,2,3,4,5]=[14,2,3,4,5].
    ).

%color([card(4,♥),card(5,♥),card(6,♥),card(7,♥),card(8,♥)]).
color([C1,C2,C3,C4,C5]):-
    color(Color1, C1),color(Color2, C2),color(Color3, C3),color(Color4, C4),color(Color5, C5),
    Color1 = Color2, Color2 = Color3, Color3 = Color4, Color4 = Color5.

%fullHouse([card(9,♥),card(10,♠),card(jack,♠),card(jack,♥),card(jack,♦)]).
fullHouse([C1,C2,C3,C4,C5]):-
    (mismoNumero(C1,C2,C3), mismoNumero(C4,C5));
    (mismoNumero(C1,C2), mismoNumero(C3,C4,C5)).

%poker([card(4,♥),card(4,♥),card(4,♥),card(4,♥),card(5,♥)]).
poker([C1,C2,C3,C4,C5]):-
    mismoNumero(C1,C2,C3,C4); mismoNumero(C2,C3,C4,C5).

%escaleraColor([card(2,♥),card(3,♥),card(4,♥),card(5,♥),card(6,♥)]).
escaleraColor(Mano):-
    escalera(Mano), color(Mano).

%escaleraColor([card(10,♥),card(11,♥),card(12,♥),card(13,♥),card(14,♥)]).
escaleraReal([C1,C2,C3,C4,C5]):-
    escalera([C1,C2,C3,C4,C5]), color([C1,C2,C3,C4,C5]),
    valor(V5, C5), V5 = 14.

% Comprobar si es el mismo número de carta, no importa el color.
mismoNumero(card(R1, _), card(R2, _)):-
    R1 = R2.
mismoNumero(card(R1, _), card(R2, _), card(R3,_)):-
    R1 = R2,
    R2 = R3,
    R1 = R3.
mismoNumero(card(R1, _), card(R2, _), card(R3,_), card(R4,_)):-
    R1 = R2,
    R2 = R3,
    R3 = R4,
    R1 = R4.
