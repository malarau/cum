
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here 

;a) Macro de Apilar.
;b) Macro de Desapilar.
;c) Macro de imprimir Pila.
;d) Macro de invertir Pila.
;e) Salir
     
.DATA
    ; TEXT
    ; Menu
    txt_menu db 10, 13, "Menu inicial: $"
    txt_menu1 db 10, 13, "1.- Apilar$"
    txt_menu2 db 10, 13, "2.- Desapilar$"
    txt_menu3 db 10, 13, "3.- Imprimir Pila$"
    txt_menu4 db 10, 13, "4.- Invertir Pila$"
    txt_menu5 db 10, 13, "5.- Salir$"
    txt_menu6 db 10, 13, "Ingresa una opcion: $"
    txt_outBounds db 10, 13, 9, 9, "La opcion se encuentra fuera de los limites.$" 
    ; Main
    txt_enter_value db 10, 13, 10, 13, 9, "Ingresa un valor: $"
    txt_full db 10, 13, "La pila esta llena!$" 
    txt_empty db 10, 13, "La pila esta vacia!$"
    txt_pop_ok db 10, 13, "El valor fue desapilado con exito.$" ; Creo
    txt_inverse_ok db 10, 13, "Pila invertida.$"
    ; Stack
    txt_elem_start db 10, 13, 9, 9, "[ $"
    txt_elem_end db " ]$"
    txt_empty_space db " $"
     
     
    ; Txt aux
    txt_newLine db 10, 13, "$"
    txt_tab db 9, 9, "$"
    
    ; STACK
    ;Default: 0's
    stack db 20 dup(0) ; CHANGE HERE
    currentSize db 0
    maxSize db 20
    
    ; Selected from menu
    choice db 0
    validLimit db 0
    value_to_stack db 0
    
    ;Aux   
    value1 db 0
    value2 db 0
    half_currenSize dw 0
    
     
.CODE
    mov ax, @data
    mov ds, ax
    
    ; DEFINE MACROS
    ;
    showMessage macro txt
        push ax
        push bx
        
        lea dx, txt
        mov ah, 9h
        int 21h

        pop bx
        pop ax    
    endm
    
    showNumber macro number
        push ax
        push bx
        
        mov dl, number
        add dl, 48
        mov ah, 2
        int 21h 

        pop bx
        pop ax        
    endm
    
    
    ; Macro 1
    macro1 macro value
        push ax ; Who knows
        push bx
        
        mov value_to_stack, al 
    
        lea di, stack
        ; Current position
        mov bl, currentSize
        
        cmp bl, maxSize
        je call_macro_full
        
        ; Base index -> DI, Current stack index -> BX
        mov ax, 1
        mul bl
        mov bx, ax
        ; Add it
        mov al, value_to_stack
        mov [di+bx], ax
        
        ; Increase size
        inc currentSize    
        
        pop bx
        pop ax     
        
    endm
        
    ; Macro 2
    macro2 macro
        push ax ; Who knows
        push bx
        
        mov al, currentSize
        cmp al, 0
        je call_macro_empty
        
        ; Current position
        mov bl, currentSize
        
        ;Add value to stack
        mov ax, 1
        mul bl
        dec ax ; Index = array[Size-1]
        mov bx, ax
        mov [di+bx], 0
        
        dec currentSize
        
        ; Pop message
        showMessage txt_pop_ok
        
        pop bx
        pop ax
    endm
    
    ; Macro 3
    macro3 macro
        push ax ; Who knows
        push bx
        
        showMessage txt_newLine
        
        mov ax, 1
        mul maxSize
        mov bx, ax
        dec bx ; array[Index], Index -> BX
        
        lea si, stack
        loop_stack_inverse:            
            
            showMessage txt_elem_start 
            mov al, [si+bx]
            cmp al, 0
            je empty ; If 0, it's empty then show an empty space
            
            ; If not, show the number

            showNumber al
            
            continue_empty:
            showMessage txt_elem_end
            
            dec bx
            ; It's the end of the stack?
            cmp bx, 0
            jl end_loop_stack_inverse   
            
            ; Not the end, continue loop             
            jmp loop_stack_inverse          
        
        empty:
            showMessage txt_empty_space
            jmp continue_empty 
        
        end_loop_stack_inverse:
              
        pop bx
        pop ax        
    endm
    
    ; Macro 4
    macro4 macro
        push ax ; Who knows
        push bx
        
        lea di, stack ;
        
        ; Set CX, the current size
        mov ax, 1
        mul currentSize
        mov cx, ax ; array[Index], Index -> BX
          
        ; Get half the size and put it into half_currenSize
        mov dx, 0
        mov bx, 2
        div bx
        mov half_currenSize, ax

        mov ax, 0 ; AX = Start index, CX = End index
        iterate_swap: 
            
            ; If we are at half size, then stop!
            cmp cx, half_currenSize
            jle end_iterate_swap  
        
            ; Get firts pos
            mov bx, ax
            mov dl, [di+bx]
            mov value1, dl
            
            ; Get last pos
            mov bx, cx
            dec bx
            mov dl, [di+bx]
            mov value2, dl
            
            ; Swap
            
            ; Set first pos
            mov bx, ax
            mov dl, value2
            mov [di+bx], dl
            
            ; Set last pos
            mov bx, cx
            dec bx
            mov dl, value1
            mov [di+bx], dl
            
                  
            ; Increase first pos index
            inc ax
            
            loop iterate_swap
        
        end_iterate_swap:
        
        showMessage txt_inverse_ok
            
        pop bx
        pop ax        
    endm
    
    
    
    ; MAIN

    main:
        call show_menu
        
         ; Ask for an option
        call getKeyboardNumber ; Saved --> AL
        
        ; Check limits (0 < X < 6)
        mov validLimit, 1 ; By default: It's valid.
        call validateLimits
        
        ; If valid, continue 
        cmp validLimit, 1
        je continue_main
        
        ; If not, again
        jmp main 
        
        ; Continue, it's a valid choice
        continue_main:
        mov choice, al        
        call execute_choice
        
        ; loop
        jmp main                               

