[1mdiff --git a/DELAY.EXE b/DELAY.EXE[m
[1mindex abd351c..7a7874a 100644[m
Binary files a/DELAY.EXE and b/DELAY.EXE differ
[1mdiff --git a/DELAY.OBJ b/DELAY.OBJ[m
[1mindex 79bef7a..93c2f71 100644[m
Binary files a/DELAY.OBJ and b/DELAY.OBJ differ
[1mdiff --git a/DELAY.asm b/DELAY.asm[m
[1mindex 3095cc0..07fe0c1 100644[m
[1m--- a/DELAY.asm[m
[1m+++ b/DELAY.asm[m
[36m@@ -67,7 +67,7 @@[m [mDSEG    SEGMENT PARA PUBLIC 'DATA'[m
 		Erro_Open       db      'Erro ao tentar abrir o ficheiro$'[m
 		Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'[m
 		Erro_Close      db      'Erro ao tentar fechar o ficheiro$'[m
[31m-		FichMenu			db	   'menu.TXT', 0[m
[32m+[m		[32mFichMenu		db	   'menu.TXT', 0[m[41m[m
 		Fich         	db      'moldura.TXT',0[m
 		HandleFich      dw      0[m
 		car_fich        db      ?[m
[36m@@ -124,16 +124,66 @@[m [mPASSA_TEMPO   ENDP[m
 [m
 ;********************************************************************************	[m
 [m
[32m+[m[32mMenu_Fich PROC[m[41m[m
[32m+[m[32m; abre ficheiro[m[41m[m
[32m+[m	[32mmov     ah,3dh			; vamos abrir ficheiro para leitura[m[41m [m
[32m+[m	[32mmov     al,0			; tipo de ficheiro[m[41m	[m
[32m+[m	[32mlea     dx,FichMenu		; nome do ficheiro[m[41m[m
[32m+[m	[32mint     21h			     ; abre para leitura[m[41m [m
[32m+[m	[32mjc      erro_abrirmenu		; pode aconter erro a abrir o ficheiro[m[41m [m
[32m+[m	[32mmov     HandleFich,ax		; ax devolve o Handle para o ficheiro[m[41m [m
[32m+[m	[32mjmp     ler_ciclomenu		; depois de abero vamos ler o ficheiro[m[41m [m
[32m+[m[41m[m
[32m+[m	[32merro_abrirmenu:[m[41m[m
[32m+[m	[32mmov     ah,09h[m[41m[m
[32m+[m	[32mlea     dx,Erro_Open[m[41m[m
[32m+[m	[32mint     21h[m[41m[m
[32m+[m	[32mjmp     sai[m[41m[m
[32m+[m[41m[m
[32m+[m	[32mler_ciclomenu:[m[41m[m
[32m+[m	[32mmov     ah,3fh			; indica que vai ser lido um ficheiro[m[41m [m
[32m+[m	[32mmov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto[m[41m [m
[32m+[m	[32mmov     cx,1			; numero de bytes a ler[m[41m [m
[32m+[m	[32mlea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)[m[41m[m
[32m+[m	[32mint     21h			; faz efectivamente a leitura[m[41m[m
[32m+[m	[32mjc	    erro_lermenu		; se carry é porque aconteceu um erro[m[41m[m
[32m+[m	[32mcmp	    ax,0		     ;EOF?	verifica se já estamos no fim do ficheiro[m[41m [m
[32m+[m	[32mje	    fecha_ficheiromenu	; se EOF fecha o ficheiro[m[41m [m
[32m+[m	[32mmov     ah,02h			; coloca o caracter no ecran[m[41m[m
[32m+[m	[32mmov	    dl,car_fich	; este é o caracter a enviar para o ecran[m[41m[m
[32m+[m	[32mint	    21h			; imprime no ecran[m[41m[m
[32m+[m	[32mjmp	    ler_ciclomenu		; continua a ler o ficheiro[m[41m[m
[32m+[m[41m[m
[32m+[m	[32merro_lermenu:[m[41m[m
[32m+[m	[32mmov     ah,09h[m[41m[m
[32m+[m	[32mlea     dx,Erro_Ler_Msg[m[41m[m
[32m+[m	[32mint     21h[m[41m[m
[32m+[m[41m[m
[32m+[m	[32mfecha_ficheiromenu:					; vamos fechar o ficheiro[m[41m [m
[32m+[m	[32mmov     ah,3eh[m[41m[m
[32m+[m	[32mmov     bx,HandleFich[m[41m[m
[32m+[m	[32mint     21h[m[41m[m
[32m+[m	[32mjnc     sai[m[41m[m
[32m+[m[41m[m
[32m+[m	[32mmov     ah,09h			; o ficheiro pode não fechar correctamente[m[41m[m
[32m+[m	[32mlea     dx,Erro_Close[m[41m[m
[32m+[m	[32mInt     21h[m[41m[m
[32m+[m	[32msai:	  RET[m[41m[m
[32m+[m[32mMenu_Fich	endp[m[41m[m
[32m+[m[41m[m
[32m+[m[41m[m
 [m
 [m
 Imp_Fich	PROC[m
 [m
[32m+[m[41m[m
[32m+[m[41m[m
 ;abre ficheiro[m
 [m
         mov     ah,3dh			; vamos abrir ficheiro para leitura [m
         mov     al,0			; tipo de ficheiro	[m
[31m-        lea     dx,FichMenu			; nome do ficheiro[m
[31m-        int     21h			; abre para leitura [m
[32m+[m[32m        lea     dx,Fich		; nome do ficheiro[m[41m[m
[32m+[m[32m        int     21h			     ; abre para leitura[m[41m [m
         jc      erro_abrir		; pode aconter erro a abrir o ficheiro [m
         mov     HandleFich,ax		; ax devolve o Handle para o ficheiro [m
         jmp     ler_ciclo		; depois de abero vamos ler o ficheiro [m
[36m@@ -366,6 +416,13 @@[m [mfim:		goto_xy		40,23[m
 [m
 move_snake ENDP[m
 [m
[32m+[m[41m[m
[32m+[m[32mone proc[m[41m[m
[32m+[m	[32mcall		Imp_Fich[m[41m[m
[32m+[m	[32mcall		move_snake[m[41m[m
[32m+[m[32mone endp[m[41m[m
[32m+[m[41m[m
[32m+[m[41m[m
 ;#############################################################################[m
 ;             MAIN[m
 ;#############################################################################[m
[36m@@ -374,10 +431,19 @@[m [mMENU    Proc[m
 		MOV     	DS,AX[m
 		MOV		AX,0B800H[m
 		MOV		ES,AX		; ES indica segmento de memória de VIDEO[m
[31m-		CALL 		APAGA_ECRAN [m
[31m-		CALL		Imp_Fich[m
[31m-		call		move_snake[m
[31m-		[m
[32m+[m		[32mcall 	APAGA_ECRAN[m[41m [m
[32m+[m		[32mcall      Menu_Fich[m[41m[m
[32m+[m[32mTecla:[m[41m[m
[32m+[m		[32mmov		ah, 08h[m[41m[m
[32m+[m		[32mint		21h[m[41m[m
[32m+[m		[32mcmp		AL, '1'[m[41m[m
[32m+[m		[32mjne		not_one[m[41m[m
[32m+[m		[32mjmp		one[m[41m[m
[32m+[m[32mnot_one:[m[41m [m
[32m+[m		[32mcmp		AL, 'x'[m[41m[m
[32m+[m		[32mjne		Tecla[m[41m[m
[32m+[m		[32mjmp 		fim[m[41m[m
[32m+[m[32mfim:[m[41m	[m
 		MOV		AH,4Ch[m
 		INT		21h[m
 MENU    endp[m
[1mdiff --git a/menu.txt b/menu.txt[m
[1mindex 97e3f31..e91fc9d 100644[m
[1m--- a/menu.txt[m
[1m+++ b/menu.txt[m
[36m@@ -1,16 +1,15 @@[m
[31m-                            S N A K E [m
  _____________________________________________________________________[m
[32m+[m[32m||								     ||[m[41m       [m
[32m+[m[32m||		          			          	     ||[m
 ||								     ||[m
[32m+[m[32m||								     ||[m[41m        [m
[32m+[m[32m||			SNAKE	          			     ||[m
 ||								     ||[m
 ||								     ||[m
[31m-||								     ||[m
[31m-||								     ||[m
[31m-||								     ||[m
[31m-||								     ||[m
[31m-||			NOVO JOGO(1)					     ||[m
[31m-||			VELOCIDADE PADRAO  					     ||[m
[31m-||								     ||[m
[31m-||								     ||[m
[32m+[m[32m||			NOVO JOGO                (1)                 ||[m
[32m+[m[32m||			HISTORICO DE JOGOS       (2)                 ||[m
[32m+[m[32m||			VALORES ESTATISTICOS     (3)                 ||[m
[32m+[m[32m||			SAIR                     (X)                 ||[m
 ||								     ||[m
 ||								     ||[m
 ||								     ||[m
[36m@@ -21,4 +20,4 @@[m
 ||								     ||[m
 ||								     ||[m
 ||___________________________________________________________________||[m
[31m-                 VELOCIDADE: (teclas 1, 2, 3 e 4)[m
[41m+                 [m
[1mdiff --git a/moldura.TXT b/moldura.TXT[m
[1mindex 60d9a87..7c376ad 100644[m
[1m--- a/moldura.TXT[m
[1m+++ b/moldura.TXT[m
[36m@@ -4,7 +4,7 @@[m
 ||								     ||[m
 ||								     ||[m
 ||								     ||[m
[31m-||			()					     ||[m
[32m+[m[32m||			()				asd	     ||[m[41m[m
 ||								     ||[m
 ||						[]		     ||[m
 ||								     ||[m
