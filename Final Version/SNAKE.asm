;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2018/2019
;
;
;   Alexandre Reis 21280926
;   Celso Jordão  21130067
;
;		press ESC to exit
;------------------------------------------------------------------------

.8086
.model	small
.stack	2048

dseg    segment para public 'data'

        game_name db "SNAKE GAME$"
        texto1  db "Trabalho efetuado por$"
        nomes   db "Alexandre Reis-21280926 & Celso Jordao-21130067$"

        menu_principal1     db "[ 1 ] NOVO JOGO$"
        menu_principal2     db "[ 2 ] HISTORICO DE JOGOS$"
        menu_principal3     db "[ 3 ] VALORES ESTATISTICOS$"
        menu_principal4     db "[ X ] SAIR DO JOGO$"

        menu_velocidade    db "1-(NIVEL 1)  2-(NIVEL 2)  3-(NIVEL 3)  4-(NIVEL 4)$"
        menu    db 0

        name_macav  db "MACAS VERDE$"
        name_macam  db "MACA VERMELHA$"
        name_rato   db "RATO$"

        game_right   db "DIREITA$"
        game_left   db "ESQUERDA$"
        game_up   db "CIMA$"
        game_down   db "BAIXO$"
        game_esc   db "ESC - MENU$"

        name_points     db "PONTUACAO:$"

        print_points    db  6 dup ('0'),'$'
        print_maca_v     db  3 dup ('0'),'$'
        print_maca_m     db  3 dup ('0'),'$'
        print_rato      db  3 dup ('0'),'$'
        digit       dw  0

        POSy    db  1218 dup (0)
        POSx    db  1218 dup (0)

        corpo dw  1

        passa_t		dw	0
        passa_t_ant	dw	0
        direccao	db	3

        segundos    db  0

        centesimos	dw 	0
        factor		db	100
        metade_factor	db	?
        resto		db	0

        ultimo_num_aleat dw 0
        nivel   dw  0

        POSyf	db	3	; Posição fruta de y
        POSxf	db	8	; Posição fruta de x
        POSyr	db	15	; Posição temporaria rato de y
        POSxr	db	10	; Posição temporaria rato de x

        fruta   db  0   ; Contador de frutas
        ratos   db  0   ; Contador de ratos
        fruta_t dw  5   ; Temporizador colocar fruta
        rato_t  dw  0   ; Temporizador colocar ratos

        pontos      dw  0   ; Pontuaca atual
        macav       dw  0   ; Numero macas verdes comidas
        macam       dw  0   ; Numero macas maduras comidas
        rato        dw  0   ; Numero ratos comidos

        fname	db	'pontos.bin',0
        fhandle dw	0
        buffer  db	6 dup ('0'),13,10

        msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
        msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
        msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"

dseg	ends

cseg	segment para public 'code'
        assume cs:cseg, ds:dseg

;*****************************************
;   CURSOR NO ECRA                       *
;*****************************************
goto_xy	macro POSx,POSy
		mov     ah,02h
		mov     bh,0		; numero da página
		mov     dl,POSx
		mov     dh,POSy
		int     10h
endm

;******************************
;   ROTINA PARA TER DELAY     *
;******************************
DELAY proc
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

CICLO:
        mov	    ah,2Ch
        int	    21h
        mov	    al,100
        mul	    dh
        xor	    dh,dh
        add	    ax,dx

        cmp	    ax,si
        jnb	    NOTJUST
        add	    ax,6000 ; 60 segundos

NOTJUST:
        sub	    ax,si
        cmp	    ax,di
        jb	    CICLO

        pop	    si
        pop	    dx
        pop	    cx
        pop	    ax
        popf
        ret
DELAY endp

;------------------------------------------------------------------------
;   ROTINA PARA CONVERTER NUMEROS PARA STRING                           |
;------------------------------------------------------------------------
NUM_CONVERSION proc
        pushf
        push    cx
        push    dx
        push    di

        mov     di,digit
        mov     cx,10

CICLO:
        xor     dx,dx
        div     cx
        add     dl,48
        mov     [bx+di],dl
        dec     di
        cmp     ax,0
        jne     CICLO

        pop     di
        pop     dx
        pop     cx
        popf
        ret
