
GOTO_XY		MACRO	POSX,POSY
			MOV	AH,02H
			MOV	BH,0
			MOV	DL,POSX
			MOV	DH,POSY
			INT	10H
ENDM

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM


.8086
.model small
.stack 2048h

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS
	

DSEG    SEGMENT PARA PUBLIC 'DATA'

;********************************************************************************
;  						Variaveis para Horas   
;********************************************************************************
	
		STR12	 		DB 		"            "					; String para 12 digitos	
		NUMERO			DB		"                    $" 		; String destinada a guardar o número lido
		NUM_SP			db		"                    $" 		; PAra apagar zona de ecran
		DDMMAAAA 		db		"                     "
		Horas			dw		0								; Vai guardar a HORA actual
		Minutos			dw		0								; Vai guardar os minutos actuais
		Segundos		dw		0								; Vai guardar os segundos actuais
		Old_seg			dw		0								; Guarda os últimos segundos que foram lidos
		POSy			db		10								; a linha pode ir de [1 .. 25]
		POSx			db		40								; POSx pode ir [1..80]	
		NUMDIG			db		0								; controla o numero de digitos do numero lido
		MAXDIG			db		4								; Constante que define o numero MAXIMO de digitos a ser aceite
		Game_Time_s		dw		0								; segundos
		Game_Time_m		dw		0								; minutos
		Game_Time_h		dw		0								; horas

;*********************************************************************************
;  						Variaveis para Top 10   
;*********************************************************************************

		Top10_Classificacao		db  80 dup('_'),13,10
								db   '                              TOP 10 - Classificacao                      ',13,10
								db   80 dup('_'),13,10	     
								db   ' C      Nome   Tempo                    ',13,10
								db   "____________________",13,10
								
		Top10_jogadores			db	 " 1","      Ana ","  m  s  ",13,10
								db	 " 2","      Ana ","  m  s  ",13,10
								db   " 3","          ","  m  s  ",13,10
								db   " 4","          ","  m  s  ",13,10
								db   " 5","          ","  m  s  ",13,10
								db   " 6","          ","  m  s  ",13,10
								db   " 7","          ","  m  s  ",13,10
								db   " 8","          ","  m  s  ",13,10
								db   " 9","          ","  m  s  ",13,10
								db   "10","          ","  m  s  ",13,10
								db  '$',0

;********************************************************************************		
; Variaveis para escrever no ficheiro
;********************************************************************************

		Top10_File				db	'Top10.TXT',0
		fhandle 				dw	0
		msgErrorCreate_File		db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite_File		db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose_File		db	"Ocorreu um erro no fecho do ficheiro!$"

;********************************************************************************
; 						variaveis para Ler ficheiro TOP 10
;********************************************************************************
		
		Erro_Open				db	'Erro ao tentar abrir o ficheiro$'
		Erro_Ler_Msg			db	'Erro ao tentar ler do ficheiro$'
		Erro_Close				db	'Erro ao tentar fechar o ficheiro$'	
		HandleFile_Read			dw	0
		caracter_TOP10			db	?
		contador				dw	0
		linha					db	0
		line					db	0
		line2					db	0
		total_bytes				db	22
		m1						db	11
		m2						db  12
		s1						db 	14 
		s2                      db 	15
		pos1					db	?
		pos2					db  ?
		pos3     				db  ?
		pos4 					db  ?
		classificacao_top10   	db  ?
		nome_top10				db 	10 dup(?)
		tempo_top10				db 	8  dup(?) 	
		

;*********************************************************************************
; 						variaveis para gravar jogador
;*********************************************************************************	
		
		nome_jogador			db 10
								db ?
								db 8 dup(0)
								
								
;*********************************************************************************
;				Variavel onde grava string que pede nome do jogador
;*********************************************************************************
		
		pede_jogador 			db	"Indique o nome do jogador $",0
			
			
			
;********************************************************************************
;  					Variavel para  Funcao  trata_min_segundos   
;********************************************************************************

		tempo_total_jogador db  ?
		horasb				db  2 dup(0)
		minutosb			db  2 dup(0)
		segundosb			db  2 dup(0)
		


;*********************************************************************************
;			Variaveis para verificar e trocar se for necessario o jogo
;*********************************************************************************			
			
		
		temp_nome_jogador 	db 	"          "
		temp_seg	db	"  "
		temp_min	db  "  "


		
