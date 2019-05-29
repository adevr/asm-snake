;------------------------------------------------------------------------
;                                                                       |
;	TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES      |
;                                                                       |
;	ANO LECTIVO 2018/2019                                               |
;                                                                       |
;                                                                       |
;	José Oliveira - 21280913                                            |
;   Rui Ferreira - 21280922                                             |
;------------------------------------------------------------------------

.8086
.model	small
.stack	2048

dseg    segment para public 'data'

        titulo  dw 0526, 0524, 0522, 0520, 0518, 0516, 0514, 0512, 0672, 0832
                dw 0992, 1152, 1154, 1156, 1158, 1160, 1162, 1164, 1166, 1326
                dw 1486, 1646, 1806, 1804, 1802, 1800, 1798, 1796, 1794, 1792
                dw 1812, 1652, 1492, 1332, 1172, 1012, 0852, 0692, 0532, 0694
                dw 0856, 1016, 1178, 1180, 1342, 1502, 1664, 1826, 1666, 1506
                dw 1346, 1186, 1026, 0866, 0706, 0546, 1832, 1672, 1512, 1352
                dw 1192, 1032, 0872, 0712, 0552, 0554, 0556, 0558, 0560, 0562
                dw 0564, 0566, 0726, 0886, 1046, 1206, 1366, 1526, 1686, 1846
                dw 1194, 1196, 1198, 1200, 1202, 1204, 0572, 0732, 0892, 1052
                dw 1212, 1372, 1532, 1692, 1852, 1214, 1216, 1058, 1060, 0902
                dw 0744, 0586, 1378, 1380, 1542, 1704, 1866, 0606, 0604, 0602
                dw 0600, 0598, 0596, 0594, 0592, 0752, 0912, 1072, 1232, 1392
                dw 1552, 1712, 1872, 1874, 1876, 1878, 1880, 1882, 1884, 1886
                dw 1234, 1236, 1238, 1240, 1242

        texto1  db "DESENVOLVIDO POR$"
        texto2  db "ESCRITO EM LINGUAGEM ASSEMBLY 8086$"
        nomes   db "Jose Oliveira-21280913 / Rui Ferreira-21280922$"

        menu    db "1. NOVO - 2. HISTORICO - 3. ESTATISTICAS - 4. SAIR$"
        menu_velocidade    db "1-(Nivel1)  2-(Nivel2)  3-(Nivel3)  4-(Nivel4)$"

        menu_macav  db "Macas Verdes$"
        menu_macam  db "Macas Maduras$"
        menu_rato   db "Ratos$"

        menu_jogo1   db "Direita$"
        menu_jogo2   db "Esquerda$"
        menu_jogo3   db "Cima$"
        menu_jogo4   db "Baixo$"
        menu_jogo5   db "Voltar$"
        menu_esc     db "Esc$"

        texto_pm    db "Pontuacao Maxima:$"
        texto_p     db "Pontuacao:$"

        pontos_m db  6 dup ('0'),'$'
		pontos db  6 dup ('0'),'$'

        POSy    db 12	; a linha pode ir de [1..25]
		POSx    db 40	; a coluna pode ir de [1..80]
        POSya	db	5	; Posição anterior de y
		POSxa	db	10	; Posição anterior de x

		passa_t		dw	0
		passa_t_ant	dw	0
		direccao	db	3

        centesimos	dw 	0
		factor		db	100
		metade_factor	db	?
		resto		db	0

		ultimo_num_aleat dw 0

        POSyf	db	3	; Posição fruta de y
		POSxf	db	8	; Posição fruta de x

		fruta   dw  0   ; Contador de frutas
		rato    dw  0   ; Contador de ratos
		fruta_t dw  0   ; Temporizador colocar fruta
		rato_t  dw  0   ; Temporizador colocar ratos

dseg	ends

cseg	segment para public 'code'
        assume cs:cseg, ds:dseg

;------------------------------------------------------------------------
;   MACRO PARA POSICIONAR CURSOR NO ECRA                                |
;------------------------------------------------------------------------
goto_xy	macro POSx,POSy
		mov     ah,02h
		mov     bh,0		; numero da página
		mov     dl,POSx
		mov     dh,POSy
		int     10h
endm

;------------------------------------------------------------------------
;   ROTINA DE DELAY                                                     |
;------------------------------------------------------------------------
delay proc
	pushf
	push	ax
	push	cx
	push	dx
	push	si

	mov     ah,2Ch
	int     21h
	mov     al,100
	mul     dh
	xor     dh,dh
	add     ax,dx
	mov     si,ax

