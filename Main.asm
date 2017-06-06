.8086
.model small
.stack 2048

dseg	segment para public 'data'
		
		POSy		db	0	; a linha pode ir de [1 .. 25]
		POSx		db	0	; POSx pode ir [1..80]

		;####################################################################################################################
		;Variaveis relativas ao MENUS
		menu 			db	80 dup ('_'),13,10,10
						db	'                   	 	L A B I R I N T O!',13,10,10
						db	80 dup ('_'),13,10,10
    					db 	'			  1. Jogar!',13,10,10
						db 	'			  2. Configuracoes do jogo!',13,10,10
						db 	'			  3. TOP 10!',13,10,10
						db 	'			  4. Sair.',10,10,10
						db	'Selecione uma opcao: ',13,10
						db	'$',0
		
		menuLabirintos	db	80 dup ('_'),13,10,10
						db  '				Configuracoes do Jogo',13,10,10
						db	80 dup ('_'),13,10,10
    					db 	'			  1. Carregar Labirinto por omissao.',13,10,10
						db 	'			  2. Criar Labirinto.',13,10,10
						db 	'			  3. Editar Labirinto.',13,10,10
						db 	'			  4. Voltar.',10,10,10
						db	'Selecione uma opcao: ',13,10
						db	'$',0

	    tecla			db	?	;variavel que irá conter a escolha do utilizador!
		
		;####################################################################################################################
		;Variaveis para o menu de criacao de labirintos.
		car		db	?
		cria_lab_instrucoes	db	' 1 - ',219,' 2 - ',178,' 3 - ',177,' 4 - ',176,' 5 - apaga  6 - Inicio  7 - fim  g - Guarda  ESC - Sair',13,10
							db	80 dup('-'),'$',0

		;Variaveis para gestão do ficheiro de labirinto
		fhandle			dw	0
		buffer			dw	?
		
		;####################################################################################################################
		msgAskFich		db	"Indique o nome do ficheiro $",0
		msgAskNovoFich	db	"Indique o nome do novo ficheiro $",0
		msgAskPlayer 	db	"Indique o nome do jogador $",0

		fname	db 12
   				db ?
   				db 12 dup(0)

		
		jname	db 12
   				db ?
   				db 12 dup(0)

		default db 'def.txt',0
		
		msgErrorOpen	db	"Ocorreu um erro na abertura do fichero!$",0
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$",0
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$",0
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$",0
		msgErrorRead	db	"Ocorreu um erro no ao ler do ficheiro!$",0
		
		
		;####################################################################################################################
		;Variaveis altera mapa omissao

		Warning			db	"			  | 1 - Comfirmar | 2 - Cancelar |",13,10
						db	80 dup('-'),13,10
						db	'$',0
	
		lista_labirintos	db  '		     Labirintos disponiveis		 ',13,10,10,10
							db	'		    A.txt	B.txt	C.txt	D.txt	E.txt','$',0
		
		;####################################################################################################################
		;Variaveis do jogo

		Cor			db	7	; Guarda os atributos de cor do caracter
		POSya		db	3	; Posi��o anterior de y
		POSxa		db	22	; Posi��o anterior de x
		nome_jogar	db	12 dup(?) 	; nome do utilizador

		menuJogo	db	'	| Direita ',16,' |  Esquerda ',17,' | Cima ',30,' | Baixo ',31,' | ESC - Desistir |$',0

		verificax	db 	0
		verificay	db	0
		
		msgErrorFileName	db	'Nome do ficheiro invalido!$'
		msgErrorName	db	'Nome de jogador invalido!$'
		msgInfoErroOpen db	'Sera aberto o labirinto por defeito!$'
		msgInfo			db 	'Precione ENTER para carregar o mapa por defeito!$'
		msgErrorInicio 	db	'Nao existe um inicio no labirinto selecionado!$'
		msgErrorFim		db	'Nao existe um fim no labirinto selecionado!$'
		msgErrorOpenMap	db	'Nao foi possivel abrir o labirinto!$'
		msgGanhou		db	'Ganhou!$'
		

		;####################################################################################################################
		;Variaveis do EXTRA

		 POSx_Saved	db	0
		 POSy_Saved	db	0

		 ; The compass can vary from 4 values
		 ; 0 - NORTH
		 ; 1 - SOUTH
		 ; 2 - WEST
		 ; 3 - EAST
		 compass db 0
		 
		 ; The position variables can vary from 0's and 1's meaning there is a wall if it's at 1
		 ; These will be updated at every step along with the orientation
		 straight	db	0
		 back	db	0
		 left	db 	0
		 right	db 	0

		;####################################################################################################################
		;Variaveis do temporizador

		STR12	 		DB 		"            "					; String para 12 digitos	
		NUMERO			DB		"                    $" 		; String destinada a guardar o número lido
		NUM_SP			db		"                    $" 		; PAra apagar zona de ecran
		DDMMAAAA 		db		"                     "
		Horas			dw		0								; Vai guardar a HORA actual
		Minutos			dw		0								; Vai guardar os minutos actuais
		Segundos		dw		0								; Vai guardar os segundos actuais
		Old_seg			dw		0								; Guarda os últimos segundos que foram lidos
		NUMDIG			db		0								; controla o numero de digitos do numero lido
		MAXDIG			db		4								; Constante que define o numero MAXIMO de digitos a ser aceite
		Game_Time_s		dw		0								; segundos
		Game_Time_m		dw		0								; minutos
		Game_Time_h		dw		0								; horas

		;####################################################################################################################
		;Variaveis do TOP 10

;*********************************************************************************
;  						Variaveis para Top 10   
;*********************************************************************************

		Top10_Classificacao		db  80 dup('_'),13,10
								db   '                              TOP 10 - Classificacao                      ',13,10
								db   80 dup('_'),13,10	     
								db   ' Tempo   Nome                    ',13,10
								db   "______________",13,10
								
		Top10_jogadores			db	 "   m  s  ","          ",13,10
								db	 " 00m45s  ","joao      ",13,10
								db   " 00m50s  ","Francis   ",13,10
								db   " 01m05s  ","Cristina  ",13,10
								db   " 01m10s  ","Maria     ",13,10
								db   " 01m15s  ","Joana     ",13,10
								db   " 01m25s  ","Margarida ",13,10
								db   " 01m30s  ","Jose      ",13,10
								db   " 01m35s  ","Toino     ",13,10
								db   "   m  s  ","          ",13,10
								db  '$',0

