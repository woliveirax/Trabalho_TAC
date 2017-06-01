.8086
.model small
.stack 2048

dseg	segment para public 'data'
		
		POSy		db	5	; a linha pode ir de [1 .. 25]
		POSx		db	10	; POSx pode ir [1..80]

		;####################################################################################################################
		;Variaveis relativas ao MENU ↓
		menu 			db	80 dup ('_'),13,10,10
						db	'                   	 	THE MAZE GAME!',13,10,10
						db	80 dup ('_'),13,10,10
    					db 	'				1. Jogar!',13,10,10
						db 	'				2. Jogo com cheats!',13,10,10
						db 	'				3. Criar labirinto!',13,10,10
						db 	'				4. TOP 10!',13,10,10
						db 	'				5. Sair.',10,10,10
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
		fname			db	'Teste.txt'
		fhandle			dw	0
		buffer			db	1600 dup(32)

		msgErrorCreate	db	"Ocorreu um erro na criacao do ficheiro!$"
		msgErrorWrite	db	"Ocorreu um erro na escrita para ficheiro!$"
		msgErrorClose	db	"Ocorreu um erro no fecho do ficheiro!$"

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
; 								Mostra Menu
;########################################################################

display_menu proc
	;apaga ecra e posiciona o cursor no inicio.
	call apaga_ecran
	goto_xy 0,0

	;mostra menu
	mov  ah,09h
  	lea  dx,menu
  	int  21h
	
	;Pede input ao utilizador.
	goto_xy	21,19
	call LE_TECLA	;obtem tecla e poe em AL
	mov tecla, al	;move a tecla para AL

FIM:
	ret
display_menu endp

;########################################################################
;							Funcoes do jogo
;########################################################################
;Procedure do jogo normal!

game proc
	mov ah,09h
	lea dx,game_placeholder
	int 21h

	ret
game endp

;########################################################################
;Procedure do jogo com cheats!

game_cheats proc
	mov ah,09h
	lea dx,game_cheats_placeholder
	int 21h

	ret
game_cheats endp

;########################################################################
;Procedure para criar labirinto!

guarda_buffer 	proc
	
	mov	bx, 360
	mov	cx, 800	; Linhas x Colunas

	xor si,si
	mov	contador,0
	
	jmp Obtem_e_escreve

gambiarra:
	add	bx,80
	mov	contador,0

Obtem_e_escreve:	
	mov al, byte ptr es:[bx]
	mov buffer[si], al

	mov	al, byte ptr es:[bx+1]
	mov	buffer[si+1], al
	
	inc si
	inc si

	inc	bx
	inc bx

	inc contador

	cmp	contador,40
	je gambiarra

	loop Obtem_e_escreve
fim:
	pop ax
	ret
guarda_buffer	endp

save_to_file	proc
	call apaga_ecran
	call guarda_buffer

	mov	ah, 3ch			; abrir ficheiro para escrita
	mov	cx, 0			; tipo de ficheiro
	lea	dx, fname		; dx contem endereco do nome do ficheiro
	int	21h				; abre efectivamente e AX vai ficar com o Handle do ficheiro
	jnc	escreve			; se não acontecer erro vai vamos escrever

	mov	ah, 09h			; Aconteceu erro na leitura
	lea	dx, msgErrorCreate
	int	21h
	jmp	fim

escreve:

	mov	bx, ax			; para escrever BX deve conter o Handle
	mov	ah, 40h			; indica que vamos escrever

	lea	dx, buffer		; Vamos escrever o que estiver no endereço DX
	mov	cx, 1600		; vamos escrever multiplos bytes duma vez só
	int	21h				; faz a escrita
	
	jnc close			; se não acontecer erro fecha o ficheiro

	mov	ah, 09h
	lea	dx, msgErrorWrite
	int	21h

close:
	mov	ah,3eh			; indica que vamos fechar
	int	21h				; fecha mesmo
	jnc	fim				; se não acontecer erro termina

	mov	ah, 09h
	lea	dx, msgErrorClose
	int	21h

fim:
	ret

save_to_file	endp


draw_limits	proc
		mov contador,2

loop_rows:
		goto_xy 20,contador

		mov		ah, 02h
		mov		dl, 219
		int		21H
		
		goto_xy	62,contador

		mov		ah, 02h
		mov		dl, 219
		int		21H

		inc		contador

		cmp		contador,24
		jne		loop_rows

		mov contador,20

loop_columns:
		goto_xy contador,2

		mov		ah, 02h
		mov		dl, 219
		int		21H

		goto_xy contador,24

		mov		ah, 02h
		mov		dl, 219
		int		21H

		inc 	contador
		
		cmp		contador,63
		jne		loop_columns

		ret
draw_limits endp

draw_instruct	proc
		goto_xy 0,0
		mov		ah,09h
		lea		dx,cria_lab_instrucoes
		int		21h

		ret
draw_instruct	endp

cria_labirinto proc
		
		call	apaga_ecran
		call 	draw_instruct
		call	draw_limits
		
		mov	POSx,22
		mov POSy,3

		
CICLO:	

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
		call	save_to_file
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

		cmp		POSy,23
		je		CICLO

		inc 	POSy			;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA

		cmp		POSx,21
		je		CICLO

		dec		POSx			;Esquerda
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		CICLO

		cmp		POSx,61
		je		CICLO

		inc		POSx			;Direita
		jmp		CICLO

fim:
		ret
cria_labirinto endp

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
;Procedure para ler labirinto para o ecrã

guarda_buffer 	proc
	push ax
	
	mov	bx, 360
	mov	cx, 800	; Linhas x Colunas

	xor si,si
	mov	contador,0
	
	jmp Obtem_e_escreve

gambiarra:
	add	bx,80
	mov	contador,0

Obtem_e_escreve:	
	mov al, byte ptr es:[bx]
	mov buffer[si], al

	mov	al, byte ptr es:[bx+1]
	mov	buffer[si+1], al
	
	inc si
	inc si

	inc	bx
	inc bx

	inc contador

	cmp	contador,40
	je gambiarra

	loop Obtem_e_escreve
fim:
	pop ax
	ret
guarda_buffer	endp



abre_labirinto proc


	ret
abre_labirinto endp

;########################################################################
;									Main
;########################################################################

Main  proc
		mov		ax, dseg
		mov		ds,ax

		mov 	ax,0B800h	;move o ponteiro para memoria de video para ax
		mov		es,ax		;move o ponteiro para memoria de video de ax para ES

menu_loop:
		
		call display_menu	;mostra menu

		cmp	tecla,49
		je	gameNormal
		
		cmp tecla,50
		je	gameCheats

		cmp tecla,51
		je	criaLab

		cmp tecla,52
		je	topTen

		cmp tecla,53
		je	fim
		jmp menu_loop

gameNormal:
		call game
		call LE_TECLA
		jmp	menu_loop

gameCheats:
		call game_cheats
		call LE_TECLA
		jmp menu_loop

criaLab:
		call cria_labirinto
		call LE_TECLA
		jmp menu_loop

topTen:
		call top10
		call LE_TECLA
		jmp menu_loop

fim:
		mov		ah,4CH
		INT		21H

Main	endp
Cseg	ends
end	Main