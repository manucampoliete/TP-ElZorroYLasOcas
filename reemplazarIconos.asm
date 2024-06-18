global reemplazarIconos

section .text

section .bss

section .text
;rdi: dirección del tablero
;sil: nuevo ícono para el zorro
;dl: nuevo ícono para las ocas
reemplazarIconos:
    mov     rcx,49

reemplazarIcono:
    cmp     byte[rdi],'X'
    jne     verSiHayOca
    mov     byte[rdi],sil
    jmp     avanzarSig

verSiHayOca:
    cmp     byte[rdi],'O'
    jne     avanzarSig
    mov     byte[rdi],dl

avanzarSig:
    inc     rdi
    loop    reemplazarIcono

    ret