ciclo:
    mov	    ah,2Ch
	int	    21h
	mov	    al,100
	mul	    dh
	xor	    dh,dh
	add	    ax,dx

	cmp	    ax,si
	jnb	    naoajusta
	add	    ax,6000 ; 60 segundos

naoajusta:
	sub	    ax,si
	cmp	    ax,di
	jb	    ciclo

	pop	    si
	pop	    dx
	pop	    cx
	pop	    ax
	popf
	ret
delay endp

;------------------------------------------------------------------------
;   ROTINA PARA CONVERTER NUMEROS PARA STRING                           |
;------------------------------------------------------------------------
converte_num proc
        pushf
        push    cx
        push    dx
        push    di

        mov     di,6
        mov     cx,10

ciclo:
        xor     dx,dx
        div     cx
        add     dl,48
        mov     [bx+di],dl
        dec     di
        cmp     ax,0
        jne     ciclo

        pop     di
        pop     dx
        pop     cx
        popf
        ret
converte_num endp

;------------------------------------------------------------------------
;   ROTINA PARA APAGAR ECRA                                             |
;------------------------------------------------------------------------
limpa_ecran	proc
        pushf
        push    cx
        push    di

        mov     di,0
        mov     cx,25*80
limpa:
        mov     byte ptr es:[di],' '
        mov     byte ptr es:[di+1],00000111b
        add     di, 2
        loop    limpa

        pop     di
        pop     cx
        popf
        ret
limpa_ecran	endp

;------------------------------------------------------------------------
;   ROTINA PARA IMPRIMIR ECRA INICIAL                                   |
;------------------------------------------------------------------------
imprime_ecran proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx

		goto_xy	1,0         ; imprime canto superior esquerdo
		mov		ah, 02h
		mov		dl, 0C9h
		int		21H
        goto_xy	78,0        ; imprime canto superior direito
		mov		ah, 02h
		mov		dl, 0BBh
		int		21H
        goto_xy	1,24        ; imprime canto inferior esquerdo
		mov		ah, 02h
		mov		dl, 0C8h
		int		21H
        goto_xy	78,24       ; imprime canto inferior direito
		mov		ah, 02h
		mov		dl, 0BCh
		int		21H

        mov     cx, 76
        mov     bl, 2
imprime_horizontal:         ; imprime barra topo e base
        goto_xy	bl,0        ; imprime topo
		mov		ah, 02h
		mov		dl, 0CDh
		int		21H
        goto_xy	bl,24       ; imprime base
		mov		ah, 02h
		mov		dl, 0CDh
		int		21H
		inc     bl
		loop    imprime_horizontal

		mov     cx, 23
		mov     bl, 1
imprime_vertical:           ; imprime barra esquerda e direita
        goto_xy	1,bl        ; imprime esquerda
		mov		ah, 02h
		mov		dl, 0BAh
		int		21H
        goto_xy	78,bl       ; imprime direita
		mov		ah, 02h
		mov		dl, 0BAh
		int		21H
		inc     bl
		loop    imprime_vertical

		pop     dx
		pop     cx
        pop     bx
        pop     ax
        popf
        ret
imprime_ecran endp

;------------------------------------------------------------------------
;   ROTINA PARA IMPRIMIR ECRA DE JOGO                                   |
;------------------------------------------------------------------------
imprime_jogo proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si

		goto_xy	57,0         ; imprime separador do topo
		mov		ah, 02h
		mov		dl, 0CBh
		int		21H
        goto_xy	57,24        ; imprime separador da base
		mov		ah, 02h
		mov		dl, 0CAh
		int		21H

        mov     cx, 23
        mov     bl, 1
imprime_vertical:
        goto_xy	57,bl         ; imprime barra separadora
		mov		ah, 02h
		mov		dl, 0BAh
		int		21H
		inc     bl
		loop    imprime_vertical

		goto_xy	57,5          ; imprime separador da pontuacao esquerda
		mov		ah, 02h
		mov		dl, 0CCh
		int		21H
        goto_xy	78,5          ; imprime separador da pontuacao direita
		mov		ah, 02h
		mov		dl, 0B9h
		int		21H

        goto_xy	57,12          ; imprime separador da legenda esquerda
		mov		ah, 02h
		mov		dl, 0CCh
		int		21H
        goto_xy	78,12          ; imprime separador da legenda direita
		mov		ah, 02h
		mov		dl, 0B9h
		int		21H

        goto_xy	1,22          ; imprime separador da velocidade esquerda
		mov		ah, 02h
		mov		dl, 0CCh
		int		21H
        goto_xy	57,22          ; imprime separador da velocidade direita
		mov		ah, 02h
		mov		dl, 0B9h
		int		21H

        mov     cx, 20
        mov     bl, 58