;********************************************************************************		
; Variaveis para escrever no ficheiro
;********************************************************************************

		Top10_File				db	'Top10.TXT',0
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
		contador				dw	1
		linha					db	0
		line					db	0
		line2					db	0
		total_bytes				db	21
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
		
		nome_jogador			db 12
								db ?
								db "          "
		nome_com_sifrao			db "         "
		
;*********************************************************************************
;				Variavel onde grava string que pede nome do jogador
;*********************************************************************************
		
		pedir_jogador 			db	"Indique o nome do jogador $",0


;*********************************************************************************
;				Variaveis para guardar tempo em bytes
;*********************************************************************************
		
		horasb				db  2 dup(0)
		minutosb			db  2 dup(0)
		segundosb			db  2 dup(0)
		

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

;########################################################################
;							Go to XY Macro
;########################################################################

goto_xy	macro	POSx,POSy
		mov		ah,02h	;indica que é para mudar o cursor.
		mov		bh,0	;Numero página.
		mov		dl,POSx	;Pos X do ecrã, vai de 0 a 80
		mov		dh,POSy ;Pos Y do ecrã, vai de 0 a 25
		int		10h		;interrupt call
endm

;########################################################################
;						  Mostra string - Macro
;########################################################################

MOSTRA MACRO str

	mov ah,09h
	lea dx, str 
	int 21h

endm

;########################################################################
;						ROTINA PARA APAGAR ECRAN
;########################################################################

apaga_ecran	proc
			xor		bx,bx
			mov		cx,25*80

	apaga:
			mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp

;########################################################################
;                          Rotinas de TEMPO 
;########################################################################

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
Ler_TEMPO ENDP 

;************************************************************************
; LEITURA DE UMA TECLA DO TECLADO 
; LE UMA TECLA	E DEVOLVE VALOR EM AH E AL
; SE ah=0 É UMA TECLA NORMAL
; SE ah=1 É UMA TECLA EXTENDIDA
; AL DEVOLVE O CÓDIGO DA TECLA PREMIDA
;************************************************************************

LE_TECLA proc

		cmp	ah,0
		je	espera_tecla

	mostra_horas:
			call Trata_Horas
			
			mov	ah,0Bh
			int 21h
			
			cmp al,0
			je	mostra_horas

			goto_xy	POSx,POSy

	espera_tecla:
			mov	ah,08h
			int	21h
			mov	ah,0

			cmp	al,0
			jne	SAI_TECLA
			
			mov	ah, 08H
			int	21h
			
			mov	ah,1
	SAI_TECLA:	
			ret

LE_TECLA endp

;########################################################################
;			  ---	começa a contar o tempo de jogo do zero  ---

; aqui incrementa o tempo a começar do zero;
Incrementa_Segundos PROC
		
	inc_segundos:

			cmp Game_Time_s, 60
			je inc_minutos
			inc Game_Time_s
			jmp Fim
			
	inc_minutos:
			inc Game_Time_m
			mov Game_Time_s, 0
			cmp Game_Time_m, 60
			je inc_horas
			jmp Fim
			
	inc_horas:
			mov Game_Time_s,0
			mov Game_Time_m,0
			jmp Fim
	Fim:
		ret
		
Incrementa_Segundos ENDP

;########################################################################
;			  ---	começa a contar o tempo de jogo do zero  ---

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
			MOV 	STR12[0],al			; 
			MOV 	STR12[1],ah
			MOV 	STR12[2],'s'		
			MOV 	STR12[3],'$'
			GOTO_XY	74,14				; alterar a posiçao das segundos coluna/linha
			MOSTRA STR12				; 
								
	fim_horas:		
			goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
			
			POPF
			POP DX		
			POP CX
			POP BX
			POP AX
			RET		
			

Trata_Horas ENDP

;########################################################################
;							Funcoes do jogo
;########################################################################
;Pede string ao utilizador

obtem_string_jogo macro str
	;call apaga_ecran
	
	goto_xy 15,8
	MOSTRA	msgInfo

	goto_xy	24,10
	MOSTRA str

	goto_xy	34,11

	mov ah, 0Ah
	mov dx,offset fname
	int 21h
	
	mov si, offset fname + 1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 				;MOVE LENGTH TO CL.
	mov ch, 0      				;CLEAR CH TO USE CX. 
	inc cx 						;TO REACH CHR(6).
	add si, cx 					;NOW SI POINTS TO CHR(12).
	mov al, ' '
	mov [si], al 				;REPLACE CHR(12) BY '$'.            

endm

obtem_string macro str
	call apaga_ecran
	goto_xy	24,10
	MOSTRA	str
	goto_xy	34,11

	mov ah, 0Ah
	mov dx,offset fname
	int 21h
	
	mov si, offset fname + 1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 				;MOVE LENGTH TO CL.
	mov ch, 0      				;CLEAR CH TO USE CX. 
	inc cx 						;TO REACH CHR(6).
	add si, cx 					;NOW SI POINTS TO CHR(12).
	mov al, ' '
	mov [si], al 				;REPLACE CHR(12) BY '$'.            

endm

obtem_string_nome_jogador macro str
	call apaga_ecran

	goto_xy	24,10
	mov ah,09h
	lea dx,str
	int 21h
	goto_xy	34,11

	mov ah, 0Ah
	mov dx,offset jname
	int 21h
	
	mov si, offset jname + 1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 				;MOVE LENGTH TO CL.
	mov ch, 0      				;CLEAR CH TO USE CX. 
	inc cx 						;TO REACH CHR(6).
	add si, cx 					;NOW SI POINTS TO CHR(12).
	mov al, ' '
	mov [si], al 				;REPLACE CHR(12) BY '$'.