;********************************************************************************
;  							Fim das variaveis
;********************************************************************************
DSEG    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:CSEG, DS:DSEG, SS:PILHA


;********************************************************************************
;							escreve para ficheiro
;********************************************************************************	

Escreve_dados_Ficheiro_Top10 PROC

		mov	ah, 3ch						; abrir ficheiro para escrita 
		mov	cx, 00H						; tipo de ficheiro
		lea	dx, Top10_File				; dx contem endereco do nome do ficheiro 
		int	21h							; abre efectivamente e AX vai ficar com o Handle do ficheiro 
		jnc	escreve						; se não acontecer erro vai vamos escrever
		
		mov	ah, 09h						; Aconteceu erro na leitura
		lea	dx, msgErrorCreate_File	
		int	21h
		
		jmp	fim

	escreve:

		mov	bx, ax						; para escrever BX deve conter o Handle 
		mov	ah, 40h						; indica que vamos escrever 
			
		lea	dx, Top10_jogadores			; Vamos escrever o que estiver no endereço DX
		mov	cx, 220						; vamos escrever multiplos bytes duma vez só
		int	21h							; faz a escrita 
		jnc	close						; se não acontecer erro fecha o ficheiro 
		
		mov	ah, 09h
		lea	dx, msgErrorWrite_File
		int	21h
		
	close:

		mov	ah,3eh						; indica que vamos fechar
		int	21h							; fecha mesmo
		jnc	fim							; se não acontecer erro termina
		
		mov	ah, 09h
		lea	dx, msgErrorClose_File
		int	21h
		
	fim:
		ret 
		
Escreve_dados_Ficheiro_Top10 ENDP

;****************************************************************************************
;              					  LÊ do ficheiro
;****************************************************************************************
	
copia_linha_top10_para_vetor proc
	
	push ax
	
	
	;Call Preenche_top10_pos_jogo
	
	mov al, classificacao_top10               	   	;                   	
	mov Top10_jogadores[0], al					  	;
													;
	mov al, nome_top10								;
	mov Top10_jogadores[1], al						; preenche as respetivas linhas com os dados de cada classificaçao
													;
	mov al, tempo_top10								;
	mov Top10_jogadores[2], al						;
	
	
	pop ax
	
copia_linha_top10_para_vetor endp		
		
; funçao principal para ler dados 	do ficheiro	

Ler_Dados_Ficheiro_Top10 PROC
	
		push ax
		push bx
		push cx
		push dx
		
													; ;abre ficheiro
		mov     ah,3dh
		mov     al,0
		lea     dx,Top10_File
		int     21h									; Chama a rotina de abertura de ficheiro (AX fica com Handle)
		jc      erro_abrir
		mov     HandleFile_Read,ax						; para onde aponta o ponteiro na memoria;
		
	inicio:
	
		xor	    si,si								; inicio da leitura do ficheiro vai chamar o ciclo1
		jmp		ler_ciclo1
		
	resete_contador:								
		
		mov     contador,0							; reseta contador para iniciar a leitura no inicio da nova linha
		inc 	linha	
		jmp		ler_ciclo1
				
	ler_classificacao:
	
		mov     	cx, 2							; vai ler apenas um byte de cada vez
		lea     	dx, classificacao_top10			; DX fica a apontar para o caracter lido
		mov 		contador,1
		jmp 		ler_ciclo2
	
	ler_nome:
	
		mov			cx, 10							;; vai ler 10 bytes de cada vez, ara preencher o nome
		lea 		dx, nome_top10
		mov 		contador,2
		jmp 		ler_ciclo2
		
	ler_tempo:
	
		mov 		cx, 8							;; vai ler 8 bytes de cada vez para preencher a hora
		lea			dx, tempo_top10
		jmp 		ler_ciclo2
		
		
	ler_ciclo1:									; contador vai servir para defenir o numero de bits que se vai ler do ficheiro de cada vez;
	
		cmp			contador,0                  ; se contador for igual a 0 vai para ler_classificaçao
		je			ler_classificacao
		
		cmp			contador, 1					; se contador for igual a 1 vai para ler nome
		je			ler_nome
		
		cmp 		contador, 2					; se contador for igual a 2 vai para ler tempo
		je  		ler_tempo
		
	ler_ciclo2:
	
		mov     	ah, 3fh							; ficheiro aberto para leitura
		mov     	bx, HandleFile_Read
		
		int     	21h								; mostra erro se nao conseguir abrir o ficheiro
		jc	    	erro_ler
		
		cmp		    ax, 0							; verifica se já chegou o fim de ficheiro EOF? 
		je			fecha_ficheiro					; se chegou ao fim do ficheiro fecha e sai
					
		cmp			caracter_TOP10, 13				; verifica se já chegou ao fim da linha do ficheiro, 
		je			resete_contador					; se chegou ao fim  
	
		cmp 		linha, 10
		je  		Fim	
		jmp			ler_ciclo1						; vai ler o próximo caracter
		
	erro_abrir:										
	
		mov    	ah,09h
		lea     dx,Erro_Open
		int     21h
		jmp     Fim

	erro_ler:
	
		mov     ah,09h
		lea     dx,Erro_Ler_Msg
		int     21h
		   
	fecha_ficheiro:
	
		mov     ah,3eh
		mov     bx,HandleFile_Read
		int     21h
		jnc 	fim

		mov     ah,09h
		lea     dx,Erro_Close
		Int     21h
		jmp 	Fim
		
	Fim:
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		ret
			
Ler_Dados_Ficheiro_Top10 ENDP


;****************************************************************************************
;              			VAi inserir tempo no top 10
;****************************************************************************************
top10_incrementa_novo_jogador proc
	
	ciclo_horas:
		
		;faz contas para saltar de linha
		mov bl, line
		mov al, total_bytes
		mul bl

		add ax, 12 	;adiciona o deslocamento as linhas
		mov si,ax	; coloca a posicao a alterar em si

		mov bl, minutosb[0]
		mov Top10_jogadores[si],bl

		inc si
		mov bl, minutosb[1]
		mov Top10_jogadores[si],bl
		
		add si,2
		mov bl, segundosb[0]
		mov Top10_jogadores[si],bl
		
		inc si
		mov bl, segundosb[1]
		mov Top10_jogadores[si],bl
		inc si


		mov bl, line
		mov al, total_bytes
		mul bl

		add ax,2
		mov di,2
		mov si,ax		
		ciclo_nome:
						
			mov al,nome_jogador[di]
			mov Top10_jogadores[si],al
			inc di
			inc si
			cmp di,10
			jne ciclo_nome
			
			
		inc line
		cmp line,10
		jne ciclo_horas
		
		ret
		
top10_incrementa_novo_jogador ENDP


;****************************************************************************************
;                 Pede nome ao utlizador:
;****************************************************************************************
obtem_nome_jogador macro str

	call apaga_ecran
	goto_xy	24,10
	mov ah,09h
	lea dx,str
	int 21h
	goto_xy	34,11

	mov ah, 0Ah
	mov dx,offset nome_jogador			; onde fica guardado o nome do jogador
	int 21h

										;CHANGE CHR(12) BY '$'.
	mov si, offset nome_jogador + 1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 						;MOVE LENGTH TO CL.
	mov ch, 0      						;CLEAR CH TO USE CX. 
	inc cx 								;TO REACH CHR(6).
	add si, cx 							;NOW SI POINTS TO CHR(12).
	mov al, '$'
	mov [si], al 						;REPLACE CHR(12) BY '$'.            

  ;DISPLAY STRING.                   
    ;mov ah, 9 ;SERVICE TO DISPLAY STRING.
	;mov dx, offset fname + 2 ;MUST END WITH '$'.
    ;int 21h
endm

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 


;********************************************************************************
;ROTINA PARA APAGAR ECRAN
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

;********************************************************************************
; LEITURA DE UMA TECLA DO TECLADO 
; LE UMA TECLA	E DEVOLVE VALOR EM AH E AL
; SE ah=0 É UMA TECLA NORMAL
; SE ah=1 É UMA TECLA EXTENDIDA
; AL DEVOLVE O CÓDIGO DA TECLA PREMIDA
;********************************************************************************
LE_TECLA	PROC

sem_tecla:

		call Trata_Horas

		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		goto_xy	POSx,POSy
		
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

LE_TECLA	ENDP

;**********************************************************************************
;			  ---	incrementa o tempo de jogo do zero  ---
;**********************************************************************************

; aqui incrementa o tempo a começar do zero;