imprime_horizontal1:
        goto_xy	bl,5          ; imprime barra separadora pontuacao
		mov		ah, 02h
		mov		dl, 0CDh
		int		21H
		inc     bl
		loop    imprime_horizontal1

        mov     cx, 20
        mov     bl, 58
imprime_horizontal2:
        goto_xy	bl,12          ; imprime barra separadora legenda
		mov		ah, 02h
		mov		dl, 0CDh
		int		21H
		inc     bl
		loop    imprime_horizontal2

        mov     cx, 55
        mov     bl, 2
imprime_horizontal3:
        goto_xy	bl,22          ; imprime barra separadora velocidade
		mov		ah, 02h
		mov		dl, 0CDh
		int		21H
		inc     bl
		loop    imprime_horizontal3

        goto_xy	59,1           ; imprime legenda pontuacao maxima
        lea     dx,texto_pm
        mov     ah,09h
        int     21h
        goto_xy	59,3           ; imprime legenda pontuacao
        lea     dx,texto_p
        mov     ah,09h
        int     21h

        goto_xy	59,6            ; imprime legenda de jogo maca verde
        mov		ah, 09h
        mov     bl, 00000010b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0BEh
        int		21h
        goto_xy	61,6
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,6
        lea     dx,menu_macav
        mov     ah,09h
        int     21h

        goto_xy	59,8            ; imprime legenda de jogo maca madura
        mov		ah, 09h
        mov     bl, 00000100b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0BDh
        int		21h
        goto_xy	61,8
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,8
        lea     dx,menu_macam
        mov     ah,09h
        int     21h

        goto_xy	59,10            ; imprime legenda de jogo rato
        mov		ah, 09h
        mov     bl, 00001000b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0CFh
        int		21h
        goto_xy	61,10
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,10
        lea     dx,menu_rato
        mov     ah,09h
        int     21h

        goto_xy	59,13            ; imprime legenda de jogo direcoes direita
        mov		ah, 02h
        mov		dl, 010h
        int		21h
        goto_xy	61,13
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,13
        lea     dx,menu_jogo1
        mov     ah,09h
        int     21h

        goto_xy	59,15            ; imprime legenda de jogo direcoes esquerda
        mov		ah, 02h
        mov		dl, 011h
        int		21h
        goto_xy	61,15
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,15
        lea     dx,menu_jogo2
        mov     ah,09h
        int     21h

        goto_xy	59,17            ; imprime legenda de jogo direcoes cima
        mov		ah, 02h
        mov		dl, 01Eh
        int		21h
        goto_xy	61,17
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,17
        lea     dx,menu_jogo3
        mov     ah,09h
        int     21h

        goto_xy	59,19            ; imprime legenda de jogo direcoes baixo
        mov		ah, 02h
        mov		dl, 01Fh
        int		21h
        goto_xy	61,19
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	63,19
        lea     dx,menu_jogo4
        mov     ah,09h
        int     21h

        goto_xy	59,22            ; imprime legenda de jogo direcoes voltar
        lea     dx,menu_esc
        mov     ah,09h
        int     21h
        goto_xy	63,22
        mov		ah, 02h
        mov		dl, '-'
        int		21h
        goto_xy	65,22
        lea     dx,menu_jogo5
        mov     ah,09h
        int     21h

        goto_xy	6,23             ; imprime legenda de velocidades de jogo
        lea     dx,menu_velocidade
        mov     ah,09h
        int     21h

        pop     si
		pop     dx
		pop     cx
        pop     bx
        pop     ax
        popf
        ret
imprime_jogo endp

;------------------------------------------------------------------------
;   ROTINA PARA IMPRIMIR TITULO                                         |
;------------------------------------------------------------------------
imprime_titulo	proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        xor     si,si
        mov	    cx,135
escreve_titulo:
        mov     bx,titulo[si]
        ;mov     byte ptr es:[bx],' '
        mov     byte ptr es:[bx+1],01000111b
        add     si,2
        mov	    di,1 		;delay de 1 centesimo de segundo
		;call	delay
        loop    escreve_titulo

        goto_xy	32,19
        lea     dx,texto1
        mov     ah,09h
        int     21h

        goto_xy	17,20
        lea     dx,nomes
        mov     ah,09h
        int     21h

        goto_xy	23,22
        lea     dx,texto2
        mov     ah,09h
        int     21h

        goto_xy	15,14
        lea     dx,menu
        mov     ah,09h
        int     21h

        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