endm

;########################################################################
;								JOGO
;########################################################################
; Inicia jogo
; Mostra instrucoes
; encontra ponto de inicio e posiciona cursor


;obtem caractere da posicao do cursor
obtem_car_ecra proc
	mov ah,08h
	mov bh,0
	int 10h

	ret
obtem_car_ecra endp

;Verifica se o mapa carregado para o ecra possui inicio
encontra_inicio proc

		mov verificax,20
		mov verificay,3

	ciclo:
		goto_xy verificax,verificay
		call obtem_car_ecra

		cmp al,73
		je	fim_sucesso

		cmp verificax,60
		je	resetx

		cmp verificay,23
		je 	fim_erro

		inc	verificax

		jmp ciclo

	resetx:
		mov verificax,20
		inc verificay
		jmp ciclo

	fim_sucesso:
		mov	al,verificax
		mov POSx,al

		mov al,verificay
		mov POSy,al

		mov	al,0
		jmp fim

	fim_erro:
		mov al,1

	fim:
		ret
encontra_inicio endp

;Verifica se o mapa carregado para o ecra possui fim
encontra_fim proc

		mov verificax,20
		mov verificay,3

	ciclo:
		goto_xy verificax,verificay
		call obtem_car_ecra

		cmp al,70
		je	fim_sucesso

		cmp verificax,60
		je	resetx

		cmp verificay,23
		je 	fim_erro

		inc	verificax
		
		jmp ciclo

	resetx:
		mov verificax,20
		inc verificay
		jmp ciclo

	fim_sucesso:
		mov	al,0
		jmp fim

	fim_erro:
		mov al,1		; se al estiver a 0 encontrou fim, se for 1 é por que nao encontrou e tem que sair do jogo

	fim:
		ret
encontra_fim endp

; Mostra instruções do jogo
draw_instruct_jogo proc

	goto_xy	0,0
	MOSTRA	menuJogo

	ret
draw_instruct_jogo endp

;obtem a proxima posicao do cursor 
get_nextPos proc
	goto_xy POSx,POSy

	mov ah,08h
	mov bh,0
	int 10h
	
	ret
get_nextPos endp

;mostra mapas que vem de origem com o jogo
mostra_mapas proc
	goto_xy 15,2

	MOSTRA lista_labirintos

	ret
mostra_mapas endp

jogo proc

	restart:
			; Reinicia o contador do jogo
			mov Game_Time_h,0
			mov Game_Time_m,0
			mov Game_Time_s,0
			
			; O labirinto por omissao estará guardado dento de um ficheiro chamado def.txt.
			; Este ficheiro so sera alterado quando for feita a alteracao no menu de alterar labirinto por omissao.

			obtem_string_nome_jogador msgAskPlayer
			cmp jname[2],32
			je erro_nome_jogador

			call apaga_ecran
			call mostra_mapas
			
			obtem_string_jogo msgAskFich			; pede labirinto para jogar
			cmp	fname[2],32							; verifica se o nome do labirinto = a espaço
			jne	abre_labirinto_selecionado			; se nao for espaço carrega o labirinto por defeito

	labirinto_default:
			call apaga_ecran
			call draw_instruct_jogo

			;verifica se houve erro ao abrir ou escrever o labirinto para o ecra			
			call abre_labirinto_default			; carrega o labirinto def.txt - labirinto por defeito para o ecra
			cmp al,1							; se houver erro vai para o fim e nao começa o jogo
			je erro_abrir_labirinto

			jmp inicio

	abre_labirinto_selecionado:
			call apaga_ecran
			call draw_instruct_jogo

			;verifica se houve erro ao abrir ou escrever o labirinto para o ecra
			call abre_labirinto
			cmp al,1							; se houver erro vai para o fim e nao comeca o jogo
			je erro_abrir_labirinto


	inicio:
			;verifica se o labirinto contem inicio em fim
			call encontra_inicio
			cmp	al,1
			je	erro_encontra_inicio

			call encontra_fim
			cmp al,1
			je	erro_encontra_fim
			
			;Inicializa posicoes anteriores ( pois no inicio do jogo nao existem posicoes anteriores )
			mov al,POSx
			mov POSxa,al

			mov al,POSy
			mov POSya,al

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
			mov	bh, 0			; numero da p�gina
			int	10h
			mov	Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			
	CICLO:
			
			goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
			mov	ah, 02h
			mov	dl, Car			; Repoe Caracter guardado
			int	21h

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h
			mov	bh,0			; numero da p�gina
			int	10h
			mov	Car, al			; Guarda o Caracter que est� na posi��o do Cursor

			goto_xy	POSx,POSy	; Vai para posi��o do cursor
			
			cmp Car,' '
			jne movimento
			jmp IMPRIME

	movimento:
			goto_xy	POSxa,POSya

			mov al,POSxa
			mov POSx,al
			mov al, POSya
			mov POSy,al
			
			jmp imprime

	IMPRIME:	
			mov	ah, 02h
			mov	dl, 190			; Coloca AVATAR
			int	21H
			
			goto_xy	POSx,POSy	; Vai para posi��o do cursor

			mov	al, POSx		; Guarda a posi��o do cursor
			mov	POSxa, al
			mov	al, POSy		; Guarda a posi��o do cursor
			mov POSya, al

	LER_SETA:
			mov ah,1
			call LE_TECLA

			cmp	ah, 1
			je	ESTEND

			cmp AL, 27			; ESCAPE
			je	FIM

			jmp	LER_SETA

	ESTEND:	
			cmp al,48h			; Cima
			jne	BAIXO

			cmp POSy,3
			je	LER_SETA

			dec	POSy
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	BAIXO:	cmp	al,50h			; Baixo
			jne	ESQUERDA

			cmp POSy,22
			je	LER_SETA

			inc POSy
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	ESQUERDA:
			cmp	al,4Bh			; Esquerda
			jne	DIREITA

			cmp POSx,20
			je LER_SETA
			
			dec	POSx
			call get_nextPos

			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	DIREITA:
			cmp	al,4Dh			; Direita
			jne	LER_SETA

			cmp POSx,59
			je	LER_SETA

			inc POSx
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	
	erro_encontra_inicio:
			call apaga_ecran

			goto_xy 15,10
			MOSTRA	msgErrorInicio

			mov	ah,0
			call LE_TECLA
			
			jmp fim

	erro_encontra_fim:
			call apaga_ecran

			goto_xy 15,10
			MOSTRA	msgErrorFim
						
			mov ah,0
			call LE_TECLA

			jmp fim

	erro_abrir_labirinto:

			goto_xy 21,12
			MOSTRA msgInfoErroOpen
			
			mov ah,0
			call LE_TECLA

			jmp labirinto_default

	erro_nome_jogador:
			call apaga_ecran
			
			goto_xy 15,10
			MOSTRA msgErrorName

			mov	ah,0
			call LE_TECLA

			jmp restart

	ganhou:
			; ALTERAR A MENSAGEM
			; adicionar tempo e nome do jogador no fim :)
			call apaga_ecran
			
			goto_xy	37,10
			MOSTRA msgGanhou

			goto_xy 15,11
			;MOSTRA tempoFim
			;MOSTRA nome do jogador
			
			mov	ah,0
			call LE_TECLA
	fim:
		ret

