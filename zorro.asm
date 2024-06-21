global main

extern cargarMatriz
extern reemplazarIconos
extern imprimirTablero
extern calcularDesplazamiento

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
    movimientosOca  times 0 db ' '
    movOcaCostado1          db 'A'
    movOcaAdelante          db 'S'
    movOcaCostado2          db 'D'
    cantMovimientos         dq 100
    turnoZorro              db 1
    ocasComidas             db 0

    msgMovimientoZorro      db 'Ingrese un movimiento para el zorro: ',0
    msgElegirOrientacion    db 'Elija una orientación para el tablero (N si no quiere rotar, I para',10
                            db 'rotar a Izquierda, D para rotar a Derecha y V para dar vuelta): ',0
    msgElegirIconoZorro     db 'Elija un ícono para el zorro (X por default): ',0
    msgElegiriconoOca       db 'Elija un ícono para la oca (O por default): ',0
    comandoClear            db 'clear',0
    msgPedirPosicionOca     db 'Ingrese fila (1 a 7) y columna (1 a 7) separados por un espacio: ',0
    formatoPosicionOca      db '%hhi %hhi',0
    msgPedirMovimientoOca   db 'Ingrese un movimiento para la oca: ',0
    msgNoHayOca             db 'Allí no hay una oca! Elija otra posición: ',0
    msgHaGanadoElZorro      db 'Ha ganado el Zorro!',0
    msgHanGanadoLasOcas     db 'Han ganado las ocas!',0

section .bss
    movimientoZorro         resb 10
    movimientoOca           resb 10
    posicionOca             resb 10
    filOca                  resb 1
    colOca                  resb 1
    orientacionTablero      resb 10
    iconoZorro              resb 10
    iconoOca                resb 10
    RESULTMOVZORRO          resb 1
    RESULTMOVOCA            resb 1
    RESULTORIENTACION       resb 1
    
section .text
main:

pedirOrientacion:
    mov     rdi,msgElegirOrientacion
    mPrintf
    mGets   orientacionTablero

    sub     rsp,8
    call    validarOrientacion
    add     rsp,8

    cmp     byte[RESULTORIENTACION],'S'
    jne     pedirOrientacion

pedirIconoZorro:
    mov     rdi,msgElegirIconoZorro
    mPrintf
    mGets   iconoZorro

pedirIconoOca:
    mov     rdi,msgElegiriconoOca
    mPrintf
    mGets   iconoOca

    mov     rdi,tablero
    xor     rsi,rsi
    mov     sil,[orientacionTablero]
    mov     rdx,filaZorro
    mov     rcx,columnaZorro
    mov     r8,movimientosOca
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
    mGets   movimientoZorro

    sub     rsp,8
    call    validarMovimientoZorro
    add     rsp,8

    cmp     byte[RESULTMOVZORRO],'S'
    jne     moverZorro

    cmp     byte[movimientoZorro],'A'
    je      moverIzq

    cmp     byte[movimientoZorro],'D'
    je      moverDer

    cmp     byte[movimientoZorro],'W'
    je      moverArriba

    cmp     byte[movimientoZorro],'S'
    je      moverAbajo

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
    jne     moverZorro

moverZorroAdyacenteIzq:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    inc     rbx
    mov     byte[tablero + rbx],' '

    dec     byte[columnaZorro]
    mov     byte[turnoZorro],0
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
    jne     moverZorro

moverZorroAdyacenteDer:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    dec     rbx
    mov     byte[tablero + rbx],' '

    inc     byte[columnaZorro]
    mov     byte[turnoZorro],0
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
    jne     moverZorro

moverZorroAdyacenteArr:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    add     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

    dec     byte[filaZorro]
    mov     byte[turnoZorro],0
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
    jne     moverZorro

moverZorroAdyacenteAbj:
    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    
    sub     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '
 
    inc     byte[filaZorro]
    mov     byte[turnoZorro],0
    jmp     loopPrincipal

cambiarFilaAbj:
    add     byte[filaZorro],2
    jmp     loopPrincipal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; MOVER OCAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moverOcas:

    mPuts   msgPedirPosicionOca
    mGets   posicionOca

    mov     rdi,posicionOca
    mov     rsi,formatoPosicionOca
    mov     rdx,filOca
    mov     rcx,colOca
    mSscanf

    cmp     rax,2
    jl      moverOcas

    xor     rdi,rdi
    mov     dil,[filOca]
    xor     rsi,rsi
    mov     sil,[colOca]
    mov     rdx,[longitudFila]
    mov     rcx,[longitudElem]
    sub     rsp,8
    call    calcularDesplazamiento
    add     rsp,8

    mov     rbx,rax
    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    ; je      verSiOcaPuedeMoverse
    je      pedirMovimientoOca

    mPuts   msgNoHayOca
    jmp     moverOcas

; verSiOcaPuedeMoverse:
;     sub     rsp,8
;     call    ocaPuedeMoverse
;     add     rsp,8

;     cmp     rax,1
;     je      pedirMovimientoOca

;     mPuts   msgOcaNoPuedeMoverse
;     jmp     moverOca

pedirMovimientoOca:
    mPuts   msgPedirMovimientoOca
    mGets   movimientoOca

    sub     rsp,8
    call    validarMovimientoOca
    add     rsp,8

    cmp     byte[RESULTMOVOCA],'S'
    jne     pedirMovimientoOca

    cmp     byte[movimientoOca],'A'
    jne     moverOcaDer
    cmp     byte[colOca],1
    je      pedirMovimientoOca
    dec     rbx
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    inc     rbx
    mov     byte[tablero + rbx],' '
    jmp     esTurnoZorro

moverOcaDer:
    cmp     byte[movimientoOca],'D'
    jne     moverOcaArr
    cmp     byte[colOca],7
    je      pedirMovimientoOca
    inc     rbx
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    dec     rbx
    mov     byte[tablero + rbx],' '
    jmp     esTurnoZorro

moverOcaArr:
    cmp     byte[movimientoOca],'W'
    jne     moverOcaAbj
    cmp     byte[filOca],1
    je      pedirMovimientoOca
    sub     rbx,[longitudFila]
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    add     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '
    jmp     esTurnoZorro

moverOcaAbj:
    cmp     byte[filOca],7
    je      pedirMovimientoOca
    add     rbx,[longitudFila]
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    sub     rbx,[longitudFila]
    mov     byte[tablero + rbx],' '

esTurnoZorro:
    mov     byte[turnoZorro],1
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

    cmp     byte[movimientoZorro],'Q'    ; Arriba-Izq
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'W'    ; Arriba
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'E'    ; Arriba-Der
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'A'    ; Izq
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'S'    ; Abajo
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'D'    ; Der
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'Z'    ; Abajo-Izq
    je      movimientoZorroValido
    cmp     byte[movimientoZorro],'V'    ; Abajo-Der
    je      movimientoZorroValido

    mov     byte[RESULTMOVZORRO],'N'

movimientoZorroValido:
    ret
; ********************************
validarOrientacion:
    mov     byte[RESULTORIENTACION],'S'

    cmp     byte[orientacionTablero],'N'    ; Sin orientación
    je      orientacionValida
    cmp     byte[orientacionTablero],'I'    ; Rotado 90° a Izq
    je      orientacionValida
    cmp     byte[orientacionTablero],'D'    ; Rotado 90° a Der
    je      orientacionValida
    cmp     byte[orientacionTablero],'V'    ; Rotado 180°
    je      orientacionValida

    mov     byte[RESULTORIENTACION],'N'
    
orientacionValida:
    ret
; ********************************
validarMovimientoOca:

    mov     byte[RESULTMOVOCA],'S'

    mov     al,[movimientoOca]

    cmp     al,[movOcaCostado1]
    je      movimientoOcaValido

    cmp     al,[movOcaAdelante]
    je      movimientoOcaValido
    
    cmp     al,[movOcaCostado2]
    je      movimientoOcaValido

    mov     byte[RESULTMOVOCA],'N'

movimientoOcaValido:
    ret
; ********************************


