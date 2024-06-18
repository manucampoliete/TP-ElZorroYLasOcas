global cargarMatriz

section .data
    tableroRotadoIzq    db '-','-','O','O','O','-','-'
                        db '-','-','O',' ',' ','-','-'
                        db 'O','O','O',' ',' ',' ',' '
                        db 'O','O','O',' ','X',' ',' '
                        db 'O','O','O',' ',' ',' ',' '
                        db '-','-','O',' ',' ','-','-'
                        db '-','-','O','O','O','-','-'

    tableroRotadoDer    db '-','-','O','O','O','-','-'
                        db '-','-',' ',' ','O','-','-'
                        db ' ',' ',' ',' ','O','O','O'
                        db ' ',' ','X',' ','O','O','O'
                        db ' ',' ',' ',' ','O','O','O'
                        db '-','-',' ',' ','O','-','-'
                        db '-','-','O','O','O','-','-'

    tableroDadoVuelta   db '-','-',' ',' ',' ','-','-'
                        db '-','-',' ',' ',' ','-','-'
                        db 'O',' ',' ','X',' ',' ','O'
                        db 'O',' ',' ',' ',' ',' ','O'
                        db 'O','O','O','O','O','O','O'
                        db '-','-','O','O','O','-','-'
                        db '-','-','O','O','O','-','-'

section .bss
    dirNuevoTablero     resq 1

section .text
;rdi: dirección efectiva del tablero
;sil: 'N', no se modifica la orientación del tablero, pues ya está cargada la orientación por default
;     'I', sobreescribe la orientación por default, cargando el tablero rotado 90° a Izq
;     'D', sobreescribe la orientación por default, cargando el tablero rotado 90° a Der
;     'V', sobreescribe la orientación por default, cargando el tablero dado vuelta (rotado 180°)
;rdx: dirección de la fila del zorro (campo de 64 bits)
;rcx: dirección de la columna del zorro (campo de 64 bits)
cargarMatriz:

    cmp     sil,78 ; 78[10] = Ascii('N')
    je      finCarga

    cmp     sil,73 ; ; 73[10] = Ascii('I')
    jne     verSiEsRotacionDerecha
    mov     qword[dirNuevoTablero],tableroRotadoIzq
    mov     qword[rdx],4
    mov     qword[rcx],5
    jmp     efectuarCarga

verSiEsRotacionDerecha:
    cmp     sil,68 ; 68[10] = Ascii('D')
    jne     verSiEsRotacionCompleta
    mov     qword[dirNuevoTablero],tableroRotadoDer
    mov     qword[rdx],4
    mov     qword[rcx],3
    jmp     efectuarCarga

verSiEsRotacionCompleta:
    cmp     sil,86 ; 86[10] = Ascii('V')
    jne     finCarga
    mov     qword[dirNuevoTablero],tableroDadoVuelta
    mov     qword[rdx],3
    mov     qword[rcx],4

efectuarCarga:
    mov     rsi,[dirNuevoTablero]
    mov     rcx,49
    rep movsb

finCarga:
    ret