NUM_CONVERSION endp

;****************************
;   ROTINA PARA APAGAR ECRA *
;****************************
APAGA_ECRA	proc
        pushf
        push    cx
        push    di

        mov     di,0
        mov     cx,25*80
CLEAN:
        mov     byte ptr es:[di],' '
        mov     byte ptr es:[di+1],00000111b
        add     di, 2
        loop    CLEAN

        pop     di
        pop     cx
        popf
        ret
APAGA_ECRA	endp

;**********************************
;   ROTINA PARA IMPRIMIR MENU     *
;**********************************
PRINT_ECRA proc
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
PRINT_HRTL:         ; imprime barra topo e base
        goto_xy	bl,0        ; imprime topo
        mov		ah, 02h
        mov		dl, 0CDh
        int		21H
        goto_xy	bl,24       ; imprime base
        mov		ah, 02h
        mov		dl, 0CDh
        int		21H
        inc     bl
        loop    PRINT_HRTL

        mov     cx, 23
        mov     bl, 1
PRINT_VERTICAL:           ; imprime barra LEFT_1 e RIGHT_1
        goto_xy	1,bl        ; imprime LEFT_1
        mov		ah, 02h
        mov		dl, 0BAh
        int		21H
        goto_xy	78,bl       ; imprime RIGHT_1
        mov		ah, 02h
        mov		dl, 0BAh
        int		21H
        inc     bl
        loop    PRINT_VERTICAL

        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
PRINT_ECRA endp

;**********************************
;   ROTINA PARA IMPRIMIR MOLDURA  *                                |
;**********************************
PRINT_MOLDURA proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si

          goto_xy	55,0         ; imprime separador do topo
          mov		ah, 02h
          mov		dl, 0CBh
          int		21H

          goto_xy	55,24        ; imprime separador da base
          mov		ah, 02h
          mov		dl, 0CAh
          int		21H

          mov     cx, 23
          mov     bl, 1
PRINT_VERTICAL:
          goto_xy	55,bl         ; imprime barra separadora
          mov		ah, 02h
          mov		dl, 0BAh
          int		21H
          inc     bl
          loop    PRINT_VERTICAL

          goto_xy	55,5          ; imprime separador da pontuacao esquerda
          mov		ah, 02h
          mov		dl, 0CCh
          int		21H


          goto_xy	55,12          ; imprime separador da legenda esquerda
          mov		ah, 02h
          mov		dl, 0CCh
          int		21H


          mov     cx, 22
          mov     bl, 56

