global main

extern cargarMatriz
extern reemplazarIconos
extern imprimirTablero
extern calcularDesplazamiento

%include 'macros.asm'

; %1 -> ΔD (cambio en el desplazamiento)
; %2 -> columna a chequear (-1 si no se debe chequear)
; %3 -> fila a chequear (-1 si no se debe chequear)
; %4 -> SIG columna a chequear (-1 si no se debe chequear)
; %5 -> SIG fila a chequear (-1 si no se debe chequear)
; %6 -> dirección campo de memoria (64 bits) del contador de movimiento a incrementar
%macro mCargarParametrosMovimientoZorro 6
    mov     r8,%1
    mov     r9,%2
    mov     r10,%3
    mov     r11,%4
    mov     r12,%5
    mov     r13,%6
%endmacro

%macro mMostrarEstadisticas 2
    mov     rdi,msgEstadisticas
    mov     rsi,%1
    mov     rdx,%2
    mPrintf
%endmacro

section .data
    tablero         db '-','-','O','O','O','-','-'
                    db '-','-','O','O','O','-','-'
                    db 'O','O','O','O','O','O','O'
                    db 'O',' ',' ',' ',' ',' ','O'
                    db 'O',' ',' ','X',' ',' ','O'
                    db '-','-',' ',' ',' ','-','-'
                    db '-','-',' ',' ',' ','-','-'

    desplazamientoZorro     dq 31

    movimientosOca  times 0 db ' '
    movOcaCostado1          db 'A'
    movOcaAdelante          db 'S'
    movOcaCostado2          db 'D'

    turnoZorro              db 1

    ocasComidas             db 0

    cantMovZorroIzq         dq 0
    cantMovZorroDer         dq 0
    cantMovZorroArr         dq 0
    cantMovZorroAbj         dq 0
    cantMovZorroArrIzq      dq 0
    cantMovZorroArrDer      dq 0
    cantMovZorroAbjIzq      dq 0
    cantMovZorroAbjDer      dq 0

;   Constantes
    LONGITUD_ELEM           equ 1
    LONGITUD_FILA           equ 7
    DESPLAZ_IZQ             equ -1      ; = -LONGITUD_ELEM
    DESPLAZ_DER             equ 1       ; = +LONGITUD_ELEM
    DESPLAZ_ARR             equ -7      ; = -LONGITUD_FILA
    DESPLAZ_ABJ             equ 7       ; = +LONGITUD_FILA
    DESPLAZ_ARR_IZQ         equ -8      ; = -LONGITUD_FILA - LONGITUD_ELEM
    DESPLAZ_ARR_DER         equ -6      ; = -LONGITUD_FILA + LONGITUD_ELEM
    DESPLAZ_ABJ_IZQ         equ 6       ; = +LONGITUD_FILA - LONGITUD_ELEM
    DESPLAZ_ABJ_DER         equ 8       ; = +LONGITUD_FILA + LONGITUD_ELEM
    COL_MIN                 equ 1
    FIL_MIN                 equ 1
    COL_MAX                 equ 7
    FIL_MAX                 equ 7
    SIG_COL_MIN             equ 2
    SIG_FIL_MIN             equ 2
    SIG_COL_MAX             equ 6
    SIG_FIL_MAX             equ 6
    NO_CHEQUEAR             equ -1
    OBJETIVO_OCAS           equ 12
    ES_TURNO_ZORRO          equ 1
    ES_TURNO_OCAS           equ 0

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
    msgEstadisticas         db 'Cantidad de movimientos en la dirección <%s> = %li',10,0
    msgIzq                  db 'Izquierda',0
    msgDer                  db 'Derecha',0
    msgArr                  db 'Arriba',0
    msgAbj                  db 'Abajo',0
    msgArrIzq               db 'Arriba-Izquierda',0
    msgArrDer               db 'Arriba-Derecha',0
    msgAbjIzq               db 'Abajo-Izquierda',0
    msgAbjDer               db 'Abajo-Derecha',0
    msgInterrupcionPartida  db 'Se ha interrumpido la partida!',0

section .bss
    orientacionTablero      resb 10
    iconoZorro              resb 10
    iconoOca                resb 10
    movimientoZorro         resb 10
    movimientoOca           resb 10
    posicionOca             resb 10
    
    filOca                  resb 1
    colOca                  resb 1
    
    RESULTMOVZORRO          resb 1
    RESULTMOVOCA            resb 1
    RESULTORIENTACION       resb 1
    
section .text
main:

pedirOrientacion:
    mov     rdi,msgElegirOrientacion
    mPrintf
    mGets   orientacionTablero

    cmp     byte[orientacionTablero],'q'
    je      interrupcionDePartida

    sub     rsp,8
    call    validarOrientacion
    add     rsp,8

    cmp     byte[RESULTORIENTACION],'S'
    jne     pedirOrientacion

pedirIconoZorro:
    mov     rdi,msgElegirIconoZorro
    mPrintf
    mGets   iconoZorro

    cmp     byte[iconoZorro],'q'
    je      interrupcionDePartida

pedirIconoOca:
    mov     rdi,msgElegiriconoOca
    mPrintf
    mGets   iconoOca

    cmp     byte[iconoOca],'q'
    je      interrupcionDePartida

    mov     rdi,tablero
    xor     rsi,rsi
    mov     sil,[orientacionTablero]
    mov     rdx,movimientosOca
    mov     rcx,desplazamientoZorro
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

    cmp     byte[ocasComidas],OBJETIVO_OCAS
    je      ganoZorro

    ; sub     rsp,8
    ; call    zorroPuedeMoverse
    ; add     rsp,8

    ; cmp     rax,0
    ; je      ganaronOcas

    cmp     byte[turnoZorro],ES_TURNO_ZORRO
    je      pedirMovimientoZorro

    jmp     moverOcas

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER ZORRO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pedirMovimientoZorro:
    mPuts   msgMovimientoZorro
    mGets   movimientoZorro

    cmp     byte[movimientoZorro],'q'
    je      interrupcionDePartida

    sub     rsp,8
    call    validarMovimientoZorro
    add     rsp,8

    cmp     byte[RESULTMOVZORRO],'S'
    jne     pedirMovimientoZorro

    cmp     byte[movimientoZorro],'A'
    jne     verSiEsMovDer
    mCargarParametrosMovimientoZorro DESPLAZ_IZQ,COL_MIN,NO_CHEQUEAR,SIG_COL_MIN,NO_CHEQUEAR,cantMovZorroIzq
    jmp     moverZorro

verSiEsMovDer:
    cmp     byte[movimientoZorro],'D'
    jne     verSiEsMovArr
    mCargarParametrosMovimientoZorro DESPLAZ_DER,COL_MAX,NO_CHEQUEAR,SIG_COL_MAX,NO_CHEQUEAR,cantMovZorroDer
    jmp     moverZorro

verSiEsMovArr:
    cmp     byte[movimientoZorro],'W'
    jne     verSiEsMovAbj
    mCargarParametrosMovimientoZorro DESPLAZ_ARR,NO_CHEQUEAR,FIL_MIN,NO_CHEQUEAR,SIG_FIL_MIN,cantMovZorroArr
    jmp     moverZorro

verSiEsMovAbj:
    cmp     byte[movimientoZorro],'S'
    jne     verSiEsMovArrIzq
    mCargarParametrosMovimientoZorro DESPLAZ_ABJ,NO_CHEQUEAR,FIL_MAX,NO_CHEQUEAR,SIG_FIL_MAX,cantMovZorroAbj
    jmp     moverZorro

verSiEsMovArrIzq:
    cmp     byte[movimientoZorro],'Q'
    jne     verSiEsMovArrDer
    mCargarParametrosMovimientoZorro DESPLAZ_ARR_IZQ,COL_MIN,FIL_MIN,SIG_COL_MIN,SIG_FIL_MIN,cantMovZorroArrIzq
    jmp     moverZorro 

verSiEsMovArrDer:
    cmp     byte[movimientoZorro],'E'
    jne     verSiEsMovAbjIzq
    mCargarParametrosMovimientoZorro DESPLAZ_ARR_DER,COL_MAX,FIL_MIN,SIG_COL_MAX,SIG_FIL_MIN,cantMovZorroArrDer
    jmp     moverZorro

verSiEsMovAbjIzq:
    cmp     byte[movimientoZorro],'Z'
    jne     esMovAbjDer
    mCargarParametrosMovimientoZorro DESPLAZ_ABJ_IZQ,COL_MIN,FIL_MAX,SIG_COL_MIN,SIG_FIL_MAX,cantMovZorroAbjIzq
    jmp     moverZorro

esMovAbjDer:
    mCargarParametrosMovimientoZorro DESPLAZ_ABJ_DER,COL_MAX,FIL_MAX,SIG_COL_MAX,SIG_FIL_MAX,cantMovZorroAbjDer

moverZorro:
    mov     rbx,[desplazamientoZorro]

;   Recuperar posición del zorro
    xor     rdx,rdx                 ; (rdx) = 0
    mov     rax,rbx                 ; (rax) = desplazamiento del zorro en el tablero
    mov     r15,LONGITUD_FILA
    idiv    r15                     ; (rdx:rax) / op -> (rdx) = resto, (rax) = cociente
    inc     rdx                     ; (rdx) = columna zorro = resto + 1
    inc     rax                     ; (rax) = fila zorro = cociente + 1

;   Ver si el zorro está en un borde del tablero peligroso para el movimiento en cuestión
;   Si lo está, se pide otro movimiento
    cmp     rdx,r9
    je      pedirMovimientoZorro
    cmp     rax,r10
    je      pedirMovimientoZorro
        
    add     rbx,r8

;   Omitir caso en el que se quiera comer a una oca que está en el borde del tablero
;   En ese caso, directamente se compara con un vacío
    cmp     rdx,r11
    je      compararVacio
    cmp     rax,r12
    je      compararVacio

;   Ver si en la posición adyacente en la dirección indicada hay una oca
    mov     al,byte[tablero + rbx]
    cmp     al,[iconoOca]
    jne     compararVacio

;   Si la hay, ver si la posición adyacente a la oca en esa misma dirección está vacía
    add     rbx,r8
    cmp     byte[tablero + rbx],' '

;   Si no lo está se pedirá un nuevo movimiento
    jne     pedirMovimientoZorro

;   Si lo está, se modifica el desplazamiento del zorro y se come a la oca, incrementando la cantidad de ocas comidas
    mov     [desplazamientoZorro],rbx

    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    sub     rbx,r8
    mov     byte[tablero + rbx],' '
    sub     rbx,r8
    mov     byte[tablero + rbx],' '
    inc     byte[ocasComidas]
    inc     qword[r13]

;   Como el zorro ha comido una oca, sigue siendo su turno
    jmp     loopPrincipal

compararVacio:
;   Si no había una oca, se verifica si la posición está libre. Si no lo está se pedirá un nuevo movimiento
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoZorro

;   Si lo está, se modifica el desplazamiento del zorro y se mueve a la posición adyacente en la dirección indicada
    mov     [desplazamientoZorro],rbx

    mov     al,[iconoZorro]
    mov     byte[tablero + rbx],al
    sub     rbx,r8
    mov     byte[tablero + rbx],' '
    inc     qword[r13]

;   Deja de ser el turno del zorro. Ahora es el turno de las ocas
    mov     byte[turnoZorro],ES_TURNO_OCAS
    jmp     loopPrincipal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MOVER OCAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moverOcas:

    mPuts   msgPedirPosicionOca
    mGets   posicionOca

    cmp     byte[posicionOca],'q'
    je      interrupcionDePartida

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
    mov     rdx,LONGITUD_FILA
    mov     rcx,LONGITUD_ELEM
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

    cmp     byte[movimientoOca],'q'
    je      interrupcionDePartida

    sub     rsp,8
    call    validarMovimientoOca
    add     rsp,8

    cmp     byte[RESULTMOVOCA],'S'
    jne     pedirMovimientoOca

    cmp     byte[movimientoOca],'A'
    jne     moverOcaDer
    cmp     byte[colOca],COL_MIN
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
    cmp     byte[colOca],COL_MAX
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
    cmp     byte[filOca],FIL_MIN
    je      pedirMovimientoOca
    sub     rbx,LONGITUD_FILA
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    add     rbx,LONGITUD_FILA
    mov     byte[tablero + rbx],' '
    jmp     esTurnoZorro

moverOcaAbj:
    cmp     byte[filOca],FIL_MAX
    je      pedirMovimientoOca
    add     rbx,LONGITUD_FILA
    cmp     byte[tablero + rbx],' '
    jne     pedirMovimientoOca
    mov     al,[iconoOca]
    mov     [tablero + rbx],al
    sub     rbx,LONGITUD_FILA
    mov     byte[tablero + rbx],' '

esTurnoZorro:
    mov     byte[turnoZorro],ES_TURNO_ZORRO
    jmp     loopPrincipal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ganoZorro:
    mPuts   msgHaGanadoElZorro
    jmp     mostrarEstadisticas

ganaronOcas:
    mPuts   msgHanGanadoLasOcas

mostrarEstadisticas:
    mMostrarEstadisticas    msgIzq, qword[cantMovZorroIzq]
    mMostrarEstadisticas    msgDer, qword[cantMovZorroDer]
    mMostrarEstadisticas    msgArr, qword[cantMovZorroArr]
    mMostrarEstadisticas    msgAbj, qword[cantMovZorroAbj]
    mMostrarEstadisticas    msgArrIzq, qword[cantMovZorroArrIzq]
    mMostrarEstadisticas    msgArrDer, qword[cantMovZorroArrDer]
    mMostrarEstadisticas    msgAbjIzq, qword[cantMovZorroAbjIzq]
    mMostrarEstadisticas    msgAbjDer, qword[cantMovZorroAbjDer]
    jmp     fin

interrupcionDePartida:
    mPuts   msgInterrupcionPartida

fin:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RUTINAS INTERNAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
    cmp     byte[movimientoZorro],'C'    ; Abajo-Der
    je      movimientoZorroValido

    mov     byte[RESULTMOVZORRO],'N'

movimientoZorroValido:
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