jogo endp

;########################################################################
;Procedure para encontrar fim do labirinto

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;
; 										Algorithm											 ;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;
;																							 ;
; 1 - O avatar ira mover-se para a direita sempre que possivel								 ;
; 2 - Se o caminho para direita estiver bloqueado, devera seguir em frente					 ;
; 3 - Se o caminho da direita e em frente estiverem bloqueados devera ir para a esquerda	 ;
; 4 - Se todos os caminhos estiverem bloqueados, o avatar devera voltar para tras.			 ;
;																							 ;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;


init_pos proc

	mov straight,0
	mov	back,0
	mov left,0
	mov right,0

	ret
init_pos endp

obtem_surroundings proc

		call init_pos

		dec POSy
		goto_xy POSx,POSy

		mov ah,08h
		mov bh,0
		int 10h
		
		cmp al,32
		jne voltar_atras
		mov straight,1

		inc POSy

	voltar_atras:
		
		inc POSy
		goto_xy POSx,POSy

		mov ah,08h
		mov bh,0
		int 10h
		
		cmp al,32
		jne esquerda
		mov back,1

		dec POSy

	esquerda:

		dec POSx
		goto_xy POSx,POSy

		mov ah,08h
		mov bh,0
		int 10h
		
		cmp al,32
		jne direita
		mov left,1

		inc POSx

	direita:

		inc POSx
		goto_xy POSx,POSy

		mov ah,08h
		mov bh,0
		int 10h
		
		cmp al,32
		jne fim
		mov right,1

		dec POSx

	fim:
		ret
obtem_surroundings endp

jogo_extra proc
			
			call apaga_ecran
			call mostra_mapas						; mostra escolha possiveis que vem com o jogo
			
			obtem_string_jogo msgAskFich			; pede labirinto para jogar
			cmp	fname[2],32							; verifica se o nome do labirinto = a espaço
			jne	abre_labirinto_selecionado			; se nao for espaço carrega o labirinto por defeito

	labirinto_default:
			call apaga_ecran

			;verifica se houve erro ao abrir ou escrever o labirinto para o ecra			
			call abre_labirinto_default			; carrega o labirinto def.txt - labirinto por defeito para o ecra
			cmp al,1							; se houver erro vai para o fim e nao começa o jogo
			je erro_abrir_labirinto

			jmp inicio

	abre_labirinto_selecionado:
			call apaga_ecran

			;verifica se houve erro ao abrir ou escrever o labirinto para o ecra
			call abre_labirinto
			cmp al,1							; se houver erro vai para o fim e nao comeca o jogo
			je erro_abrir_labirinto


	inicio:
			;verifica se o labirinto contem inicio em fim
			call encontra_inicio
			cmp	al,1
			je	erro_encontra_inicio

			call encontra_fim
			cmp al,1
			je	erro_encontra_fim
			
			;Inicializa posicoes anteriores ( pois no inicio do jogo nao existem posicoes anteriores )
			mov al,POSx
			mov POSxa,al

			mov al,POSy
			mov POSya,al

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
			mov	bh, 0			; numero da p�gina
			int	10h
			mov	Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			
	CICLO:
			
			goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
			mov	ah, 02h
			mov	dl, Car			; Repoe Caracter guardado
			int	21h

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h
			mov	bh,0			; numero da p�gina
			int	10h
			mov	Car, al			; Guarda o Caracter que est� na posi��o do Cursor

			goto_xy	POSx,POSy	; Vai para posi��o do cursor
			
			cmp Car,' '
			jne movimento
			jmp IMPRIME

	movimento:
			goto_xy	POSxa,POSya

			mov al,POSxa
			mov POSx,al
			mov al, POSya
			mov POSy,al
			
			jmp imprime

	IMPRIME:	
			mov	ah, 02h
			mov	dl, 190			; Coloca AVATAR
			int	21H
			
			goto_xy	POSx,POSy	; Vai para posi��o do cursor

			mov	al, POSx		; Guarda a posi��o do cursor
			mov	POSxa, al
			mov	al, POSy		; Guarda a posi��o do cursor
			mov POSya, al

	CIMA:	
			cmp al,48h			; Cima
			jne	BAIXO

			cmp POSy,3
			;je	LER_SETA

			dec	POSy
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	BAIXO:	cmp	al,50h			; Baixo
			jne	ESQUERDA

			cmp POSy,22
			;je	LER_SETA

			inc POSy
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	ESQUERDA:
			cmp	al,4Bh			; Esquerda
			jne	DIREITA

			cmp POSx,20
			;je LER_SETA
			
			dec	POSx
			call get_nextPos

			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	DIREITA:
			cmp	al,4Dh			; Direita
			;jne	LER_SETA

			cmp POSx,59
			;je	LER_SETA

			inc POSx
			call get_nextPos
			
			cmp	al,70
			je	ganhou

			cmp al,32
			jne movimento

			jmp	CICLO

	
	erro_encontra_inicio:
			call apaga_ecran

			goto_xy 15,10
			MOSTRA	msgErrorInicio

			mov	ah,0
			call LE_TECLA
			
			jmp fim

	erro_encontra_fim:
			call apaga_ecran

			goto_xy 15,10
			MOSTRA	msgErrorFim
						
			mov ah,0
			call LE_TECLA

			jmp fim

	erro_abrir_labirinto:

			goto_xy 21,12
			MOSTRA msgInfoErroOpen
			
			mov ah,0
			call LE_TECLA

			jmp labirinto_default

	ganhou:
			
			mov	ah,0
			call LE_TECLA
	fim:
		ret

