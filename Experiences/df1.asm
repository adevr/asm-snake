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

; MOSTRA - Faz o display de uma string terminada em $
;---------------------------------------------------------------------------
MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM
; FIM DAS MACROS


;---------------------------------------------------------------------------


.8086
.model small
.stack 2048h

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS
	

DSEG    SEGMENT PARA PUBLIC 'DATA'

                ultimo_num_aleat dw 0
texto db 'Pontos = ____ $'
		POSy	db	10	; a linha pode ir de [1 .. 25]
		POSx	db	40	; POSx pode ir [1..80]	
		;POSya		db	5	; Posição anterior de y
		;POSxa		db	10	; Posição anterior de x
		corpo		db	1	;
		ponto2		dw  10000
		posYa		db	100 dup('_')
		posXa		db	100 dup('_')
		PASSA_T		dw	0
		PASSA_T_ant	dw	0
		direccao	db	3

                linha		db	0	; Define o número da linha que está a ser desenhada
		nlinhas		db	0

		
		Centesimos	dw 	0
		FACTOR		db	100
		metade_FACTOR	db	?
		resto		db	0
						
		Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
		Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
		Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
		Fich         	db      'moldura.TXT',0
		HandleFich      dw      0
		car_fich        db      ?
		Car		db	32	; Guarda um caracter do Ecran

DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA
	


;********************************************************************************



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




;********************************************************************************	



Imp_Fich	PROC

;abre ficheiro

        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich			; nome do ficheiro
        int     21h			; abre para leitura 
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

;########################################################################

;********************************************************************************
;ROTINA PARA APAGAR ECRAN

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



;alteraçao
CalcAleat proc near

	sub	sp,2		; 
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat	; vai buscar o aleatório anterior
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx			
	pop	dx			 
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx	; guarda o novo numero aleatório  

	mov	[BP+4],dx		; o aleatório é passado por pilha

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp
;alteraçao





;#############################################################################
move_snake PROC

CICLO:	

call ponto1
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		cmp 		al, '#'	;  na posição do Cursor
		je		fim
		
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		cmp 		al, 15	;  na posição do Cursor
		je		fim
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		cmp 		al, 'b'	;  COMER ALGO ALTERADO POR JOSE DIAS
		jne	seguinte
		
        
goto_xy		POSx,POSy	; Vai para posição do cursor

		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 		POSya, al


		mov	linha, dh	; O Tabuleiro vai começar a ser desenhado na linha 8
		mov	nlinhas,al	; O Tabuleiro vai ter 6 linhas



		mov	al, 140
		mov	ah, linha
		mul	ah
		add	ax, 45
		mov 	bx, ax		; Determina Endereço onde começa a "linha". bx = 160*linha + 60
                inc     ah
		mov	cx, 7   	; São 9 colunas

		 ;mov 	dh,	car	; vai imprimir o caracter "SAPCE"
		 ;mov	es:[bx],dh	;

;;

		call	CalcAleat	; Calcula próximo aleatório que é colocado na pilha
		;pop	ax		; Vai buscar 'a pilha o número aleatório
                mov     ax,'b'
		and 	ah,01110000b	; posição do ecran com cor de fundo aleatório e caracter a preto
                ;cmp     ah,'#'
                ;je      trocaletra
                ;jne     ciclo
                ;;;;;;;;
                

		 ;mov 	dh,	   car	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois caracteres de ecran
		 ;mov	es:[bx],   dh

		mov	es:[bx+1], al	; Coloca as características de cor da posição atual
              




;;;;;;;;;;;;;;;;;;;;

		

		xor al,al
		mov al,corpo
		inc al
		mov corpo,al ; FIM DE COMER ALGO
		dec al
		mov ah,0
		add ax,10000
		mov ponto2,ax
		
	
	
	
	seguinte:	
	xor ax,ax
		
		mov al,corpo
		
		mov si,ax
		
		goto_xy		POSxa[si],POSya[si]		; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, ' ' 	; Coloca ESPAÇO
		int		21H	


		
		
IMPRIME:	
		goto_xy		POSx,POSy	; Vai para posição do cursor
	
		mov		ah, 02h
		mov		dl, 21	; Coloca AVATAR1
		int		21H
		

			
			xor ax,ax
		
		mov al,corpo
		
		mov si,ax
		
		cmp si,1
		je next
		
		goto_xy		POSxa[1],POSya[1]	; Vai para posição do cursor resto do corpo
		
		mov		ah, 02h
		mov		dl, 15	; Coloca AVATAR1
		int		21H
		
	
		next:
		;goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor NO ARRY ALTERADO POR JOSE DIAS
		mov		POSxa[0], al
		mov		al, POSy	; Guarda a posição do cursor NO ARRY
		mov 	POSya[0], al
		
		xor ax,ax				;DESENHA COBRA POR ARRY
		mov al,corpo
		mov si,ax
		
		desenha:					;DESENHA COBRA POR ARRY
		mov al,posxa[si-1]
		mov posxa[si],al
		mov al,posya[si-1]
		mov posya[si],al
		cmp si,0
		dec si
		ja desenha
		;FIM DESENHA COBRA POR ARRY ALTERADO POR JOSE DIAS
		
		
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
		

ESTEND:	

		MOV bl, DIRECCAO
		cmp bl,1
		je	baixo
		cmp bl,3
		je baixo
		
		cmp 		al,48h
		jne		BAIXO
		mov		direccao, 1
		jmp		CICLO

BAIXO:	

		cmp bL,3
		je	esquerda
		cmp bL,1
		je	esquerda
		
		cmp		al,50h
		jne		ESQUERDA
		mov		direccao, 3
		jmp		CICLO

ESQUERDA:

		cmp bL,2
		je	direita
		cmp bL,0
		je direita
		
		cmp		al,4Bh
		jne		DIREITA
		mov		direccao, 2
		jmp		CICLO

DIREITA:
		cmp bL,0
		je	ciclo
		cmp bl,2
		je ciclo
		cmp		al,4Dh
		jne		LER_SETA 
		mov		direccao, 0	
		jmp		CICLO

fim:	
MOV		AH,4Ch
		INT		21h	
;goto_xy		45,23
		;RET

move_snake ENDP
;;;;;

ponto1 proc
	
		mov    ax,ponto2
		
        lea    bx,texto
        add    bx,8
        call   converte
		goto_xy	0,0
		 lea dx, texto
        mov ah,09h
        int    21h
     
; pontos

   converte proc
        
        pushf
        push cx
        push dx
        push di

        mov cx,10
        mov di,4
ciclo2: 
        mov dx,0 
        div cx
        add dl,48
        mov[bx+di],dl
        dec di
        cmp di,0
        jne ciclo2
    
        pop di 
        pop dx
        pop cx
        popf
        ret
converte endp
ponto1 endp
;#############################################################################
;             MAIN
;#############################################################################
MENU    Proc
		MOV     	AX,DSEG
		MOV     	DS,AX
		MOV		AX,0B800H
		MOV		ES,AX		; ES indica segmento de memória de VIDEO
		CALL 		APAGA_ECRAN 
		CALL		Imp_Fich
		call		move_snake
		
		MOV		AH,4Ch
		INT		21h
MENU    endp
cseg	ends
end     MENU