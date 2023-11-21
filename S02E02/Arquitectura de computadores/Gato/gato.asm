
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h     

.DATA
    ; TEXT
    txt_humanPlays db 10, 13, "Tu turno.$"
    txt_CPUPlays db 10, 13, "Turno de la CPU.$"                    
    txt_aksForRow db 10, 13, 9, "Ingresa una fila: $"
    txt_askForCol db 10, 13, 9, "Ingresa una columna: $"
    txt_alreadyTaken db 10, 13, 9, 9, "La casilla ya ha sido ocupada!$"
    txt_outBounds db 10, 13, 9, 9, "La opcion se encuentra fuera de los limites!$"
    txt_gameOver db 10, 13, "Has perdido :($"
    txt_gameDone db 10, 13, "Has ganado! :D$"
    txt_itsADraw db 10, 13, "Es un empate :/$"    
    txt_waitForKey db 10, 13, "Presiona una tecla para finalizar... $"
    ; Aux
    txt_newLine db 10, 13, "$"
    txt_tab db 9, 9, "$"
    txt_boardVerticalDivider db "|$"
    txt_boardHorizontalDivider db "-----$"
    
    txt_human db "O$"
    txt_CPU db "X$"
    txt_empty db " $"
    
    ; VARIABLES    
    human db 1
    CPU db 2
    
    currentPlayer db 0
    ; Start player
    humanFirst db 0
    ; Game finished
    draw db 0

    ; Board
    board db 9 dup(0)
    ;board db 0,1,2,1,2,1,1,2,1
    currentBoardIndex db 0
    
    ; Round
    actual_round db 0
    
    ; Random
    random db 0
    
    ; Is a valid movement
    validLimit db 0
    validMovement db 0
    
    ; Selected positions
    humanRow db 0
    humanCol db 0
    CPURow db 0
    CPUCol db 0

.CODE
    mov ax, @data
    mov ds, ax
    
    ; DEFINE MACROS
    ;
    showMessage macro txt
        push ax
        push bx
        push cx
        ;
        lea dx, txt
        mov ah, 9h
        int 21h
        ;
        pop cx
        pop bx
        pop ax    
    endm                 
    
    validateMovement macro row, col
        lea si, board
        ; Get the position
        mov al, row
        dec al
        mov bl, 3
        mul bl
        add al, col
        dec al
        mov bl, al ; BL: The position in the array (0-8)
        ; Check if it's an empty cell
        mov ax, 1
        mul bl
        mov bx, ax ; Transform to 16. BX: The position in the array (0-8)        
        mov al, [si+bx] 
        cmp al, 0
        jne setInvalidMovement  
        ; Update board only if movement is valid, if not, it does jump this.   
        lea di, board
        mov al, currentPlayer 
        mov [bx+di], al 
        continue_setInvalidMovement:            
    endm
           
    ; MAIN PROGRAM
    ;
    ; Select who is first
    call selectFirstPlayer
    
    ; # Start game
    ; Check if human plays first or CPU
    ; If human then calls a function to do it in that order.
    ; Otherwise, the opposite. Those func check if game is done.
    ; If game isn't done, then repat process.
    getMovements:
        cmp humanFirst, 1
        je startHumanFirst
        
        cmp humanFirst, 0
        je startCPUFirst 
     
        continueGame:        
        jmp getMovements               
    
    startHumanFirst:
        ; Human turn
        showMessage txt_humanPlays 
        call getHumanMovement
        inc actual_round
        call updateBoard
        call checkWinCondition
        ; CPU Turn
        showMessage txt_CPUPlays
        call getCPUMovement
        inc actual_round
        call updateBoard
        ; Check if someone just win
        call checkWinCondition
        ; Continue game
        jmp continueGame
        
    startCPUFirst:
        ; CPU Turn
        showMessage txt_CPUPlays
        call getCPUMovement
        inc actual_round
        call updateBoard
        call checkWinCondition
        ; Human turn
        showMessage txt_humanPlays
        call getHumanMovement
        inc actual_round
        call updateBoard
        ; Check if someone just win
        call checkWinCondition
        ; Continue game
        jmp continueGame
ret


; Movements           
getHumanMovement:
    mov bl, human
    mov currentPlayer, bl
    getRow:
        ; Show text asking for a number
        showMessage txt_aksForRow
        call getKeyboardNumber
                      
        ; Check limits (0 < X < 4)
        mov validLimit, 1 ; By default: Mov is okay, but if not, it's 0.
        call validateLimits
        ; If valid, continue 
        cmp validLimit, 1
        je continue_getRow
        ; If not, again
        jmp getRow
    continue_getRow:
    ;It's all right, save movement
    mov humanRow, al ; Save it
   
    getColumn:
        ; Show text asking for a number
        showMessage txt_askForCol
        call getKeyboardNumber   
        ; Check limits (0 < X < 4)
        mov validLimit, 1 ; By default: Mov is okay, but if not, it's 0
        call validateLimits
        ; If valid, continue 
        cmp validLimit, 1
        je continue_getColumn
        ; If not, again
        jmp getColumn
    continue_getColumn:
    ;It's all right, save movement
    mov humanCol, al 
    
    
    mov validMovement, 1 ; By default, is a valid move, but if not, then 0
    validateMovement humanRow, humanCol
    ; If it's NOT a valid movement (already taken) 
    cmp validMovement, 0
    je getHumanMovement
ret

validateLimits:
    cmp al, 1 ; If less than 1
    jl setInvalidLimit
    
    mov bl, 3
    cmp al, 3 ; If greater than 3
    jg setInvalidLimit
    
    continue_setInvalidLimit:
ret

setInvalidLimit:
    showMessage txt_outBounds
    mov validLimit, 0
    jmp continue_setInvalidLimit                          

setInvalidMovement:
    showMessage txt_alreadyTaken
    mov validMovement, 0
    jmp continue_setInvalidMovement                             

getCPUMovement:
    mov bl, CPU
    mov currentPlayer, bl
            
    call getRandom
    ; Count how many empty cells
    mov al, 9
    sub al, actual_round
    ; Map random (0 - 99) to (0 - how_many_empty_cells)
    
    ; But if AL = 0, DONT DIVIDE 99/0
    cmp al, 0
    je yesItIs0
    
    mov bl, al
    mov al, 99
    mov ah, 0
    div bl
    mov bl, al
    mov al, random
    mov ah, 0
    div bl
    
    yesItIs0:
    
    ; Go to empty cell index: AL --> Selected cell
    lea di, board
    mov bl, 0
    moveXEmptyCells:    
        cmp [di], 0
        jne dontCountThisOne        
        
        cmp al, bl ; Are we on the X cell?
        je done_moveXEmptyCells
        inc bl        
        
        dontCountThisOne:
        inc di
        
        jmp moveXEmptyCells
        
    done_moveXEmptyCells:
    mov bl, currentPlayer
    mov [di], bl
ret
   
; Update board
updateBoard:
    ; New line
    showMessage txt_newLine
    showMessage txt_newLine
    
    mov bx, 0

    ; Print from [i=0] to [i=2]
    call printHorizontalChunck
    showMessage txt_newLine
    call printHorizontalDivider
    showMessage txt_newLine
    
    ; Print from [i=3] to [i=5]
    call printHorizontalChunck
    showMessage txt_newLine
    call printHorizontalDivider
    showMessage txt_newLine
    
    ; Print from [i=6] to [i=8]
    call printHorizontalChunck
    showMessage txt_newLine
    
    ; New line
    showMessage txt_newLine
ret


printHorizontalChunck:
    
    showMessage txt_tab
    ; Left element
    lea si, board
    call print_cell    
      
    ; Center element
    inc bx
    showMessage txt_boardVerticalDivider             
    call print_cell    
    showMessage txt_boardVerticalDivider
    
    ; Right element
    inc bx
    call print_cell
    inc bx
ret

print_cell:
    cmp [si+bx], 0
    je printEmpty
    
    cmp [si+bx], 1
    je printHuman
    
    cmp [si+bx], 2
    je printCPU
    
    continue_printCell:
ret    
 
printEmpty:
    showMessage txt_empty
    jmp continue_printCell

printHuman:
    showMessage txt_human
    jmp continue_printCell

printCPU:
    showMessage txt_CPU
    jmp continue_printCell
    

; Just a line
printHorizontalDivider:
    showMessage txt_tab
    showMessage txt_boardHorizontalDivider