jogo_extra endp

;########################################################################
;Procedure para alterar o labirinto por omissao

guarda_labirinto_default proc
		
		mov	ax,0B800h ;0B800h -> endereço para memoria de video 
		mov	es,ax	  ;colocado em es -> aponta para um sitio menos cs ds ss
		
		mov	ah, 3ch						; abrir ficheiro para escrita 
		mov	cx, 00H						; tipo de ficheiro
		lea	dx, default					; dx contem endereco do nome do ficheiro 
		int	21h	
		mov fhandle,ax					; abre efectivamente e AX vai ficar com o Handle do ficheiro
		jnc inicio

		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea	dx,msgErrorOpen
		int 21h

		mov ah,0
		call LE_TECLA
		
		jmp fim

	inicio:
		mov si,320

	ciclo:
		mov ax,es:[si]
		add si,2
		
		mov buffer,ax
		mov	bx, fhandle		; para escrever BX deve conter o Handle 
		mov	ah, 40h			; indica que vamos escrever 
		lea	dx, buffer		;ax ->al Vamos escrever o que estiver no endereço DX
		mov	cx, 2			;2 vamos escrever multiplos bytes duma vez só
		int	21h				; faz a escrita 		
		jc	erro_escrita

		cmp si,3840
		jne ciclo
		jmp fechar
	
	erro_escrita:
		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea dx,msgErrorWrite
		int 21h
		
		mov ah,0
		call LE_TECLA

	fechar:
		mov	ah,3eh			; indica que vamos fechar
		mov bx,fhandle		; passa o handle do ficheiro para bx
		int	21h				; fecha mesmo
							; se não acontecer erro termina
	fim:
		;call apaga_ecran
		ret
guarda_labirinto_default endp

altera_labirinto_default proc

			obtem_string msgAskFich
			call apaga_ecran
			
			call abre_labirinto
			cmp	al,1
			je	erro_abrir
	
			goto_xy 0,0
			MOSTRA Warning

	CICLO:
			mov	ah,0
			call LE_TECLA
			
			cmp al, 27			; ESCAPE
			je	fim

	SIM:
			cmp al,49
			jne NAO
			call guarda_labirinto_default
			jmp fim

	NAO:
			cmp al,50
			jne	NOVE
			jmp fim

	NOVE:
			jmp	CICLO
	
	erro_abrir:
			mov	ah,0
			call LE_TECLA
			
	fim:
			ret
altera_labirinto_default endp

;########################################################################
;Procedure para criar labirinto!

guarda_labirinto proc
		
		mov	ax,0B800h ;0B800h -> endereço para memoria de video 
		mov	es,ax	  ;colocado em es -> aponta para um sitio menos cs ds ss
		
		mov	ah, 3ch						; abrir ficheiro para escrita 
		mov	cx, 00H						; tipo de ficheiro
		lea	dx, offset fname + 2		; dx contem endereco do nome do ficheiro 
		int	21h	
		mov fhandle,ax					; abre efectivamente e AX vai ficar com o Handle do ficheiro
		jnc inicio

		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea	dx,msgErrorOpen
		int 21h

		mov ah,0
		call LE_TECLA
		
		jmp fim

	inicio:
		mov si,320

	ciclo:
		mov ax,es:[si]
		add si,2
		
		mov buffer,ax
		mov	bx, fhandle		; para escrever BX deve conter o Handle 
		mov	ah, 40h			; indica que vamos escrever 
		lea	dx, buffer		;ax ->al Vamos escrever o que estiver no endereço DX
		mov	cx, 2			;2 vamos escrever multiplos bytes duma vez só
		int	21h				; faz a escrita 		
		jc	erro_escrita

		cmp si,3840
		jne ciclo
		jmp fechar
	
	erro_escrita:
		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea dx,msgErrorWrite
		int 21h
		
		mov ah,0
		call LE_TECLA

	fechar:
		mov	ah,3eh			; indica que vamos fechar
		mov bx,fhandle		; passa o handle do ficheiro para bx
		int	21h				; fecha mesmo
							; se não acontecer erro termina
	fim:
		;call apaga_ecran
		ret
guarda_labirinto endp

draw_instruct	proc
		goto_xy 0,0
		mov		ah,09h
		lea		dx,cria_lab_instrucoes
		int		21h

		ret
draw_instruct	endp

