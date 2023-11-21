
org 100h

.CODE
    rectangulo macro x, y, alto, ancho, color
        local ciclo
        local nueva_fila
        local salida
        push ax
        push bx
        push cx
        push dx
        
        mov ax, x
        mov bx, y
        add ax, ancho
        add bx, alto
        
        mov cx, x
        mov dx, y
        
        ciclo:
            pintar color
            inc dx
            cmp dx, bx
            je nueva_fila
            jmp ciclo
        
        nueva_fila:
            mov dx, y
            inc cx
            cmp cx, ax
            je salida
            pintar color
            jmp ciclo
            
        salida:
            pop dx
            pop cx
            pop bx
            pop ax
    endm
    
    pintar macro color
        push ax
        push bx
        push cx
        push dx 
        
        mov al, color
        mov ah, 0ch
        int 10h
        
        pop dx
        pop cx
        pop bx
        pop ax
    endm
        
    mov ax, 12h
    int 10h
    
    ; rectangulo alto, ancho, x, y, color
    ;CODE_HERE

	

ret