ret

 
; Check if game is done
checkWinCondition:    
    ; Horizontal check
    mov bx, 0
    call compareHorizontal
    call compareHorizontal
    call compareHorizontal
    
    ; Vertical check
    mov bx, 0
    call compareVertical
    mov bx, 1
    call compareVertical
    mov bx, 2
    call compareVertical
    
    ; Cross check
    mov bx, 0
    call compareCross1
    mov bx, 2
    call compareCross2
    
    ; Draw?
    call checkDraw
ret

checkDraw:
    lea si, board
    mov cx, 9
    ; We assume it's a draw by default
    mov draw, 1
    sumBoardLoop:
        cmp [si], 0
        je notADraw
        inc si
        loop sumBoardLoop
    
    cmp draw, 1
    je terminateGame_draw
    
    continue_notADraw:                       
ret

notADraw:
    mov draw, 0
    jmp continue_notADraw

compareHorizontal:
    lea si, board  
    ; Check if triple empty:
    cmp [si+bx], 0
    je emptyHorizontal
    ; If not, check if are the same
    mov al, [si+bx]    
    inc bx
    cmp al, [si+bx]
    je compareWithRightSide
    inc bx
    continue_compareWithRightSide: 
    inc bx
ret
                
; Increase bx to continue with others call compareHorizontal
emptyHorizontal:
    inc bx
    inc bx
    jmp continue_compareWithRightSide                       

compareWithRightSide:
    lea si, board
    mov al, [si+bx]
    inc bx
    cmp al, [si+bx]
    je terminateGame
    ; If not, continue
    jmp continue_compareWithRightSide
    
compareVertical:
    lea si, board
    ; Check if triple empty:
    cmp [si+bx], 0
    je continue_compareWithBottomSide
    mov al, [si+bx]
    add bx, 3
    mov dl, [si+bx]
    cmp al, dl
    je compareWithBottomSide
    continue_compareWithBottomSide: 
ret

compareWithBottomSide:
    lea si, board
    mov al, [si+bx]
    add bx, 3
    cmp al, [si+bx]
    je terminateGame
    ; If not, continue
    jmp continue_compareWithBottomSide
    
compareCross1:
   lea si, board
   ; Check if triple empty:
   cmp [si+bx], 0
   je continue_compareOtherSide1
   
   mov al, [si+bx]    
   add bx, 4
   cmp al, [si+bx]
   je compareOtherSide1
   
   continue_compareOtherSide1:  
ret

compareOtherSide1:
    mov al, [si+bx]    
    add bx, 4
    cmp al, [si+bx]
    je terminateGame
    ; Not the same, continue.
    jmp continue_compareOtherSide1
    
compareCross2:
   lea si, board
   ; Check if triple empty:
   cmp [si+bx], 0
   je continue_compareOtherSide2
   
   mov al, [si+bx]    
   add bx, 2
   cmp al, [si+bx]
   je compareOtherSide2
   
   continue_compareOtherSide2:  
ret

compareOtherSide2:
    mov al, [si+bx]    
    add bx, 2
    cmp al, [si+bx]
    je terminateGame
    ; Not the same, continue.
    jmp continue_compareOtherSide2
     
terminateGame:
    ; Did I just win??? OMG
    mov bl, human 
    cmp currentPlayer, bl
    je terminateGame_winner
    
    jmp terminateGame_loser

terminateGame_winner:
    showMessage txt_newLine
    showMessage txt_gameDone
    showMessage txt_waitForKey
    call getKeyboardNumber
    jmp gameDone 
    
terminateGame_loser:
    showMessage txt_newLine
    showMessage txt_gameOver
    showMessage txt_waitForKey
    call getKeyboardNumber
    jmp gameDone
    
terminateGame_draw:
    showMessage txt_newLine
    showMessage txt_itsADraw
    showMessage txt_waitForKey
    call getKeyboardNumber
    jmp gameDone


; AUX
; Select who is first
selectFirstPlayer:
    call getRandom     
    cmp random, 50
    jae setHumanFirstPlayer
    continue_setHumanFirstPlayer:
ret

setHumanFirstPlayer:
    mov humanFirst, 1
    jmp continue_setHumanFirstPlayer

getKeyboardNumber:
    mov ah, 01
    int 21h    
    sub al, 48
ret
    
getRandom:
    mov ah, 2Ch
    int 21h
    mov random, dl
ret
     

gameDone: