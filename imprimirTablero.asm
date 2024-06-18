global imprimirTablero

extern puts

section .data
    filaInc             db '    | | | |    ',0
    filaComp            db '| | | | | | | |',0
 
section .bss
    dirTablero          resq 1
    dirFila             resq 1
    esComp              resb 1
    contador            resq 1

section .text
;rdi: dirección de inicio del tablero de 7x7. Al imprimir se omiten las 4 celdas de las 4 esquinas.
;    | | | |    
;    | | | |    
;| | | | | | | |
;| | | | | | | |
;| | | | | | | |
;    | | | |    
;    | | | |    
imprimirTablero:
    mov     [dirTablero],rdi
    mov     qword[contador],1

nuevaFila:
    cmp     qword[contador],8
    je      finImprimir
    cmp     qword[contador],2
    jle     esFilaIncompleta
    cmp     qword[contador],6
    jge     esFilaIncompleta

    mov     byte[esComp],'S'
    mov     qword[dirFila],filaComp

    jmp     llenarAndImprimirFila

esFilaIncompleta:
    mov     byte[esComp],'N'
    mov     qword[dirFila],filaInc

llenarAndImprimirFila:
    sub     rsp,8
    call    llenarFila
    add     rsp,8

    mov     rdi,[dirFila]
    sub     rsp,8
    call    puts
    add     rsp,8

    add     qword[dirTablero],7
    inc     qword[contador]
    jmp     nuevaFila

finImprimir:
    ret
; ******************************
; RUTINAS INTERNAS
; ******************************
llenarFila:
    cmp     byte[esComp],'S'
    je      configurarParaFilaCompleta

    mov     rcx,3
    mov     rsi,[dirTablero]
    add     rsi,2
    lea     rdi,[filaInc + 5]

    jmp     llenarCelda

configurarParaFilaCompleta:
    mov     rcx,7
    mov     rsi,[dirTablero]
    lea     rdi,[filaComp + 1]

llenarCelda:

    mov     al,[rsi]
    mov     [rdi],al

    inc     rsi
    add     rdi,2

    loop    llenarCelda

    ret
; ******************************