PRINT_HRTL2:


          goto_xy	57,3           ; imprime legenda pontuacao
          lea     dx,name_points
          mov     ah,09h
          int     21h

          goto_xy	58,4            ; Escreve a pontucao atual a 0 no ecra
          lea     dx,print_points
          mov     ah,09h
          int     21h

          goto_xy	57,6            ; imprime legenda de jogo maca verde
          mov		ah, 09h
          mov     bl, 00000010b
          mov     cx, 1
          int     10h
          mov		ah, 02h
          mov		dl, 006h
          int		21h
          goto_xy	59,6
          lea     dx,name_macav
          mov     ah,09h
          int     21h

          goto_xy 74,6            ; Escreve o numero total a 000 de macas verdes
          lea     dx,print_maca_v
          mov     ah,09h
          int     21h

          goto_xy	57,8            ; imprime legenda de jogo maca madura
          mov		ah, 09h
          mov     bl, 00000100b
          mov     cx, 1
          int     10h
          mov		ah, 02h
          mov		dl, 005h
          int		21h
          goto_xy	59,8
          lea     dx,name_macam
          mov     ah,09h
          int     21h

          goto_xy 74,8            ; Escreve o numero total a 000 de macas maduras
          lea     dx,print_maca_m
          mov     ah,09h
          int     21h

          goto_xy	57,10            ; imprime legenda de jogo rato
          mov		ah, 09h
          mov     bl, 00000111b
          mov     cx, 1
          int     10h
          mov		ah, 02h
          mov		dl, 0DFh
          int		21h
          goto_xy	59,10
          lea     dx,name_rato
          mov     ah,09h
          int     21h

          goto_xy 74,10            ; Escreve o numero total a 000 de ratos
          lea     dx,print_rato
          mov     ah,09h
          int     21h

          goto_xy	57,13            ; imprime legenda de jogo direcoes RIGHT_1
          mov		ah, 02h
          mov		dl, 010h
          int		21h
          goto_xy	59,13
          mov		ah, 02h
          mov		dl, '-'
          int		21h
          goto_xy	61,13
          lea     dx,game_right
          mov     ah,09h
          int     21h

          goto_xy	57,15            ; imprime legenda de jogo direcoes LEFT_1
          mov		ah, 02h
          mov		dl, 011h
          int		21h
          goto_xy	59,15
          mov		ah, 02h
          mov		dl, '-'
          int		21h
          goto_xy	61,15
          lea     dx,game_left
          mov     ah,09h
          int     21h

          goto_xy	57,17            ; imprime legenda de jogo direcoes cima
          mov		ah, 02h
          mov		dl, 01Eh
          int		21h
          goto_xy	59,17
          mov		ah, 02h
          mov		dl, '-'
          int		21h
          goto_xy	61,17
          lea     dx,game_up
          mov     ah,09h
          int     21h

          goto_xy	57,19            ; imprime legenda de jogo direcoes DOWN_1
          mov		ah, 02h
          mov		dl, 01Fh
          int		21h
          goto_xy	59,19
          mov		ah, 02h
          mov		dl, '-'
          int		21h
          goto_xy	61,19
          lea     dx,game_down
          mov     ah,09h
          int     21h

          goto_xy	57,22            ; imprime legenda de jogo direcoes GO_BACK
          lea     dx,game_esc
          mov     ah,09h
          int     21h
          goto_xy	61,22
          mov		ah, 02h
          mov		dl, '-'
          int		21h

          pop     si
          pop     dx
          pop     cx
          pop     bx
          pop     ax
          popf
          ret
PRINT_MOLDURA endp

;*****************************************
;   ROTINA PARA SELECAO DE NIVEL DE JOGO *
;*****************************************
GAME_LEVEL proc
          pushf
          push    bx
          push    cx
          push    dx
          push    si

          goto_xy	10,9         ; imprime canto superior esquerdo
          mov		ah, 02h
          mov		dl, 0C9h
          int		21H
          goto_xy	69,9        ; imprime canto superior direito
          mov		ah, 02h
          mov		dl, 0BBh
          int		21H
          goto_xy	10,14        ; imprime canto inferior esquerdo
          mov		ah, 02h
          mov		dl, 0C8h
          int		21H
          goto_xy	69,14       ; imprime canto inferior direito
          mov		ah, 02h
          mov		dl, 0BCh
          int		21H

          mov     cx, 58
          mov     bl, 11
PRINT_HRTL:         ; imprime barra topo e base
          goto_xy	bl,9        ; imprime topo
          mov		ah, 02h
          mov		dl, 0CDh
          int		21H
          goto_xy	bl,14       ; imprime base
          mov		ah, 02h
          mov		dl, 0CDh
          int		21H
          inc     bl
          loop    PRINT_HRTL

          mov     cx, 4
          mov     bl, 10
PRINT_VERTICAL:           ; imprime barra LEFT_1 e RIGHT_1
          goto_xy	10,bl        ; imprime LEFT_1
          mov		ah, 02h
          mov		dl, 0BAh
          int		21H
          goto_xy	69,bl       ; imprime RIGHT_1
          mov		ah, 02h
          mov		dl, 0BAh
          int		21H
          inc     bl
          loop    PRINT_VERTICAL

          goto_xy	17,12             ; imprime legenda de velocidades de jogo
          lea     dx,menu_velocidade
          mov     ah,09h
          int     21h

          pop     si
          pop     dx
          pop     cx
          pop     bx
          popf
          ret
GAME_LEVEL endp

;*******************************
;   ROTINA PARA MOSTRAR O MENU *
;*******************************
PRINT_MENU	proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

        xor     si,si
        mov	    cx,135
WRITE_MENU:

loop    WRITE_MENU

        goto_xy 15,05
        lea     dx,game_name
        mov     ah,09h
        int     21h

        goto_xy	32,19
        lea     dx,texto1
        mov     ah,09h
        int     21h

        goto_xy	17,20
        lea     dx,nomes
        mov     ah,09h
        int     21h

        goto_xy	15,10
        lea     dx,menu_principal1
        mov     ah,09h
        int     21h

        goto_xy	15,11
        lea     dx,menu_principal2
        mov     ah,09h
        int     21h

        goto_xy	15,13
        lea     dx,menu_principal3
        mov     ah,09h
        int     21h

        goto_xy	15,14
        lea     dx,menu_principal4
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
PRINT_MENU	endp

;***************************
;   ROTINA PARA LER O MENU *
;***************************
READ_MENU	proc
        pushf
        push    ax

        cmp     menu,1
        je      MENU_ONE
        cmp     menu,2
        je      MENU_TWO

MENU_ONE:
        call 	LE_TECLA
		cmp 	al, 58h     ; Verifica se foi a tecla ESC pressinada
		je		FIM         ; Salta para FIM e sai do programa

		cmp     al, 31h     ; Verifica se foi a tecla 1 pressinada
		je      NEW_GAME   ; Salta para novo jogo

		jmp		MENU_ONE

NEW_GAME:
		call    APAGA_ECRA
		call    GAME_LEVEL
		mov     menu,2
		call    READ_MENU
		jmp     FIM


MENU_TWO:
		call 	LE_TECLA
		cmp 	al, 1Bh     ; Verifica se foi a tecla ESC pressinada
		je		GO_BACK

		cmp     al, 31h     ; Verifica se foi a tecla 1 pressinada
		je      LEVEL_ONE      ; Salta para LEVEL_ONE
        cmp     al, 32h     ; Verifica se foi a tecla 2 pressinada
		je      LEVEL_TWO      ; Salta para LEVEL_TWO
        cmp     al, 33h     ; Verifica se foi a tecla 3 pressinada
		je      LEVEL_THREE      ; Salta para LEVEL_THREE
        cmp     al, 34h     ; Verifica se foi a tecla 4 pressinada
		je      LEVEL_FOUR      ; Salta para LEVEL_FOUR

		jmp		MENU_TWO

LEVEL_ONE:
		cmp		al, 31h
		mov		factor, 100
		mov     nivel,1
		jmp     START_GAME

LEVEL_TWO:
        cmp		al, 32h
		mov		factor, 50
        mov     nivel,2
		jmp     START_GAME

LEVEL_THREE:
        cmp		al, 33h
		mov		factor, 25
        mov     nivel,3
		jmp     START_GAME

LEVEL_FOUR:
        cmp		al, 34h
		mov		factor, 13
        mov     nivel,4
		jmp     START_GAME

START_GAME:
        call    APAGA_ECRA
		call    PRINT_ECRA
        call    PRINT_MOLDURA
        call    MOVE_SNAKE

GO_BACK:
        call    APAGA_ECRA
        call    PRINT_ECRA
        call    PRINT_MENU
        mov     menu,1
		call    READ_MENU
		jmp     FIM

FIM:
        pop     ax
        popf
        ret
READ_MENU	endp

;******************************
;   ROTINA PARA LER TECLADO   *
;******************************
LE_TECLA    proc
		mov	    ah, 0Bh
		int 	21h
		cmp 	al, 0
		jne     WITH_TECLA
		mov	    ah, 0
		mov	    al, 0
		jmp	    END_TECLA

WITH_TECLA:
		mov	    ah, 08h
		int	    21h
		mov	    ah, 0
		cmp	    al, 0
		jne	    END_TECLA
		mov	    ah, 08h
		int	    21H
		mov	    ah, 1

END_TECLA:

        ret
LE_TECLA	endp

;**************************************
;   ROTINA PARA CALCULAR ALEATORIOS   *
;**************************************
CALCULA_ALEATORIO proc near
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
CALCULA_ALEATORIO endp

;********************************************
;   ROTINA PARA CRIAR O CORPO DA SNAKE      *
;********************************************
CRIA_SNAKE proc
        pushf
        push	ax
        push	cx
        push	dx
        push    si

        xor     si,si
CICLO:
        goto_xy POSx[si], POSy[si]
        mov		ah, 09h
        mov     bl, 00000001b
        mov     cx, 1
        int     10h
        mov     ah, 02h

        cmp     si,0
        jne     CORPO_SNAKE
        mov     dl, 0DBh
        jmp     END_CORPO

CORPO_SNAKE:
        mov     dl, 0DBh

END_CORPO:
        int     21h
        inc     si
        cmp     corpo,si
        jne     CICLO

        pop     si
        pop	    dx
        pop	    cx
        pop	    ax
        popf
        ret
CRIA_SNAKE endp

;***********************************
;   ROTINA PARA APAGAR A SNAKE     *
;***********************************
DELETE_SNAKE proc
        pushf
        push	ax
        push	cx
        push	dx
        push    si

        xor     si,si
        xor     cx,cx

CICLO:
        goto_xy POSx[si], POSy[si]
        mov		ah, 09h
        mov     bl, 00000111b
        mov     cx, 1
        int     10h
        mov     ah, 02h
        mov     dl, ' '
        int     21h
        inc     si
        cmp     corpo,si
        jne     CICLO

        pop     si
        pop	    dx
        pop	    cx
        pop	    ax
        popf
        ret
DELETE_SNAKE endp

;**************************************
;   ROTINA PARA MOVIMENTAR A SNAKE    *
;**************************************
PASSA_TEMPO proc
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
		jbe     MENOR
		mov     ax, 1
		mov     passa_t, ax
		jmp     FIM_PASSA

MENOR:
        mov     ax,0
		mov     passa_t, ax

FIM_PASSA:

 		ret
PASSA_TEMPO   endp

;*******************************************
;   ROTINA PARA COLOCAR OBJETOS NO ECRA    *
;*******************************************
SNAKE_FOOD proc
        pushf
        push    ax
        push    bx
        push    cx
        push    dx

        mov     ah, 2Ch     ; Conta o tempo em segundos para auxiliar na colocacao do SNAKE_FOOD
        int     21h

        cmp     dh, segundos
        je      COORDENADASXY

        mov     segundos, dh
        inc     fruta_t
        inc     rato_t

COORDENADASXY:
        call	CALCULA_ALEATORIO	; Calcula próximo aleatório para gerar a cordenada X
        pop	    ax

        mov     cx, 53
        xor     dx,dx
        div     cx
        add     dl,2
        mov     POSxf,dl

        call	CALCULA_ALEATORIO	; Calcula próximo aleatório para gerar a cordenada Y
        pop	    ax

        mov     cx, 23
        xor     dx,dx
        div     cx
        add     dl,1
        mov     POSyf,dl

        goto_xy POSxf,POSyf ; Verifica se está algum objeto na posicao da coordenada
        mov 	ah, 08h	    ; Guarda o Caracter que está na posição do Cursor
        mov		bh,0
        int		10h
        cmp 	al,' '	    ; Verifica se não existe nada na posição do Cursor
        jne     COORDENADASXY

        cmp     ratos,0     ; Verifica se nao existem ratos no ecra
        je      CREATE_RATO

        cmp     ratos,1     ; Verifica se esta o numero maximo de ratos no ecra
        je      DELETE_RATO

DELETE_RATO:
        cmp     rato_t,24      ; Verifica se passou tempo para desaparecer o rato
        jb      END_RATO
        mov     rato_t,0

        goto_xy POSxr,POSyr     ; Elimina rato do ecra de jogo
        mov		ah, 09h
        mov     bl, 00000111b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, ' '
        int		21h
        dec     ratos
        jmp     END_RATO

CREATE_RATO:
        cmp     rato_t,20   ; Verifica se passou tempo para inserir rato
        jb      END_RATO

        mov     dl,POSxf        ; Guarda coordenada X onde rato vai ser inserido
        mov     POSxr,dl
        mov     dl,POSyf        ; Guarda coordenada Y onde rato vai ser inserido
        mov     POSyr,dl

        goto_xy POSxf,POSyf     ; Insere rato no ecra de jogo
        mov		ah, 09h
        mov     bl, 10000111b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 0DFh
        int		21h
        inc     ratos

END_RATO:

        cmp     fruta,4     ; Verifica se esta o numero maximo de frutas no ecra
        je      FIM_ALIMENTO
        cmp     fruta_t,5   ; Verifica se passou tempo para inserir fruta
        jb      FIM_ALIMENTO
        mov     fruta_t,0

        call	CALCULA_ALEATORIO	; Calcula próximo aleatório para escolher o tipo de fruto
        pop	    ax
        and     ax,00000001

        jp      MACA_MADURA     ; Verifica se insere maca madura ou verde

        goto_xy POSxf,POSyf     ; Insere maca verde no ecra de jogo
        mov		ah, 09h
        mov     bl, 00000010b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 006h
        int		21h
        inc     fruta
        jmp     FIM_ALIMENTO

MACA_MADURA:
        goto_xy POSxf,POSyf     ; Insere maca madura no ecra de jogo
        mov		ah, 09h
        mov     bl, 00000100b
        mov     cx, 1
        int     10h
        mov		ah, 02h
        mov		dl, 005h
        int		21h
        inc     fruta

FIM_ALIMENTO:

        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
        ret
SNAKE_FOOD endp

;****************************************
;   ROTINA PARA COLOCAR A PONTUACAO     *
;****************************************
GAME_POINTS proc
        pushf
        push    ax
        push    bx
        push    dx


        goto_xy	58,4            ; Escreve a GAME_POINTS atual no ecra
        xor     ax,ax
        mov     ax, pontos

        lea     bx,print_points
        mov     digit,5     ; Define o numero de digitos do numero a imprimir no ecra
        call    NUM_CONVERSION

        lea     dx,print_points
        mov     ah,09h
        int     21h

        goto_xy 74,6            ; Escreve o numero total de macas verdes comidas
        xor     ax,ax
        mov     ax, macav

        lea     bx,print_maca_v
        mov     digit,2     ; Define o numero de digitos do numero a imprimir no ecra
        call    NUM_CONVERSION

        lea     dx,print_maca_v
        mov     ah,09h
        int     21h

        goto_xy 74,8            ; Escreve o numero total de macas maduras comidas
        xor     ax,ax
        mov     ax, macam

        lea     bx,print_maca_m
        mov     digit,2     ; Define o numero de digitos do numero a imprimir no ecra
        call    NUM_CONVERSION

        lea     dx,print_maca_m
        mov     ah,09h
        int     21h

        goto_xy 74,10            ; Escreve o numero total de ratos comidos
        xor     ax,ax
        mov     ax, rato

        lea     bx,print_rato
        mov     digit,2     ; Define o numero de digitos do numero a imprimir no ecra
        call    NUM_CONVERSION

        lea     dx,print_rato
        mov     ah,09h
        int     21h

        pop     dx
        pop     bx
        pop     ax
        popf
        ret
GAME_POINTS endp

;**************************************
;   ROTINA PARA MOVIMENTAR A SNAKE    *
;**************************************
MOVE_SNAKE proc
        mov		direccao,3  ; Define por defeito a direcao inicial da cobra

		mov     fruta,0     ; Reset ao contador de frutas
		mov     ratos,0     ; Reset ao contador de ratos
		mov     fruta_t,5   ; Reset ao temporizador de frutas
		mov     rato_t,0    ; Reset ao temporizador de ratos

		mov     pontos,0    ; Reset ao pontos obtidos
		mov     macav,0     ; Reset as macas verdes comidas
		mov     macam,0     ; Reset as macas maduras comidas
		mov     rato,0      ; Reset ao ratos comidos

		mov     corpo,1   ; Reset ao corpo da snake
        call    GAME_POINTS   ; Atualiza valores

        call	CALCULA_ALEATORIO	; Calcula próximo aleatório para gerar a cordenada X
        pop	    ax

        mov     cx, 53
        xor     dx,dx
        div     cx
        add     dl,2
        mov     POSx[0],dl

        call	CALCULA_ALEATORIO	; Calcula próximo aleatório para gerar a cordenada Y
        pop	    ax

        mov     cx, 15
        xor     dx,dx
        div     cx
        add     dl,1
        mov     POSy[0],dl