cria_labirinto proc
	
	restart:
			obtem_string msgAskNovoFich
			cmp	fname[2],' '
			je	erro_nome

			call	apaga_ecran
			call 	draw_instruct
			
			mov	POSx,20
			mov POSy,3
			
	CICLO:	
			goto_xy POSx,POSy

	IMPRIME:
			mov		ah, 02h
			mov		dl, Car
			int		21H
			goto_xy	POSx,POSy
			
			mov 	ah,0
			call 	LE_TECLA

			cmp		ah, 1
			je		ESTEND
			cmp 	al, 27			; ESCAPE
			je		fim

	UM:		cmp 	al, 49			; Tecla 1
			jne		DOIS
			mov		Car, 219		;Caracter CHEIO
			jmp		CICLO		
		
	DOIS:	
			cmp 	al, 50			; Tecla 2
			jne		TRES
			mov		Car, 178		;CINZA 178 ▓
			jmp		CICLO			
			
	TRES:	
			cmp 	al, 51			; Tecla 3
			jne		QUATRO
			mov		Car, 177		;CINZA 177▒
			jmp		CICLO
			
	QUATRO:	
			cmp 	al, 52			; Tecla 4
			jne		CINCO
			mov		Car, 176		;CINZA 176
			jmp		CICLO

	CINCO:	
			cmp 	al, 53			; Tecla 5
			jne		SEIS
			mov		Car, 32			; espaço
			jmp		CICLO	

	SEIS:
			cmp 	al,54			; Tecla 6
			jne 	SEVEN
			mov 	Car,73			; I
			jmp		CICLO

	SEVEN:
			cmp 	al,55			; Tecla 7
			jne		GUARDA
			mov		Car,70			; F	
			jmp 	CICLO

	GUARDA:	
			cmp		al,103
			jne		NOVE
			call	guarda_labirinto
			jmp		fim

	NOVE:
			jmp		CICLO

	ESTEND:
			cmp 	al,48h
			jne		BAIXO
			
			cmp		POSy,3
			je		CICLO

			dec		POSy			;cima
			jmp		CICLO

	BAIXO:
			cmp		al,50h
			jne		ESQUERDA

			cmp		POSy,22
			je		CICLO

			inc 	POSy			;Baixo
			jmp		CICLO

	ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA

			cmp		POSx,20
			je		CICLO

			dec		POSx			;Esquerda
			jmp		CICLO

	DIREITA:
			cmp		al,4Dh
			jne		CICLO

			cmp		POSx,59
			je		CICLO

			inc		POSx			;Direita
			jmp		CICLO

	erro_nome:
			call apaga_ecran

			goto_xy 27,10
			
			MOSTRA	msgErrorFileName

			mov ah,0
			call LE_TECLA

			jmp restart

	fim:
			ret
cria_labirinto endp

;########################################################################
;Procedure para mostrar labirinto!

edita_labirinto proc

			obtem_string msgAskFich
			call apaga_ecran
			
			call abre_labirinto
			cmp	al,1
			je	erro_abrir
			
			call 	draw_instruct
			
			mov	POSx,20
			mov POSy,3
			
	CICLO:	
			goto_xy POSx,POSy

	IMPRIME:
			mov		ah, 02h
			mov		dl, Car
			int		21H
			goto_xy	POSx,POSy
			
			mov		ah,0
			call 	LE_TECLA

			cmp		ah, 1
			je		ESTEND
			cmp 	al, 27			; ESCAPE
			je		fim

	UM:		cmp 	al, 49			; Tecla 1
			jne		DOIS
			mov		Car, 219		;Caracter CHEIO
			jmp		CICLO		
		
	DOIS:	
			cmp 	al, 50			; Tecla 2
			jne		TRES
			mov		Car, 178		;CINZA 178 ▓
			jmp		CICLO			
			
	TRES:	
			cmp 	al, 51			; Tecla 3
			jne		QUATRO
			mov		Car, 177		;CINZA 177▒
			jmp		CICLO
			
	QUATRO:	
			cmp 	al, 52			; Tecla 4
			jne		CINCO
			mov		Car, 176		;CINZA 176
			jmp		CICLO

	CINCO:	
			cmp 	al, 53			; Tecla 5
			jne		SEIS
			mov		Car, 32			; espaço
			jmp		CICLO	

	SEIS:
			cmp 	al,54			; Tecla 6
			jne 	SEVEN
			mov 	Car,73			; I
			jmp		CICLO

	SEVEN:
			cmp 	al,55			; Tecla 7
			jne		GUARDA
			mov		Car,70			; F	
			jmp 	CICLO

	GUARDA:	
			cmp		al,103
			jne		NOVE
			call	guarda_labirinto
			jmp		fim

	NOVE:
			jmp		CICLO

	ESTEND:
			cmp 	al,48h
			jne		BAIXO
			
			cmp		POSy,3
			je		CICLO

			dec		POSy			;cima
			jmp		CICLO

	BAIXO:
			cmp		al,50h
			jne		ESQUERDA

			cmp		POSy,22
			je		CICLO

			inc 	POSy			;Baixo
			jmp		CICLO

	ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA

			cmp		POSx,20
			je		CICLO

			dec		POSx			;Esquerda
			jmp		CICLO

	DIREITA:
			cmp		al,4Dh
			jne		CICLO

			cmp		POSx,59
			je		CICLO

			inc		POSx			;Direita
			jmp		CICLO
	
	erro_abrir:
			mov	ah,0
			call LE_TECLA

	fim:
			ret
edita_labirinto endp

;########################################################################
;Procedure para ler labirinto para o ecrã