ret
       
; BLOCKS AND FUNCTIONS
show_menu:
        showMessage txt_newLine
        showMessage txt_menu   
        
        showMessage txt_tab    
        showMessage txt_menu1
        
        showMessage txt_tab
        showMessage txt_menu2
        
        showMessage txt_tab
        showMessage txt_menu3
        
        showMessage txt_tab
        showMessage txt_menu4
        
        showMessage txt_tab
        showMessage txt_menu5
        
        showMessage txt_menu6
ret
   

; Validate choice.
validateLimits:
    cmp al, 1 ; If less than 1
    jl setInvalidLimit
    
    cmp al, 5 ; If greater than 5
    jg setInvalidLimit
    
    continue_setInvalidLimit:
ret           

setInvalidLimit:
    showMessage txt_outBounds
    mov validLimit, 0
    jmp continue_setInvalidLimit
   
;a) Macro de Apilar.
;b) Macro de Desapilar.
;c) Macro de imprimir Pila.
;d) Macro de invertir Pila.

execute_choice:
    mov bl, choice
     
    cmp bl, 1
    je call_macro_1
    
    cmp bl, 2
    je call_macro_2
    
    cmp bl, 3
    je call_macro_3
    
    cmp bl, 4
    je call_macro_4
    
    cmp bl, 5
    je call_macro_5
    
    continue_execute_choice:
ret

;1) Macro de Apilar
;1) Macro de Apilar
call_macro_1:
    showMessage txt_enter_value
    call getKeyboardNumber
    
    macro1 al
    
    jmp continue_execute_choice

; Full stack    
call_macro_full:
    showMessage txt_full
    jmp continue_execute_choice

;2) Macro de Desapilar.
;2) Macro de Desapilar.
call_macro_2:
    macro2     
    ; Continue
    jmp continue_execute_choice

; Empty Stack    
call_macro_empty:
    showMessage txt_empty
    jmp continue_execute_choice


;3) Macro de imprimir Pila.    
;3) Macro de imprimir Pila.    
call_macro_3:
    macro3
    jmp continue_execute_choice

;4) Macro de invertir Pila.    
;4) Macro de invertir Pila.    
call_macro_4:
    macro4    
    jmp continue_execute_choice

;5) SALIR
;5) SALIR
call_macro_5:
    hlt    

; Enter a value (stores in AL)
getKeyboardNumber:
    mov ah, 01
    int 21h    
    sub al, 48
ret

done:
