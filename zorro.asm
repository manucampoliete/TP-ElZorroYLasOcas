global main

extern cargarMatriz
extern reemplazarIconos
extern imprimirTablero

%include 'macros.asm'

section .data
;   bordeSup        db '-','-','-','-','-','-','-'
    tablero         db '-','-','O','O','O','-','-'
                    db '-','-','O','O','O','-','-'
                    db 'O','O','O','O','O','O','O'
                    db 'O',' ',' ',' ',' ',' ','O'
                    db 'O',' ',' ','X',' ',' ','O'
                    db '-','-',' ',' ',' ','-','-'
                    db '-','-',' ',' ',' ','-','-'
;   bordeInf        db '-','-','-','-','-','-','-'

    longitudFila            dq 7
    longitudElem            dq 1
    filaZorro               dq 5
    columnaZorro            dq 4
    cantMovimientos         dq 100

    msgMovimientoZorro      db 'Ingrese un movimiento para el zorro: ',0
    msgElegirOrientacion    db 'Elija una orientación para el tablero',10
                            db '(N si no quiere rotar, I para rotar a Izquierda, D para rotar a Derecha y V para dar vuelta)',0
    msgElegirIconoZorro     db 'Elija un ícono para el zorro (X por default): ',0
    msgElegiriconoOca       db 'Elija un ícono para la oca (O por default): ',0
    comandoClear            db 'clear',0

section .bss
    movimiento              resb 10
    orientacion             resb 10
    iconoZorro              resb 10
    iconoOca                resb 10
    RESULTMOVZORRO          resb 1
    RESULTORIENTACION       resb 1
    RESULT                  resb 1
    
section .text
main:

    mPuts   msgElegirOrientacion
    mGets   orientacion

    mPuts   msgElegirIconoZorro
    mGets   iconoZorro

    mPuts   msgElegiriconoOca
    mGets   iconoOca

    mov     rdi,tablero
    xor     rsi,rsi
    mov     sil,[orientacion]
    mov     rdx,filaZorro
    mov     rcx,columnaZorro
    sub     rsp,8
    call    cargarMatriz
    add     rsp,8

    mov     rdi,tablero
    xor     rsi,rsi
    mov     sil,[iconoZorro]
    xor     rdx,rdx
    mov     dl,[iconoOca]
    sub     rsp,8
    call    reemplazarIconos
    add     rsp,8

moverZorro:

    mSystem comandoClear
    
    mov     rdi,tablero
    sub     rsp,8
    call    imprimirTablero
    add     rsp,8

    cmp     qword[cantMovimientos],0
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
    cmp     qword[columnaZorro],1
    je      moverZorro

    mov     rax,[filaZorro]
    dec     rax
    imul    rax,[longitudFila]

    mov     rbx,[columnaZorro]
    dec     rbx
    imul    rbx,[longitudElem]
    dec     rbx

    add     rbx,rax

    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacio

    ;mov     r14,-1
    ;compararSiguiente r14

    sub     rsp,8
    call    compararSiguienteIzq
    add     rsp,8

    cmp     byte[RESULT],0
    je      moverZorro
    jmp     cambiarColumna

compararVacio:
    cmp     byte[tablero + rbx],' '
    jne     moverZorro

moverZorroAdyacente:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    dec     byte[columnaZorro]
    jmp     restarCantMovimientos

cambiarColumna:
    sub     byte[columnaZorro],2

restarCantMovimientos:
    dec     qword[cantMovimientos]
    jmp     moverZorro

moverDer:
    cmp     qword[columnaZorro],7
    je      moverZorro

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

    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    dec     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[columnaZorro]

    dec     qword[cantMovimientos]
    jmp     moverZorro

moverArriba:
    cmp     qword[filaZorro],1
    je      moverZorro

    mov     rax,[filaZorro]
    sub     rax,2
    imul    rax,[longitudFila]

    mov     rbx,[columnaZorro]
    dec     rbx
    imul    rbx,[longitudElem]

    add     rbx,rax

    cmp     byte[tablero + rbx],' '
    jne     moverZorro

    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    add     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

    dec     byte[filaZorro]

    dec     qword[cantMovimientos]
    jmp     moverZorro

moverAbajo:
    cmp     qword[filaZorro],7
    je      moverZorro

    mov     rax,[filaZorro]
    imul    rax,[longitudFila]

    mov     rbx,[columnaZorro]
    dec     rbx
    imul    rbx,[longitudElem]

    add     rbx,rax

    cmp     byte[tablero + rbx],' '
    jne     moverZorro

    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    sub     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

    inc     byte[filaZorro]

    dec     qword[cantMovimientos]
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
    
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al

    inc     rbx
    mov     byte[tablero + rbx],' '
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[RESULT]

noEstaLibre:
    ret
; ********************************
validarMovimientoZorro:
    mov     byte[RESULTMOVZORRO],'S'

    cmp     byte[movimiento],'Q'    ; Arriba-Izq
    je      movimientoZorroValido
    cmp     byte[movimiento],'W'    ; Arriba
    je      movimientoZorroValido
    cmp     byte[movimiento],'E'    ; Arriba-Der
    je      movimientoZorroValido
    cmp     byte[movimiento],'A'    ; Izq
    je      movimientoZorroValido
    cmp     byte[movimiento],'S'    ; Abajo
    je      movimientoZorroValido
    cmp     byte[movimiento],'D'    ; Der
    je      movimientoZorroValido
    cmp     byte[movimiento],'Z'    ; Abajo-Izq
    je      movimientoZorroValido
    cmp     byte[movimiento],'V'    ; Abajo-Der
    je      movimientoZorroValido

    mov     byte[RESULTMOVZORRO],'N'

movimientoZorroValido:
    ret
; ********************************
validarOrientacion:
    mov     byte[RESULTORIENTACION],'S'

    cmp     byte[orientacion],'N'    ; Sin orientación
    je      orientacionValida
    cmp     byte[orientacion],'I'    ; Rotado 90° a Izq
    je      orientacionValida
    cmp     byte[orientacion],'D'    ; Rotado 90° a Der
    je      orientacionValida
    cmp     byte[orientacion],'V'    ; Rotado 180°
    je      orientacionValida

    mov     byte[RESULTORIENTACION],'N'
orientacionValida:
    ret
; ********************************





; %macro compararSiguiente 1

;     mov     byte[RESULT],0

;     add     rbx,%1
;     cmp     byte[tablero + rbx],' '
;     jne     noEstaLibre
    
;     mov     byte[tablero + rbx],'X'

;     inc     rbx
;     mov     byte[tablero + rbx],' '
    
;     inc     rbx
;     mov     byte[tablero + rbx],' '

;     inc     byte[RESULT]
; noEstaLibre:
    
;     ret

; %endmacro
