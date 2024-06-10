global main

extern puts
extern gets

%macro mPuts 1
    mov     rdi,%1 ; const char *str
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

%macro mGets 1
    mov     rdi,%1 ; char *buffer
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro

section .data
    tablero         db 'N','N',' ',' ',' ','N','N',0
                    db 'N','N',' ',' ',' ','N','N',0
                    db ' ',' ',' ',' ',' ',' ',' ',0
                    db ' ',' ',' ',' ',' ',' ',' ',0
                    db ' ',' ',' ','X',' ',' ',' ',0
                    db 'N','N',' ',' ',' ','N','N',0
                    db 'N','N',' ',' ',' ','N','N',0

    longitudFila    dq 8
    longitudElem    dq 1

    filaZorro       dq 5
    columnaZorro    dq 4

    msgMovimientoZorro      db "Ingrese un movimiento para el zorro: ",0

    RESULT                  db 1

section .bss
    movimiento              resb 1
    contador                resq 1
    
section .text
main:

    mov     rsi,10

moverZorro:
    mov     qword[contador],7
    mov     r15,tablero

imprimirFila:
    cmp     qword[contador],0
    je      impresionFinalizada

    mPuts   r15

    add     r15,[longitudFila]
    dec     qword[contador]
    jmp     imprimirFila

impresionFinalizada:
     cmp     rsi,0
     je      fin

     mPuts   msgMovimientoZorro
     mGets   movimiento

     cmp     byte[movimiento],'A'
     je      moverIzq

     cmp     byte[movimiento],'D'
     je      moverDer

     cmp     byte[movimiento],'W'
     je      moverArriba

     cmp     byte[movimiento],'S'
     je      moverAbajo

     jmp     fin

 moverIzq:
     mov     rax,[filaZorro]
     dec     rax
     imul    rax,[longitudFila]

     mov     rbx,[columnaZorro]
     dec     rbx
     imul    rbx,[longitudElem]
     dec     rbx

     add     rbx,rax

     cmp     byte[tablero + rbx],'O'
     jne     compararVacio
     mov    r14,-1
     compararSiguiente r14
     cmp    byte[RESULT],0
     je     moverZorro
     jmp    cambiarColumna

compararVacio:
     cmp     byte[tablero + rbx],' '
     jne     moverZorro

moverZorroAdyacente:
     mov     byte[tablero + rbx],'X'
    
     inc     rbx
     mov     byte[tablero + rbx],' '

     dec     byte[columnaZorro]
     jmp     restarRsi

cambiarColumna:
    sub     byte[columnaZorro],2

restarRsi:
     dec     rsi
     jmp     moverZorro

 moverDer:
     mov     rax,[filaZorro]
     dec     rax
     imul    rax,[longitudFila]

     mov     rbx,[columnaZorro]
     dec     rbx
     imul    rbx,[longitudElem]
     inc     rbx

     add     rbx,rax

     cmp     byte[tablero + rbx],' '
     jne     moverZorro

     mov     byte[tablero + rbx],'X'
    
     dec     rbx
     mov     byte[tablero + rbx],' '

     inc     byte[columnaZorro]

     dec     rsi
     jmp     moverZorro

 moverArriba:
     mov     rax,[filaZorro]
     sub     rax,2
     imul    rax,[longitudFila]

     mov     rbx,[columnaZorro]
     dec     rbx
     imul    rbx,[longitudElem]

     add     rbx,rax

     cmp     byte[tablero + rbx],' '
     jne     moverZorro

     mov     byte[tablero + rbx],'X'
    
     add     rbx,[longitudFila]
     mov     byte[tablero + rbx],' '

     dec     byte[filaZorro]

     dec     rsi
     jmp     moverZorro


 moverAbajo:
     mov     rax,[filaZorro]
     imul    rax,[longitudFila]

     mov     rbx,[columnaZorro]
     dec     rbx
     imul    rbx,[longitudElem]

     add     rbx,rax

     cmp     byte[tablero + rbx],' '
     jne     moverZorro

     mov     byte[tablero + rbx],'X'
    
     sub     rbx,[longitudFila]
     mov     byte[tablero + rbx],' '

     inc     byte[filaZorro]

     dec     rsi
     jmp     moverZorro
    
 fin:
    ret

; ********************************
; RUTINAS INTERNAS
; ********************************
compararSiguienteIzq:

    mov     byte[RESULT],0

    dec     rbx
    cmp     byte[tablero + rbx],' '
    jne     noEstaLibre
    
    mov     byte[tablero + rbx],'X'

    inc     rbx
    mov     byte[tablero + rbx],' '
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[RESULT]
noEstaLibre:
    
    ret
; ********************************
%macro compararSiguiente 1

    mov     byte[RESULT],0

    add     rbx,%1
    cmp     byte[tablero + rbx],' '
    jne     noEstaLibre
    
    mov     byte[tablero + rbx],'X'

    inc     rbx
    mov     byte[tablero + rbx],' '
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[RESULT]
noEstaLibre:
    
    ret

%endmacro
