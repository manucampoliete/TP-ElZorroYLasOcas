global main

extern cargarMatriz
extern reemplazarIconos
extern imprimirTablero

%include 'macros.asm'

%macro compararSiguiente 1

    add     rbx,%1
    cmp     byte[tablero + rbx],' '
    jne     moverZorro
    
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al

    sub     rbx,%1
    mov     byte[tablero + rbx],' '
    
    sub     rbx,%1
    mov     byte[tablero + rbx],' '

%endmacro

section .data
    tablero         db '-','-',' ',' ',' ','-','-'
                    db '-','-','O','O','O','-','-'
                    db ' ','O',' ',' ',' ','O',' '
                    db ' ','O',' ',' ',' ','O',' '
                    db ' ','O',' ','X',' ','O',' '
                    db '-','-','O','O','O','-','-'
                    db '-','-',' ',' ',' ','-','-'

    longitudFila            dq 7
    longitudElem            dq 1
    filaZorro               dq 5
    columnaZorro            dq 4
    cantMovimientos         dq 100
    turnoZorro              db 1
    ocasComidas             db 0

    msgMovimientoZorro      db 'Ingrese un movimiento para el zorro: ',0
    msgElegirOrientacion    db 'Elija una orientación para el tablero (N si no quiere rotar, I para',10
                            db 'rotar a Izquierda, D para rotar a Derecha y V para dar vuelta): ',0
    msgElegirIconoZorro     db 'Elija un ícono para el zorro (X por default): ',0
    msgElegiriconoOca       db 'Elija un ícono para la oca (O por default): ',0
    comandoClear            db 'clear',0
    msgHaGanadoElZorro      db 'Ha ganado el Zorro!',0
    msgHanGanadoLasOcas     db 'Han ganado las ocas!',0

section .bss
    movimiento              resb 10
    orientacion             resb 10
    iconoZorro              resb 10
    iconoOca                resb 10
    RESULTMOVZORRO          resb 1
    RESULTORIENTACION       resb 1
    
section .text
main:

    mov     rdi,msgElegirOrientacion
    mPrintf
    mGets   orientacion

    mov     rdi,msgElegirIconoZorro
    mPrintf
    mGets   iconoZorro

    mov     rdi,msgElegiriconoOca
    mPrintf
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


loopPrincipal:

    mSystem comandoClear

    mov     rdi,tablero
    sub     rsp,8
    call    imprimirTablero
    add     rsp,8

    cmp     byte[ocasComidas],12
    je      ganoZorro

    ; sub     rsp,8
    ; call    zorroPuedeMoverse
    ; add     rsp,8

    ; cmp     rax,0
    ; je      ganaronOcas

    cmp     byte[turnoZorro],1
    je      moverZorro

    jmp     moverOcas

; MOVER ZORRO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moverZorro:

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

    jmp     loopPrincipal

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

    cmp     qword[columnaZorro],2
    je      compararVacioIzq

    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacioIzq

    mov     r14,-1
    compararSiguiente r14
    inc     byte[ocasComidas]

    jmp     cambiarColumnaIzq

compararVacioIzq:
    cmp     byte[tablero + rbx],' '
    jne     loopPrincipal

moverZorroAdyacenteIzq:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    dec     byte[columnaZorro]
;   mov     byte[turnoZorro],0
    jmp     loopPrincipal

cambiarColumnaIzq:
    sub     byte[columnaZorro],2
    jmp     loopPrincipal



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

    cmp     qword[columnaZorro],6
    je      compararVacioDer

    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacioDer

    mov     r14,1
    compararSiguiente r14
    inc     byte[ocasComidas]

    jmp     cambiarColumnaDer
    
compararVacioDer:
    cmp     byte[tablero + rbx],' '
    jne     loopPrincipal

moverZorroAdyacenteDer:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    dec     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[columnaZorro]
;   mov     byte[turnoZorro],0
    jmp     loopPrincipal

cambiarColumnaDer:
    add     byte[columnaZorro],2
    jmp     loopPrincipal



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

    cmp     qword[filaZorro],2
    je      compararVacioArr
    
    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacioArr

    mov     r14,[longitudFila]
    imul    r14,r14,-1
    compararSiguiente r14
    inc     byte[ocasComidas]

    jmp     cambiarFilaArr

compararVacioArr:
    cmp     byte[tablero + rbx],' '
    jne     loopPrincipal

moverZorroAdyacenteArr:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    add     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

    dec     byte[filaZorro]
;   mov     byte[turnoZorro],0
    jmp     loopPrincipal

cambiarFilaArr:
    sub     byte[filaZorro],2
    jmp     loopPrincipal
    


moverAbajo:
    cmp     qword[filaZorro],7
    je      moverZorro

    mov     rax,[filaZorro]
    imul    rax,[longitudFila]

    mov     rbx,[columnaZorro]
    dec     rbx
    imul    rbx,[longitudElem]

    add     rbx,rax

    cmp     qword[filaZorro],6
    je      compararVacioAbj

    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacioAbj

    mov     r14,[longitudFila]
    compararSiguiente r14
    inc     byte[ocasComidas]
    
    jmp     cambiarFilaAbj

compararVacioAbj:
    cmp     byte[tablero + rbx],' '
    jne     loopPrincipal

moverZorroAdyacenteAbj:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    sub     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

    inc     byte[filaZorro]
;   mov     byte[turnoZorro],0
    jmp     loopPrincipal

cambiarFilaAbj:
    add     byte[filaZorro],2
    jmp     loopPrincipal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; MOVER OCAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moverOcas:
    jmp     loopPrincipal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ganoZorro:
    mPuts   msgHaGanadoElZorro
    jmp     fin

ganaronOcas:
    mPuts   msgHanGanadoLasOcas

fin:
    ret
; ********************************
; RUTINAS INTERNAS
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



