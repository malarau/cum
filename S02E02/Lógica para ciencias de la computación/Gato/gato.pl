
% Inicia un tablero vac�o.
board(X):-
    append([" ", " ", " "], [" ", " ", " ", " ", " ", " "], X).

start:- board(X), play(X,0,_).


% Dibula el tablero, que inicialmente es una lista con 9 espacios. Va de
% 3 en 3.
drawGato(Board):-
    write('Gato: '), nl,
    tab(5), getPos(1, Board, A11), write(A11), write("|"), getPos(2, Board, A12), write(A12), write("|"), getPos(3, Board, A13), write(A13), nl,
    tab(5), write("-+-+-"), nl,
    tab(5), getPos(4, Board, A21), write(A21), write("|"), getPos(5, Board, A22), write(A22), write("|"), getPos(6, Board, A23), write(A23), nl,
    tab(5), write("-+-+-"), nl,
    tab(5), getPos(7, Board, A31), write(A31), write("|"), getPos(8, Board, A32), write(A32), write("|"), getPos(9, Board, A33), write(A33), nl.

% Se obtiene el �tem de la lista que estamos buscando (del 1 al 9).
% Con el elemento, podemos consultar si es == " ", para saber si es una
% jugada v�lida o no.
getPos(1, [Cabeza|_], Cabeza).
getPos(Pos, [_|Tail], X):-
    N is Pos - 1,
    getPos(N, Tail, X).


% La traducci�n de las coordenadas ingresadas por jugador.
% Primer param : X
% Segundo param: Y
% Tercer param : Posici�n en la lista que representa el tablero.
cellPos(1,1,1).
cellPos(1,2,2).
cellPos(1,3,3).
cellPos(2,1,4).
cellPos(2,2,5).
cellPos(2,3,6).
cellPos(3,1,7).
cellPos(3,2,8).
cellPos(3,3,9).

% Funciones obtenidas desde:
% https://github.com/Rootex/99-prolog-problems/blob/master/lists.prolog#L120
insert(A, L, 1, [A|L]).
insert(A, [H|T], N, [H|R]) :-
        N1 is N - 1,
        insert(A, T, N1, R).

remove(H, [H|T], 1, T).
remove(X, [H|T], N, [H|R]):-
        N1 is N - 1,
        remove(X, T, N1, R).

% Player 0: Human, O
% Player 1: CPU, X
% @param Board El tablero inicial o el �ltimo actualizado.
% @param 0 Indica que es turno del jugador humano.
% @param NewBoard Es donde se va actualizando el tablero.
% El predicado play es siempre verdadero ya que: Obtiene movimiento
% correcto, chequea las condiciones de victoria y pasa de turno... O el
% movimiento ha fallado y pasa el otro lado del OR, donde muestra que el
% movimiento no es v�lido y debe volver a llamarse a s� mismo
play(Board, 0, NewBoard):- !,
    (
        drawGato(Board), getHumanMovement(Board, NewBoard, 0, GameStatus),!,
        (
            GameStatus == "win", drawGato(NewBoard), !,write('Le has ganado a la m�quina en aleatorio, qu� gran logro para el curriculum!'), nl;
            GameStatus == "draw", drawGato(NewBoard), !,write('EMPATE :('), nl;
            play(NewBoard, 1, _)
        );
        write('Movimiento ilegal!'), nl, play(Board, 0, _)
    ).

% Turno de la m�quina, no imprime Board ni alerta de movimiento no
% v�lido, a diferencia del play para human.
play(Board, 1, NewBoard):- !,
    (
        getRandomMovement(Board, NewBoard, 1, GameStatus),!,
        (
            GameStatus == "win", drawGato(NewBoard), !,write('Has perdido contra la m�quina en aleatorio, desinstala pls!'), nl;
            GameStatus == "draw", drawGato(NewBoard), !,write('EMPATE :('), nl;
            play(NewBoard, 0, _)
        );
        play(Board, 1, _)
    ).

% Obtiene movimientos random entre las casillas 1 y 9.
% La diferencia con getHumanMovement, es que si el movimiento no es
% v�lido, no lo informa, as� que prueba hasta que salga.
getRandomMovement(Board, NewBoard, Player, GameStatus):-
    random(1,10, Cell),
    getPos(Cell, Board, CellValue),
    CellValue == " ",
    drawMove(Board, Cell, Player, NewBoard),
    symbol(Player, Symbol),
    (
        % Dentro de este par�ntesis va un OR.
        % La condici�n de ganar es suficiente por si sola, o pasa a la 2da linea.
        % Que siempre es verdadera, indicando que el juego contin�a.
        checkGameStatus(NewBoard, "draw", GameStatus);
        checkGameStatus(NewBoard, Symbol, GameStatus);
        GameStatus = "playing"
     ).

    % X,Y: Coord
getHumanMovement(Board, NewBoard, Player, GameStatus):-
    write('Fila   : '), read(X), nl,
    write('Columna: '), read(Y), nl,
    cellPos(X, Y, Cell),
    getPos(Cell, Board, CellValue),
    CellValue == " ",
    drawMove(Board, Cell, Player, NewBoard),
    symbol(Player, Symbol),
    (
        % Dentro de este par�ntesis va un OR.
        % La condici�n de ganar es suficiente por si sola, o pasa a la 2da linea.
        % Que siempre es verdadera, indicando que el juego contin�a.
        checkGameStatus(NewBoard, "draw", GameStatus);
        checkGameStatus(NewBoard, Symbol, GameStatus);
        GameStatus = "playing"
    ).

% Todas las condiciones de victoria
checkGameStatus([A11,A12,A13,_,_,_,_,_,_],Sym, "win"):- A11=Sym,A11=A12,A12=A13.
checkGameStatus([_,_,_,A21,A22,A23,_,_,_],Sym, "win"):- A21=Sym,A21=A22,A22=A23.
checkGameStatus([_,_,_,_,_,_,A31,A32,A33],Sym, "win"):- A31=Sym,A31=A32,A32=A33.
checkGameStatus([A11,_,_,A21,_,_,A31,_,_],Sym, "win"):- A11=Sym,A11=A21,A21=A31.
checkGameStatus([_,A12,_,_,A22,_,_,A32,_],Sym, "win"):- A12=Sym,A12=A22,A22=A32.
checkGameStatus([_,_,A13,_,_,A23,_,_,A33],Sym, "win"):- A13=Sym,A13=A23,A23=A33.
checkGameStatus([A11,_,_,_,A22,_,_,_,A33],Sym, "win"):- A11=Sym,A11=A22,A22=A33.
checkGameStatus([_,_,A13,_,A22,_,A31,_,_],Sym, "win"):- A31=Sym,A31=A22,A22=A13.

% La condici�n de empate: Que cada espacio sea distinto al inicial.
checkGameStatus([A11,A12,A13,A21,A22,A23,A31,A32,A33],_, "draw"):-
    A11\=" ",
    A12\=" ",
    A13\=" ",
    A21\=" ",
    A22\=" ",
    A23\=" ",
    A31\=" ",
    A32\=" ",
    A33\=" ".

% Se obtiene el s�mbolo correspondiente a cada jugador.
symbol(0, "O").
symbol(1, "X").

% 1.- Obtiene el s�mbolo del jugador.
% 2.- Remueve el elemento de la celda en cuesti�n.
% 3.- Inserta el s�mbolo del jugador que estaaba en turno.
drawMove(Board, Cell, Player, NewBoard):-
    symbol(Player, Symbol),
    remove(_, Board, Cell, Board2),
    insert(Symbol, Board2, Cell, NewBoard).