Incrementa_Segundos PROC
	
	inc_segundos:
											;
			cmp Game_Time_s, 60				;
			je inc_minutos					;
			inc Game_Time_s					;
			jmp Fim							;
											;
	inc_minutos:							;

			inc Game_Time_m					;
			mov Game_Time_s, 0				; 
			cmp Game_Time_m, 60				;  Começa a contar o tempo de jogo do zero
			je inc_horas					;
			jmp Fim							;
											;
	inc_horas:								;

			mov Game_Time_s,0				;
			mov Game_Time_m,0				;
			jmp Fim	
			;
	Fim:
											;
		ret									;
		
Incrementa_Segundos ENDP

;########################################################################
;			  ---	começa a contar o tempo de jogo do zero  ---
;########################################################################

Trata_Horas PROC

			PUSHF
			PUSH AX
			PUSH BX
			PUSH CX
			PUSH DX		

			CALL 	Ler_TEMPO			; Horas MINUTOS e segundos do Sistema
			
			MOV		AX, Segundos
			cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
			je		fim_horas			; Se a hora não mudou desde a última leitura sai.
			mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
			
			call	incrementa_segundos ; vai contar o tempo que o utilizador demora a completar o labirinto
			
			mov 	ax,Game_Time_h
			MOV		bl, 10     
			div 	bl
			add 	al, 30h				; Caracter Correspondente às dezenas
			add		ah,	30h				; Caracter Correspondente às unidades
			mov 	horasb[0],al
			mov 	horasb[1],ah
			MOV 	STR12[0],al			; 
			MOV 	STR12[1],ah
			MOV 	STR12[2],'h'		
			MOV 	STR12[3],'$'
			GOTO_XY 66,14				; alterar a posiçao das horas coluna/linha
			MOSTRA STR12
			
			mov 	ax,Game_Time_m		; variavel que vai ser incrementada atraves da funçao incrementa tempo
			MOV 	bl, 10     
			div 	bl
			add 	al, 30h				; Caracter Correspondente às dezenas
			add		ah,	30h				; Caracter Correspondente às unidades
			mov 	minutosb[0],al
			mov 	minutosb[1],ah
			MOV 	STR12[0],al			; 
			MOV 	STR12[1],ah
			MOV 	STR12[2],'m'		
			MOV 	STR12[3],'$'
			GOTO_XY	70,14				; alterar a posiçao das min coluna/linha
			MOSTRA STR12				; mostra min 
			
			mov 	ax,Game_Time_s		; variavel que vai ser incrementada atraves da funçao incrementa tempo
			MOV 	bl, 10     
			div 	bl
			add 	al, 30h				; Caracter Correspondente às dezenas
			add		ah,	30h				; Caracter Correspondente às unidades
			mov 	segundosb[0],al
			mov 	segundosb[1],ah
			MOV 	STR12[0],al			; 
			MOV 	STR12[1],ah
			MOV 	STR12[2],'s'		
			MOV 	STR12[3],'$'
			GOTO_XY	74,14				; alterar a posiçao das segundos coluna/linha
			MOSTRA STR12				; 
			

			
			

			GOTO_XY	64,13				; posiçao do nome
			MOSTRA nome_jogador
			
								
	fim_horas:	
		
			goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
			
			POPF
			POP DX		
			POP CX
			POP BX
			POP AX
			RET		
				

Trata_Horas ENDP

;********************************************************************************
;            						Mostra no Ecran
;********************************************************************************

display_TOP10 proc

	;apaga ecra e posiciona o cursor no inicio.
	call apaga_ecran
	goto_xy 0,0

	;mostra menu
	mov  ah,09h
  	lea  dx,Top10_Classificacao
  	int  21h
	
	;Pede input ao utilizador.
	goto_xy	21,19

FIM:

	ret
	
display_TOP10 endp

;###########################################################################
;									Main
;###########################################################################

Menu_Hora    Proc

	MOV     	AX,DSEG
	MOV     	DS,AX
	MOV			AX,0B800H
	MOV			ES,AX		; ES É PONTEIRO PARA MEM VIDEO

	CALL 		APAGA_ECRAN 
	
	;call Escreve_dados_Ficheiro_Top10
	obtem_nome_jogador pede_jogador
	mov ah,1
	call LE_TECLA
	;call Ler_Dados_Ficheiro_Top10
	call top10_incrementa_novo_jogador 
	CALL APAGA_ECRAN
	call display_TOP10

	
			
	MOV			AH,4Ch
	INT		21h
	
Menu_Hora    endp
cseg	ends
end     Menu_Hora