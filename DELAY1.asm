;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2018/2019
;
;
;	
;
;		press ESC to exit
;------------------------------------------------------------------------
; MACROS
;------------------------------------------------------------------------
;MACRO GOTO_XY
; COLOCA O CURSOR NA POSIÇÃO POSX,POSY
;	POSX -> COLUNA
;	POSY -> LINHA
;------------------------------------------------------------------------
GOTO_XY		MACRO	POSX,POSY
			MOV	AH,02H
			MOV	BH,0
			MOV	DL,POSX
			MOV	DH,POSY
			INT	10H
ENDM


.8086
.model small
.stack 2048h

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS
	

DSEG    SEGMENT PARA PUBLIC 'DATA'
        POSy    db 12	; a linha pode ir de [1..25]
		POSx    db 40	; a coluna pode ir de [1..80]
        POSya	db	5	; Posição anterior de y
		POSxa	db	10	; Posição anterior de x
        linha   db 0
		ultimo_num_aleat dw 0

		pontos_m        db  6 dup ('0'),'$'
		pontos 			db  6 dup ('0'),'$'

		POSyf			db	3	; Posição fruta de y
		POSxf			db	8	; Posição fruta de x


		PASSA_T			dw	0
		PASSA_T_ant		dw	0
		direccao		db	3
		
		Centesimos		dw 	0
		FACTOR			db	100
		metade_FACTOR	db	?
		resto			db	0

		
		Erro_Open       db  'Erro ao tentar abrir o ficheiro$'
		Erro_Ler_Msg    db  'Erro ao tentar ler do ficheiro$'
		Erro_Close      db  'Erro ao tentar fechar o ficheiro$'
		FichMenu		db  'menu.TXT', 0
		Fich         	db  'moldura.TXT',0
		FichRes			db	'resulta.dat',0
		HandleFich      dw  0
		car_fich        db  ?
		fhandle 		dw	0
		buffer			dw	0
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"

		score			dw	123

		texto_score  	db  'SCORE = ', 5 dup(' '), '$'
		
DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA
	


;********************************************************************************

resultado proc

	pushf
	push ax
	push dx
	push cx


	mov		AX, DSEG	
	mov		DS, AX
	
	mov		ah, 3ch				; Abrir o ficheiro para escrita
	mov		cx, 00H				; Define o tipo de ficheiro 
	lea		dx, FichRes			; DX aponta para o nome do ficheiro 
	int		21h					; Abre efectivamente o ficheiro (AX fica com o Handle do ficheiro)
	jnc		escreve				; Se não existir erro escreve no ficheiro
	mov		ah, 09h
	lea		dx, msgErrorCreate
	int		21h
	
	jmp		fim

escreve:
	
	mov		bx, ax				; Coloca em BX o Handle
	mov		ah, 40h				; indica que é para escrever
    	
	lea		dx, pontos			; DX aponta para a infromação a escrever
	mov		cx, 240				; CX fica com o numero de bytes a escrever
	int		21h					; Chama a rotina de escrita
	jnc		close				; Se não existir erro na escrita fecha o ficheiro
	
	mov		ah, 09h
	lea		dx, msgErrorWrite
	int		21h

close:
	
	mov		ah,3eh				; fecha o ficheiro
	int		21h
	jnc		fim
	
	mov		ah, 09h
	lea		dx, msgErrorClose
	int		21h

fim:
	mov		AH,4CH
	int		21H

	pop		cx
	pop 	dx
	pop 	ax
	popf
	ret
resultado	endp

Imp_Resultado	PROC
;abre ficheiro

    mov     ah,3dh			; vamos abrir ficheiro para leitura 
    mov     al,0			; tipo de ficheiro	
    lea     dx, Fich	; nome do ficheiro
    int     21h			     ; abre para leitura 
    jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
    mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
    jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
	
	mov     ah,09h
    lea     dx,Erro_Open
    int     21h
    jmp     sai

ler_ciclo:
	
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
    mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
    mov     cx,1			; numero de bytes a ler 
    lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
    int     21h			; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0		;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
    mov     ah,02h			; coloca o caracter no ecran
	mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	int	    21h			; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro
	call	resultado

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        int     21h
sai:	
		ret
Imp_Resultado	endp

;########################################################################

PASSA_TEMPO PROC	
 
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
 		XOR AX,AX
		MOV AL, DL              ; centesimos de segundo para ax		
		mov Centesimos, AX
	
		mov bl, factor		; define velocidade da snake (100; 50; 33; 25; 20; 10)
		div bl
		mov resto, AH
		mov AL, FACTOR
		mov AH, 0
		mov bl, 2
		div bl
		mov metade_FACTOR, AL
		mov AL, resto
		mov AH, 0
		mov BL, metade_FACTOR	; deve ficar sempre com metade do valor inicial
		mov AH, 0
		cmp AX, BX
		jbe Menor
		mov AX, 1
		mov PASSA_T, AX	
		jmp fim_passa	
		
Menor:		mov AX,0
		mov PASSA_T, AX		

fim_passa:	 

 		RET 
PASSA_TEMPO   ENDP 


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

;********************************************************************************	
;********************************************************************************
; ROTINA PARA ABRIR O MENU INICIAL
;********************************************************************************

Menu_Fich PROC
; abre ficheiro
	mov     ah,3dh			; vamos abrir ficheiro para leitura 
	mov     al,0			; tipo de ficheiro	
	lea     dx,FichMenu		; nome do ficheiro
	int     21h			     ; abre para leitura 
	jc      erro_abrirmenu		; pode aconter erro a abrir o ficheiro 
	mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
	jmp     ler_ciclomenu		; depois de abero vamos ler o ficheiro 

	erro_abrirmenu:
	mov     ah,09h
	lea     dx,Erro_Open
	int     21h
	jmp     sai

	ler_ciclomenu:
	mov     ah,3fh			; indica que vai ser lido um ficheiro 
	mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
	mov     cx,1			; numero de bytes a ler 
	lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
	int     21h			; faz efectivamente a leitura
	jc	    erro_lermenu		; se carry é porque aconteceu um erro
	cmp	    ax,0		     ;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiromenu	; se EOF fecha o ficheiro 
	mov     ah,02h			; coloca o caracter no ecran
	mov	    dl,car_fich	; este é o caracter a enviar para o ecran
	int	    21h			; imprime no ecran
	jmp	    ler_ciclomenu		; continua a ler o ficheiro

	erro_lermenu:
	mov     ah,09h
	lea     dx,Erro_Ler_Msg
	int     21h

	fecha_ficheiromenu:					; vamos fechar o ficheiro 
	mov     ah,3eh
	mov     bx,HandleFich
	int     21h
	jnc     sai

	mov     ah,09h			; o ficheiro pode não fechar correctamente
	lea     dx,Erro_Close
	Int     21h
	sai:	  RET
Menu_Fich	endp

;*************************************************************************
;	ROTINA PARA ABRIR
;*************************************************************************

Imp_Fich	PROC
;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx, Fich	; nome do ficheiro
        int     21h			     ; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h			; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0		;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	int	    21h			; imprime no ecran
	jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
sai:	  RET
Imp_Fich	endp

main_score	proc

        mov ax, dseg
        mov ds, ax  
        ;...
        mov ax, score
        lea si, texto_score
        add si, 7
        call CONVERTE
    
fim:
        lea dx, texto_score       ;print string ('....$)
        mov ax, 0b800h
        mov es, ax
        mov linha, 1
        mov al, 160
        mov ah, [linha]
        mul ah
        add ax, 60
        mov bx, ax
        int 10h

main_score	endp

CONVERTE    proc
    pushf
    push    di
    push    dx
    push    bx

        mov di, 4 
        mov di, si
 ciclo:

        mov dx, 0    
        mov bx, 10
        div bx             ;DX:AX / BX = AX (Resto = DX)
        add dl, 48
        mov [di], dl
        cmp ax, 0
        je  fim_func
        dec di
        jmp ciclo
fim_func:

    pop bx
    pop dx
    pop di
    popf
    ret
CONVERTE    ENDP
;########################################################################

;********************************************************************************
;	ROTINA PARA APAGAR ECRAN
;********************************************************************************

APAGA_ECRAN	PROC
		PUSH BX
		PUSH AX
		PUSH CX
		PUSH SI
		XOR	BX,BX
		MOV	CX,24*80
		mov bx,160
		MOV SI,BX
APAGA:	
		MOV	AL,' '
		MOV	BYTE PTR ES:[BX],AL
		MOV	BYTE PTR ES:[BX+1],7
		INC	BX
		INC BX
		INC SI
		LOOP	APAGA
		POP SI
		POP CX
		POP AX
		POP BX
		RET
APAGA_ECRAN	ENDP


;*******************************************
; 	ROTINA PARA TER DELAY
;*******************************************
delay proc   
  mov cx, 7      ;HIGH WORD.
  mov dx, 0A120h ;LOW WORD.
  mov ah, 86h    ;WAIT.
  int 15h
  ret
delay endp 

;********************************************************************************
; LEITURA DE UMA TECLA DO TECLADO    (ALTERADO)
; LE UMA TECLA	E DEVOLVE VALOR EM AH E AL
; SE ah=0 É UMA TECLA NORMAL
; SE ah=1 É UMA TECLA EXTENDIDA
; AL DEVOLVE O CÓDIGO DA TECLA PREMIDA
; Se não foi premida tecla, devolve ah=0 e al = 0
;********************************************************************************

LE_TECLA_0	PROC

	;	call 	Trata_Horas
		MOV	AH,0BH
		INT 	21h
		cmp 	AL,0
		jne	com_tecla
		mov	AH, 0
		mov	AL, 0
		jmp	SAI_TECLA
com_tecla:		
		MOV	AH,08H
		INT	21H
		MOV	AH,0
		CMP	AL,0
		JNE	SAI_TECLA
		MOV	AH, 08H
		INT	21H
		MOV	AH,1
SAI_TECLA:	
		RET
LE_TECLA_0	ENDP

;#############################################################################
;*****************************************************************************
;	ROTINA PARA MOVER A SNAKE
;*****************************************************************************
move_snake PROC
	pushf
	push ax
    call        main_score
    ; ...

CICLO:	
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 	ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		cmp 	al, '|'	;  na posição do Cursor
		je		fim
		cmp 	al, '_'	;  na posição do Cursor
		je		fim
				
		;cmp 	al, '0'	;  cobra nao se mexeu!!!
		;je		salta_alimento

		;goto_xy	POSxa,POSya		; Vai para a posição anterior do cursor
		;mov		ah, 02h
		cmp 		al, ' '
		je		salta_alimento
		call 	alimento
		;jne		inserir_alimento
		
;inserir_alimento:
		
salta_alimento:

		goto_xy	POSxa,POSya	
		mov		ah, 09h
		mov		bh, 0
		mov		al, ' '		;  Coloca ESPAÇO
		mov		bl, 00000111b
		mov		cx, 1
		int		10H	
		
IMPRIME:
		goto_xy		POSx,POSy	; Vai para posição do cursor
		mov		ah, 02h
		mov		dl, '0'	; Coloca AVATAR1
		int		21H

		goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
		

LER_SETA:	call 		LE_TECLA_0
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27	; ESCAPE
		JE		FIM
		CMP		AL, '1'
		JNE		TESTE_2
		MOV		FACTOR, 100
TESTE_2:	CMP		AL, '2'
		JNE		TESTE_3
		MOV		FACTOR, 50
TESTE_3:	CMP		AL, '3'
		JNE		TESTE_4
		MOV		FACTOR, 25
TESTE_4:	CMP		AL, '4'
		JNE		TESTE_END
		MOV		FACTOR, 10
TESTE_END:		
		CALL		PASSA_TEMPO
		mov		AX, PASSA_T_ant
		CMP		AX, PASSA_T
		je		LER_SETA
		mov		AX, PASSA_T
		mov		PASSA_T_ant, AX
		
verifica_0:	mov		al, direccao
		cmp 		al, 0
		jne		verifica_1
		inc		POSx		;Direita
		jmp		CICLO
		
verifica_1:	mov 		al, direccao
		cmp		al, 1
		jne		verifica_2
		dec		POSy		;cima
		jmp		CICLO
		
verifica_2:	mov 		al, direccao
		cmp		al, 2
		jne		verifica_3
		dec		POSx		;Esquerda
		jmp		CICLO
		
verifica_3:	mov 		al, direccao
		cmp		al, 3		
		jne		CICLO
		inc		POSy		;BAIXO		
		jmp		CICLO
		
ESTEND:		cmp 		al,48h
		jne		BAIXO
		mov		direccao, 1
		jmp		LER_SETA

BAIXO:		cmp		al,50h
		jne		ESQUERDA
		mov		direccao, 3
		jmp		LER_SETA

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		mov		direccao, 2
		jmp		LER_SETA

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		mov		direccao, 0	
		jmp		LER_SETA

fim:		goto_xy		40,23
        ; ...
        
		pop ax
		popf
		RET
move_snake ENDP

;********************************************************
;	METODO QUE CHAMA A MOLDURA E INICIA A SNAKE
;********************************************************

one proc
	call		Imp_Fich
	call      alimento
	call      alimento
	call      alimento
    call		move_snake
	ret
one endp



;********************************************************
;	ROTINA PARA INSERIR OS ALIMENTOS NA MOLDURA
;********************************************************
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
	;mov     pontos[di-1],dl
	;dec     di
	;cmp     di,0
	;cmp     ax,0
	;jne     ciclo

	;lea     dx,pontos
	mov     ah,09h
	;int     21h

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
        mov     bl, 'v'
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

;#############################################################################
;             MAIN
;#############################################################################
MENU    Proc
		mov    	AX,DSEG
		mov     DS,AX
		mov		AX,0B800H
		mov		ES,AX		; ES indica segmento de memória de VIDEO

mostra_menu:
		call 	APAGA_ECRAN 
		call    Menu_Fich

Tecla:
		mov		ah, 08h
		int		21h
		cmp		AL, '1'
		jne		tecla_2
		call	one
		jmp		mostra_menu

not_one: 
		cmp		AL, 'x'
		jne		Tecla
		jmp 	fim

tecla_2:	
		cmp		AL, '2'
		jne		tecla_3
		
tecla_3:
		cmp		AL, '3'
		jne		not_one
		call    resultado
fim:	
		mov		AH,4Ch
		int		21h
MENU    endp
cseg	ends
end     MENU