CICLO:
        call    SNAKE_FOOD

        goto_xy POSx[0],POSy[0]	    ; Vai para nova posição
        mov 	ah, 08h	            ; Guarda o Caracter que está na posição do Cursor
        mov		bh,0		        ; numero da página
        int		10h

        cmp 	al, 0CDh	; Faz a verificacao se tocou nas paredes do tabuleiro de jogo
        je		FIM
        cmp 	al, 0CCh
        je		FIM
        cmp 	al, 0BAh
        je		FIM
        cmp     al, 02Ah    ; Faz a verificacao se tocou no corpo
        je      FIM

        cmp     al, 006h    ; Verifica SNAKE_FOOD comido maca verde
        je      EAT_MACA_V

        cmp     al, 005h    ; Verifica SNAKE_FOOD comido maca madura
        je      EAT_MACA_M

        cmp     al, 040h    ; Verifica SNAKE_FOOD comido rato
        je      EAT_RATO

        jmp     FIM_SNAKE_FOOD

EAT_MACA_V:
        mov     ax,1
        mov     cx,nivel
        mul     cx
        add     pontos,ax       ; Adiciona a GAME_POINTS de acordo com o fruto comido
        inc     corpo         ; Adiciona 1 posicao na cauda
        inc     macav           ; Incrementa fruto comido ao total
        dec     fruta           ; Decrementa valor no contador de frutas
        call    GAME_POINTS
        jmp     FIM_SNAKE_FOOD

EAT_MACA_M:
        mov     ax,2
        mov     cx,nivel
        mul     cx
        add     pontos,ax       ; Adiciona a GAME_POINTS de acordo com o fruto comido
        add     corpo,2       ; Adiciona 2 posicoes na cauda
        inc     macam           ; Incrementa fruto comido ao total
        dec     fruta           ; Decrementa valor no contador de frutas
        call    GAME_POINTS
        jmp     FIM_SNAKE_FOOD

EAT_RATO:
        mov     ax,3
        mov     cx,nivel
        mul     cx
        add     pontos,ax       ; Adiciona a GAME_POINTS de acordo com o fruto comido

        cmp     corpo,6       ; Verifica corpo da cauda da snake
        jnb     REDUCE_SNAKE_S
        mov     corpo,1       ; Reset ao corpo da cauda
        jmp     END_SNAKE_S

REDUCE_SNAKE_S:
        sub     corpo,5       ; Reduz a cauda em 5 posicoes

END_SNAKE_S:
        inc     rato            ; Incrementa fruto comido ao total
        dec     ratos           ; Decrementa valor no contador de ratos
        mov     rato_t,0        ; Reset do valor no temporizador de ratos
        call    GAME_POINTS
        jmp     FIM_SNAKE_FOOD

FIM_SNAKE_FOOD:
        call    CRIA_SNAKE

LER_SETA:
        call 	LE_TECLA
        cmp		ah, 1
        je		ESTEND
        cmp 	al, 27	    ; Verifica se tecla Esc pressionada
        je		FIM

        call	PASSA_TEMPO
        mov		ax, passa_t_ant
        cmp		ax, passa_t
        je		LER_SETA
        mov		ax, passa_t
        mov		passa_t_ant, ax

VERIFICA_0:
        mov		al, direccao        ; Move snake para RIGHT_1
        cmp 	al, 0
        jne		VERIFICA_1
        call    DELETE_SNAKE

        mov     si,corpo          ; Atualiza array com as COORDENADASXY da snake
        mov     cx,corpo
CORPO_0:
        mov     dl,POSy[si-1]
        mov     POSy[si],dl
        mov     dl,POSx[si-1]
        mov     POSx[si],dl
        dec     si
        loop    CORPO_0

        inc		POSx[0]
        jmp		CICLO