abre_labirinto proc
		mov ah,3dh				 	; indica que vai abrir um ficheiro
		mov al,0				 	; indica que o ficheiro sera aberto em modo de leitura
		lea dx,offset fname  + 2 	; passa o nome do ficheiro para dentro de dx
		int 21h					 	; Chama a rotina de abertura de ficheiro (AX fica com Handle)
		mov fhandle,ax				; passa handle do ficheiro que esta em AX para a variavel fhandle
		jnc inicio					; se nao houver erro salta para inicio da funcao.

		call apaga_ecran			;##################################################
		goto_xy	20,10				;Apaga o ecrã e mostra mensagem de erro ao abrir
		mov	ah,09h					;
		lea	dx,msgErrorOpen			;
		int 21h						;

		mov al,1
		jmp fim						;##################################################

	inicio:
		mov si,320				

	ciclo:	
		mov ah, 3fh			; diz que vai ler o ficheiro
		mov bx, fhandle		; passa o handle do ficheiro para bx
		mov cx, 2			; vai ler 2 byte de cada vez
		lea dx, buffer		; DX fica a apontar para o caracter lido
		int 21h				; le 2 caracteres do ficheiro
		mov ax, buffer		; mete buffer em ax para voltar posicionalos no ecra
		jc erro_leitura		; se houver erro vai mostrar o erro de leitura

		mov 	es:[si],ax	; coloca conteudo de ax no ecra
		add		si,2		; vai para a proxima posicao do ecra

		cmp si,3840			; repete o codigo do ciclo até que a posicao do ecra seja 3840
		jne ciclo
		jmp fecha_ficheiro			

	erro_leitura:
		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea	dx,msgErrorRead
		int 21h

		xor ax,ax
		mov al,1
		push ax
		
		mov ah,0
		call LE_TECLA

		jmp fim_erro_leitura

	fecha_ficheiro:
		mov     ah,3eh		; indica que vai fechar o ficheiro
		mov     bx,fhandle	; passa o handle do ficheiro para dentro de bx
		int     21h			; fecha o ficheiro

		jmp		fim
	
	fim_erro_leitura:
		call apaga_ecran

		goto_xy 15,10
		MOSTRA msgErrorRead
		
		mov     ah,3eh		; indica que vai fechar o ficheiro
		mov     bx,fhandle	; passa o handle do ficheiro para dentro de bx
		int     21h			; fecha o ficheiro

		pop ax
		jmp fim

	fim_sucesso:
		mov al,0
	fim:
		ret

abre_labirinto endp

abre_labirinto_default proc
		mov ah,3dh				 	; indica que vai abrir um ficheiro
		mov al,0				 	; indica que o ficheiro sera aberto em modo de leitura
		lea dx,default			 	; passa o nome do ficheiro para dentro de dx - este caso o default é def.txt
		int 21h					 	; Chama a rotina de abertura de ficheiro (AX fica com Handle)
		mov fhandle,ax				; passa handle do ficheiro que esta em AX para a variavel fhandle
		jnc inicio					; se nao houver erro salta para inicio da funcao.

		call apaga_ecran			;##################################################
		goto_xy	20,10				;Apaga o ecrã e mostra mensagem de erro ao abrir
		mov	ah,09h					;
		lea	dx,msgErrorOpen			;
		int 21h						;

		mov al,1
		jmp fim						;##################################################

	inicio:
		mov si,320				

	ciclo:	
		mov ah, 3fh			; diz que vai ler o ficheiro
		mov bx, fhandle		; passa o handle do ficheiro para bx
		mov cx, 2			; vai ler 2 byte de cada vez
		lea dx, buffer		; DX fica a apontar para o caracter lido
		int 21h				; le 2 caracteres do ficheiro
		mov ax, buffer		; mete buffer em ax para voltar posicionalos no ecra
		jc erro_leitura		; se houver erro vai mostrar o erro de leitura

		mov 	es:[si],ax	; coloca conteudo de ax no ecra
		add		si,2		; vai para a proxima posicao do ecra

		cmp si,3840			; repete o codigo do ciclo até que a posicao do ecra seja 3840
		jne ciclo
		jmp fecha_ficheiro			

	erro_leitura:
		call apaga_ecran
		goto_xy	20,10
		mov	ah,09h
		lea	dx,msgErrorRead
		int 21h

		xor ax,ax
		mov al,1
		push ax
		
		mov ah,0
		call LE_TECLA

		jmp fim_erro_leitura

	fecha_ficheiro:
		mov     ah,3eh		; indica que vai fechar o ficheiro
		mov     bx,fhandle	; passa o handle do ficheiro para dentro de bx
		int     21h			; fecha o ficheiro

		jmp		fim
	
	fim_erro_leitura:
		call 	apaga_ecran

		goto_xy 15,10
		MOSTRA	msgErrorRead

		mov     ah,3eh		; indica que vai fechar o ficheiro
		mov     bx,fhandle	; passa o handle do ficheiro para dentro de bx
		int     21h			; fecha o ficheiro

		pop ax
		jmp fim

	fim_sucesso:
		mov al,0
	fim:
		ret

abre_labirinto_default endp

;########################################################################
;					 			   TOP 10
;########################################################################
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

; #####################################################################
; Trata nome para  poder ser imprimido corretamente
; isto acontece devido ao obtem_nome nao guardar carater $ para se poder
; imprimir no vetor
; foi necessario fazer esta alteraçao para imprimir o nome no ecran
; sem os carateres estranhos por cima das horas
; #####################################################################
        				
trata_nome_com_sifrao PROC

		push ax
		push bx
		push si
		push di
		
		mov si, 2
		mov di, 0
		
	ciclo_trata_nome:

		mov al, nome_jogador[si]
		cmp al,' '
		je fim_trata_nome
		mov nome_com_sifrao[di],al
		inc si
		inc di
		cmp si,10
		jne ciclo_trata_nome
		
	fim_trata_nome:

		mov nome_com_sifrao[di+1], '$'

		pop di
		pop si
		pop bx
		pop ax
		ret
trata_nome_com_sifrao ENDP

obtem_string_nome_jogador macro str

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
	mov si, offset nome_jogador+1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 						;MOVE LENGTH TO CL.
	mov ch, 0      						;CLEAR CH TO USE CX. 
	inc cx 								;TO REACH CHR(6).
	add si, cx 							;NOW SI POINTS TO CHR(12).
	mov al, ' '
	mov [si], al 						;REPLACE CHR(12) BY '$'.            
	call trata_nome_com_sifrao
