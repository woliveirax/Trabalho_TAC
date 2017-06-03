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
		cria_lab_instrucoes	db	'	1 - ',219,'	2 - ',178,'	3 - ',177,'	4 - ',176,'	5 - apaga  g - Guarda  ESC - Sair',13,10
							db	80 dup('-'),'$',0
		contador			db	?

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
		

		msgErrorOpen	db	"Ocorreu um erro na abertura do fichero!$",0
		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$",0
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$",0
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$",0
		msgErrorRead	db	"Ocorreu um erro no ao ler do ficheiro!$",0

		;####################################################################################################################
		;Variaveis do jogo

		Cor			db	7	; Guarda os atributos de cor do caracter
		POSya		db	3	; Posi��o anterior de y
		POSxa		db	22	; Posi��o anterior de x
		nome_jogar	db	12 dup(?) 	; nome do utilizador


		;####################################################################################################################

		;Placeholder variables
		cria_lab_placeholder	db	'A criar labirinto! $',0
		abre_lab_placeholder	db	'A abrir labirinto! $',0
		change_top10_placeholder	db	'A alterar top 10! $',0
		top10_placeholder		db	'A mostrar top 10! $',0
		game_placeholder		db	'Inicio de jogo! $',0
		game_cheats_placeholder	db	'Inicio de jogo com ajuda do computador! $',0

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


;########################################################################
;						  Lê tecla do teclado
;########################################################################

LE_TECLA	PROC

			mov		ah,08h		;instrução para ler a tecla.
			int		21h			;interrupt a iniciar a condição indicada em ah.
			mov		ah,0		;flag para saber se o número é extendido ou não.
			cmp		al,0		;compara al para saber se o número é extendido.
			jne		SAI_TECLA
			mov		ah, 08h		;se for extendido volta a ler o número do buffer.
			int		21h			;interrupt a iniciar a condição indicada em ah.
			mov		ah,1		;indica que o número é extendido.

	SAI_TECLA:
			mov tecla,al
			ret					;retorna da procedure
LE_TECLA	endp

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
;							Funcoes do jogo
;########################################################################
;Pede string ao utilizador

obtem_string macro str
	call apaga_ecran
	goto_xy	24,10
	mov ah,09h
	lea dx,str
	int 21h
	goto_xy	34,11

	mov ah, 0Ah
	mov dx,offset fname
	int 21h
	
	mov si, offset fname + 1 	;NUMBER OF CHARACTERS ENTERED.
	mov cl, [si] 				;MOVE LENGTH TO CL.
	mov ch, 0      				;CLEAR CH TO USE CX. 
	inc cx 						;TO REACH CHR(6).
	add si, cx 					;NOW SI POINTS TO CHR(12).
	mov al, '$'
	mov [si], al 				;REPLACE CHR(12) BY '$'.            

endm
;########################################################################
;Procedure do jogo normal!

get_nextPos proc
	goto_xy POSx,POSy

	mov ah,08h
	mov bh,0
	int 10h
	
	ret
get_nextPos endp

;importa labirinto
jogo proc
			obtem_string	msgAskFich
			call apaga_ecran
			call abre_labirinto

			mov POSx,22
			mov POSy,3

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
			mov	bh, 0			; numero da p�gina
			int	10h
			mov	Car, al		; Guarda o Caracter que est� na posi��o do Cursor
			;mov	Cor, ah			; Guarda a cor que est� na posi��o do Cursor

			
	CICLO:
			
			goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
			mov	ah, 02h
			mov	dl, Car		; Repoe Caracter guardado
			int	21h

			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov ah, 08h
			mov	bh,0			; numero da p�gina
			int	10h
			mov	Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			;mov	Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		    
			goto_xy	78,0		; Mostra o caractr que estava na posi��o do AVATAR
			mov	ah, 02h			; IMPRIME caracter da posi��o no canto
			mov	dl, Car
			int	21H

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
			cmp al,32
			jne movimento
			jmp	CICLO

	BAIXO:	cmp	al,50h			; Baixo
			jne	ESQUERDA

			cmp POSy,22
			je	LER_SETA

			inc POSy
			call get_nextPos
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
			cmp al,32
			jne movimento
			jmp	CICLO

	fim:
		ret

jogo endp

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
			obtem_string msgAskNovoFich
			
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
			jne		GUARDA
			mov		Car, 32			; espaço
			jmp		CICLO	


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

	fim:
			ret
cria_labirinto endp

;########################################################################
;Procedure para mostrar labirinto!

edita_labirinto proc
			obtem_string msgAskFich

			call	apaga_ecran
			call 	abre_labirinto
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
			jne		GUARDA
			mov		Car, 32			; espaço
			jmp		CICLO	


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
		call LE_TECLA

	fecha_ficheiro:
		mov     ah,3eh		; indica que vai fechar o ficheiro
		mov     bx,fhandle	; passa o handle do ficheiro para dentro de bx
		int     21h			; fecha o ficheiro
	
	fim:
		ret

abre_labirinto endp


;########################################################################
;Procedure para mostrar top 10

top10 proc
	mov ah,09h
	lea dx,top10_placeholder
	int 21h

	ret
top10 endp

;########################################################################
;Procedure para alterar TOP 10

altera_top10 proc
	mov ah,09h
	lea dx,change_top10_placeholder
	int 21h

	ret
altera_top10 endp

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
			;all carrega_lab_omissao

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
			call LE_TECLA
			jmp	menu_loop

	opcoes:
			call display_options_menu
			jmp menu_loop

	topTen:
			obtem_string msgAskPlayer
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