imprime_titulo	endp

;------------------------------------------------------------------------
;   ROTINA PARA LER TECLADO                                             |
;------------------------------------------------------------------------
le_tecla    proc
		mov	    ah, 0Bh
		int 	21h
		cmp 	al, 0
		jne     com_tecla
		mov	    ah, 0
		mov	    al, 0
		jmp	    sai_tecla

com_tecla:
		mov	    ah, 08h
		int	    21h
		mov	    ah, 0
		cmp	    al, 0
		jne	    sai_tecla
		mov	    ah, 08h
		int	    21H
		mov	    ah, 1

sai_tecla:

        ret
le_tecla	endp

;------------------------------------------------------------------------
;   ROTINA PARA CALCULAR ALEATORIOS                                     |
;------------------------------------------------------------------------
calc_aleat proc near
        sub	    sp,2
        push	bp
        mov	    bp,sp
        push	ax
        push	cx
        push	dx

        mov	    ax,[bp+4]
        mov	    [bp+2],ax

        mov	    ah,00h
        int	    1Ah

        add	    dx,ultimo_num_aleat	    ; vai buscar o aleatório anterior
        add	    cx,dx
        mov	    ax,65521
        push	dx
        mul	    cx
        pop	    dx
        xchg	dl,dh
        add	    dx,32749
        add	    dx,ax

        mov	    ultimo_num_aleat,dx	    ; guarda o novo numero aleatório

        mov	    [BP+4],dx		        ; o aleatório é passado por pilha

        pop	    dx
        pop	    cx
        pop	    ax
        pop	    bp
        ret
calc_aleat endp

;------------------------------------------------------------------------
;   ROTINA PARA MOVIMENTAR A SNAKE                                      |
;------------------------------------------------------------------------
passa_tempo proc
		mov     ah, 2Ch             ; Buscar a hora
		int     21h

 		xor     ax,ax
		mov     al, dl              ; centesimos de segundo para ax
		mov     centesimos, ax

		mov     bl, factor		    ; define velocidade da snake (100; 50; 33; 25; 20; 10)
		div     bl
		mov     resto, ah
		mov     al, factor
		mov     ah, 0
		mov     bl, 2
		div     bl
		mov     metade_factor, al
		mov     al, resto
		mov     ah, 0
		mov     bl, metade_factor	; deve ficar sempre com metade do valor inicial
		mov     ah, 0
		cmp     ax, bx
		jbe     menor
		mov     ax, 1
		mov     passa_t, ax
		jmp     fim_passa

menor:
        mov     ax,0
		mov     passa_t, ax

fim_passa:

 		ret
passa_tempo   endp

;------------------------------------------------------------------------
;   ROTINA PARA COLOCAR OBJETOS NO ECRA                                 |
;------------------------------------------------------------------------
alimento proc

        goto_xy 5,5
        call	calc_aleat
        pop	    ax

	mov     di,6
	mov     cx,10

ciclo:
    xor     dx,dx
	div     cx
	add     dl,48
	mov     pontos[di-1],dl
	dec     di
	cmp     di,0
	;cmp     ax,0
	jne     ciclo

	lea     dx,pontos
	mov     ah,09h
	int     21h

posicao_x:
        call	calc_aleat	; Calcula próximo aleatório que é colocado na pilha
        pop	    ax

        cmp     al,2
        jbe     posicao_x
        cmp     al,56
        jae     posicao_x
        mov     POSxf,al

posicao_y:
        call	calc_aleat	; Calcula próximo aleatório que é colocado na pinha
        pop	    ax

        cmp     ah,1
        jbe     posicao_x
        cmp     ah,21
        jae     posicao_x
        mov     POSyf,ah

        call	calc_aleat	; Calcula próximo aleatório que é colocado na pinha
        pop	    ax
        and     ax,00000001

        jp      maca_madura
        jnp     maca_verde

maca_verde:
        goto_xy POSxf,POSyf
        mov		ah, 09h
        mov     bl, 00000010b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0BEh
        int		21h
        jmp     fim_fruta

maca_madura:
        goto_xy POSxf,POSyf
        mov		ah, 09h
        mov     bl, 00000100b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0BDh
        int		21h
        jmp     fim_fruta