endm

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
		mov	cx, 190						; vamos escrever multiplos bytes duma vez só
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
		
		mov     contador,1							; reseta contador para iniciar a leitura no inicio da nova linha
		inc 	linha	
		jmp		ler_ciclo1
				
	ler_nome:
	
		mov			cx, 10							;; vai ler 10 bytes de cada vez, ara preencher o nome
		lea 		dx, nome_top10
		mov 		contador,2
		jmp 		ler_ciclo2
		
	read_tempo:
	
		mov 		cx, 9							;; vai ler 8 bytes de cada vez para preencher a hora
		lea			dx, tempo_top10
		jmp 		ler_ciclo2
		
		
	ler_ciclo1:									; contador vai servir para defenir o numero de bits que se vai ler do ficheiro de cada vez;
			
		cmp			contador, 2				; se contador for igual a 1 vai para ler nome
		je			ler_nome
		
		cmp 		contador, 1				; se contador for igual a 2 vai para ler tempo
		je  		read_tempo
		
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
	
		push ax
		push bx
		push di
		push si
		
		mov line, 0
	;******************************************************
	; verifica espaços vazios
	;******************************************************
	espacos_vazios:

		cmp line, 10
		je fim_preenche
		mov bl, line
		mov al, total_bytes
		mul bl
		mov si, ax
		inc si
		cmp Top10_jogadores[si], ' '
		je preenche_novo_jogador
	;******************************************************
	; se nao encontra espaços vazios vai substituir jogador
	;******************************************************
	substitui_jogador:
			
		mov bl, minutosb[0]
		cmp bl, Top10_jogadores[si]
		je proximo1
		jb escreve1
		ja inc_linha_substitui
		inc si
	;******************************************************
	; vai procurar nas casas dos segundos se o tempo do 
	;novo jogadoré menor que os que existem no top10
	;******************************************************		
	proximo1:

		inc si
		mov bl, minutosb[1]
		cmp bl, Top10_jogadores[si]
		je proximo2
		jb escreve1
		ja inc_linha_substitui
		
	proximo2:
		
		add si,2
		mov bl, segundosb[0]
		cmp bl, Top10_jogadores[si]
		je proximo3
		jb escreve1
		ja inc_linha_substitui
		
	proximo3:
		
		inc si
		mov bl, segundosb[1]
		cmp bl, Top10_jogadores[si]
		jb  escreve1
		ja	inc_linha_substitui
		add si, 4
		mov di,2
	;******************************************************
	; vai escrever o jogador novo, se ultrapassar
	; os records atuais
	;******************************************************
	escreve1:
		
		mov bl, line
		mov al,total_bytes
		mul bl
		mov si, ax
		inc si
		mov bl, Top10_jogadores[si]
		mov dl, minutosb[0]
		mov Top10_jogadores[si],dl
		mov minutosb[0],bl
		inc si
		mov bl, Top10_jogadores[si]
		mov dl, minutosb[1]
		mov Top10_jogadores[si],dl
		mov minutosb[0],bl
		add si,2
		mov bl, Top10_jogadores[si]
		mov dl, segundosb[0]
		mov Top10_jogadores[si],dl
		mov segundosb[0],bl
		inc si
		mov bl, Top10_jogadores[si]
		mov dl, segundosb[1]
		mov Top10_jogadores[si],dl
		mov segundosb[1],bl
		add si, 4
		mov di,2

	ciclo3:
		
		mov al,Top10_jogadores[si]
		mov dl, nome_jogador[di]
		mov Top10_jogadores[si],dl
		mov nome_jogador[di],al
		inc di
		inc si
		cmp di,10
		jne ciclo3
		inc line
		jmp substitui_jogador
	;******************************************************
	; caso aja espaços em branco, vai preencher diretamente
	; com o jogador no final 
	;******************************************************			
	preenche_novo_jogador:
		
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
		add si, 4
		mov di,2

	ciclo2:
		mov al,nome_jogador[di]
		mov Top10_jogadores[si],al
		inc di
		inc si
		cmp di,10
		jne ciclo2
		jmp fim_preenche
	;******************************************************
	; se nao verifica nenhuma das duas ocorrencias
	; incrementa linha para ir para a proxima 
	;******************************************************
	inc_linha_substitui:
		inc line
		jmp espacos_vazios
		
	fim_preenche:
			
		pop si
		pop di
		pop bx
		pop ax
		ret
		
top10_incrementa_novo_jogador ENDP

;########################################################################
;									Menus
;########################################################################

display_options_menu proc
	menu_loop:
			call apaga_ecran
			goto_xy 0,0

			;mostra menu
			mov  ah,09h
			lea  dx,menuLabirintos
			int  21h
			
			;Pede input ao utilizador.
			goto_xy	21,17

			mov ah,0
			call LE_TECLA	;obtem tecla e poe em AL
			mov tecla, al

			cmp tecla,49
			je	carrega_lab

			cmp tecla,50
			je	cria_lab

			cmp tecla,51
			je	edita_lab

			cmp	tecla,52
			je	fim
			
			jmp menu_loop

	carrega_lab:
			call altera_labirinto_default
			jmp menu_loop

	cria_lab:
			call cria_labirinto
			jmp	menu_loop

	edita_lab:
			call edita_labirinto
			jmp menu_loop
	
	fim:
			ret

display_options_menu endp

main_menu proc

	menu_loop:
			;apaga ecra e posiciona o cursor no inicio.
			call apaga_ecran
			goto_xy 0,0

			;mostra menu
			mov  ah,09h
			lea  dx,menu
			int  21h
			
			;Pede input ao utilizador.
			goto_xy	21,17

			mov ah,0
			call LE_TECLA	;obtem tecla e poe em AL
			mov tecla, al	;move a tecla para AL	

			cmp	tecla,49
			je	gameNormal

			cmp tecla,50
			je	opcoes

			cmp tecla,51
			je	topTen

			cmp tecla,52
			je	fim
			jmp menu_loop

	gameNormal:
			call jogo
			jmp	menu_loop

	opcoes:
			call display_options_menu
			jmp menu_loop

	topTen:
			call Ler_Dados_Ficheiro_Top10
			call display_TOP10

			mov ah,0
			call LE_TECLA
			
			jmp menu_loop

	fim:
			ret
main_menu endp

;########################################################################
;									Main
;########################################################################

Main  proc
		mov		ax, dseg
		mov		ds,ax

		mov 	ax,0B800h	;move o ponteiro para memoria de video para ax
		mov		es,ax		;move o ponteiro para memoria de video de ax para ES

		call main_menu

	fim:
		mov		ah,4CH
		int		21H

Main	endp
Cseg	ends
end	Main