VERIFICA_1:
        mov 	al, direccao        ; Move snake para cima
        cmp		al, 1
        jne		VERIFICA_2
        call    DELETE_SNAKE

        mov     si,corpo          ; Atualiza array com as COORDENADASXY da snake
        mov     cx,corpo
CORPO_1:
        mov     dl,POSy[si-1]
        mov     POSy[si],dl
        mov     dl,POSx[si-1]
        mov     POSx[si],dl
        dec     si
        loop    CORPO_1

        dec		POSy[0]
        jmp		CICLO

VERIFICA_2:
        mov 	al, direccao        ; Move snake para LEFT_1
        cmp		al, 2
        jne		VERIFICA_3
        call    DELETE_SNAKE

        mov     si,corpo          ; Atualiza array com as COORDENADASXY da snake
        mov     cx,corpo
CORPO_2:
        mov     dl,POSy[si-1]
        mov     POSy[si],dl
        mov     dl,POSx[si-1]
        mov     POSx[si],dl
        dec     si
        loop    CORPO_2

        dec		POSx[0]
        jmp		CICLO

VERIFICA_3:
        mov 	al, direccao        ; Move snake para DOWN_1
        cmp		al, 3
        jne		CICLO
        call    DELETE_SNAKE

        mov     si,corpo          ; Atualiza array com as COORDENADASXY da snake
        mov     cx,corpo
CORPO_3:
        mov     dl,POSy[si-1]
        mov     POSy[si],dl
        mov     dl,POSx[si-1]
        mov     POSx[si],dl
        dec     si
        loop    CORPO_3

        inc		POSy[0]
		jmp		CICLO

ESTEND:
        cmp 	al,48h
		jne		DOWN_1
		cmp     corpo,2       ; Verifica se corpo da snake superior que 1
		jb      DIRECAO_1
		cmp     direccao, 3     ; Verifica movimento da snake para nao permitir que va para cima dela propria
		je      CICLO

DIRECAO_1:
		mov		direccao, 1
		jmp		CICLO

DOWN_1:
        cmp		al,50h
		jne		LEFT_1
        cmp     corpo,2       ; Verifica se corpo da snake superior que 1
		jb      DIRECAO_3
		cmp     direccao, 1     ; Verifica movimento da snake para nao permitir que va para cima dela propria
		je      CICLO

DIRECAO_3:
		mov		direccao, 3
		jmp		CICLO

LEFT_1:
		cmp		al,4Bh
		jne		RIGHT_1
        cmp     corpo,2       ; Verifica se corpo da snake superior que 1
		jb      DIRECAO_2
		cmp     direccao, 0     ; Verifica movimento da snake para nao permitir que va para cima dela propria
		je      CICLO

DIRECAO_2:
		mov		direccao, 2
		jmp		CICLO

RIGHT_1:
		cmp		al,4Dh
		jne		LER_SETA
        cmp     corpo,2       ; Verifica se corpo da snake superior que 1
		jb      DIRECAO_0
		cmp     direccao, 2     ; Verifica movimento da snake para nao permitir que va para cima dela propria
		je      CICLO

DIRECAO_0:
		mov		direccao, 0
		jmp		CICLO

FIM:
        call    APAGA_ECRA
        call    PRINT_ECRA
        call    PRINT_MENU

		ret
MOVE_SNAKE endp

;------------------------------------------------------------------------
;   MAIN                                                                |
;------------------------------------------------------------------------
MAIN	proc
        mov     ax, dseg
        mov     ds, ax
        mov     ax, 0b800h
        mov     es, ax      ; Segmento de memoria video

        mov     ch, 32      ; Esconder cursor
        mov     ah, 1
        int     10h

        call    APAGA_ECRA
        call    PRINT_ECRA
        call    PRINT_MENU
        mov     menu,1
        call    READ_MENU

FIM:
        goto_xy 79,24       ; Salta para FIM do ecra
        mov     ch, 6       ; Mostra cursor
        mov     cl, 7
        mov     ah, 1
        int     10h

        mov     al, 0
        mov     ah, 4ch
        int     21h

MAIN	endp
cseg	ends

end	MAIN