fim_fruta:

        ret
alimento endp

;------------------------------------------------------------------------
;   ROTINA PARA ORIENTAR A SNAKE                                        |
;------------------------------------------------------------------------
move_snake proc

ciclo:
        call    alimento

		goto_xy POSx,POSy	; Vai para nova posição
		mov 	ah, 08h	    ; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h
		cmp 	al, 0CDh	; na posição do Cursor
		je		fim
        cmp 	al, 0CCh	; na posição do Cursor
		je		fim
		cmp 	al, 0BAh	; na posição do Cursor
		je		fim

		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, ' ' 	; Coloca ESPAÇO
		int		21h

		inc		POSxa
		goto_xy	POSxa,POSya
		mov		ah, 02h
		mov		dl, ' '		;  Coloca ESPAÇO
		int		21h
		dec 	POSxa

		goto_xy	POSx,POSy	; Vai para posição do cursor

imprime:
        mov		ah, 02h
		mov		dl, 02h	    ; Coloca AVATAR
		int		21h

		goto_xy	POSx,POSy	; Vai para posição do cursor

		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al

ler_seta:
        call 	le_tecla
		cmp		ah, 1
		je		estend
		cmp 	al, 27	    ; Verifica se tecla Esc pressionada
		je		fim
		cmp		al, '1'
		jne		teste_2
		mov		factor, 100

teste_2:
        cmp		al, '2'
		jne		teste_3
		mov		factor, 50

teste_3:
        cmp		al, '3'
		jne		teste_4
		mov		factor, 25

teste_4:
        cmp		al, '4'
		jne		teste_end
		mov		factor, 10

teste_end:
		call	passa_tempo
		mov		ax, passa_t_ant
		cmp		ax, passa_t
		je		ler_seta
		mov		ax, passa_t
		mov		passa_t_ant, ax

verifica_0:
        mov		al, direccao        ; Move snake para direita
		cmp 	al, 0
		jne		verifica_1
		inc		POSx
		jmp		ciclo

verifica_1:
        mov 	al, direccao        ; Move snake para cima
		cmp		al, 1
		jne		verifica_2
		dec		POSy
		jmp		ciclo

verifica_2:
        mov 	al, direccao        ; Move snake para esquerda
		cmp		al, 2
		jne		verifica_3
		dec		POSx
		jmp		ciclo

verifica_3:
        mov 	al, direccao        ; Move snake para baixo
		cmp		al, 3
		jne		ciclo
		inc		POSy
		jmp		ciclo

estend:
        cmp 	al,48h
		jne		baixo
		mov		direccao, 1
		jmp		ciclo

baixo:
        cmp		al,50h
		jne		esquerda
		mov		direccao, 3
		jmp		ciclo

esquerda:
		cmp		al,4Bh
		jne		direita
		mov		direccao, 2
		jmp		ciclo

direita:
		cmp		al,4Dh
		jne		ler_seta
		mov		direccao, 0
		jmp		ciclo

fim:
        goto_xy	40,23
		ret

move_snake endp

;------------------------------------------------------------------------
;   MAIN                                                                |
;------------------------------------------------------------------------
main	proc
        mov     ax, dseg
        mov     ds, ax
        mov     ax, 0b800h
        mov     es, ax      ; Segmento de memoria video

        mov     ch, 32      ; Esconder cursor
        mov     ah, 1
        int     10h

menu_principal:
        call    limpa_ecran
        call    imprime_ecran
        call    imprime_titulo

ler_menu:
        call 	le_tecla
		cmp 	al, 34h     ; Verifica se foi a tecla 4 pressinada
		je		fim         ; Salta para fim e sai do programa

		cmp     al, 31h     ; Verifica se foi a tecla 4 pressinada
		je      novo_jogo   ; Salta para novo jogo

		jmp		ler_menu

novo_jogo:
		call    limpa_ecran
        call    imprime_ecran
        call    imprime_jogo
        call    move_snake

ler_voltar:
        call 	le_tecla
        cmp     al, 01Bh        ; Verifica se foi a tecla ESC pressinada
        je      menu_principal  ; Salta para o menu anterior

        jmp		ler_voltar

fim:
        goto_xy 79,24       ; Salta para fim do ecra
        mov     ch, 6       ; Mostrar cursor
        mov     cl, 7
        mov     ah, 1
        int     10h

        mov     al, 0
        mov     ah, 4ch
        int     21h

main	endp
cseg	ends

end	main
