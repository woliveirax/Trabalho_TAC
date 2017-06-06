.8086
.model	small
.stack	2048

dseg   	segment para public 'data'
	vec_top10 db  10 dup(?)
	Total_Sec db  ?
	Total_Min db  ?
	Mensagem_Final db 'Parabens conseguiu chegar ao fim.$'
	buffer db 'Labirinto',13,10
		db	'+----------------------------------+',13,10
		db 	' 1: Jogar                					',13,10
		db	' 2: Carregar Labirinto						',13,10
		db  ' 3: Editar Labirinto              ',13,10
		db 	' 4: Top 10           							',13,10
		db	' 5: Configuracao do Labirinto     ',13,10
		db	' 6: Sair                          ',13,10
		db	'+----------------------------------+$',13,10
	buffer_Legenda db "Legenda: 1-Carater cheio // 2-Espaco // 3-Carater Inicial // 4- Carater Final$"
	buffer_Joga db "Esc-Voltar ao menu$"
	Escolha   db  ?
	Inic_Sec	db  ?
	Inic_Min	db  ?
	total_Inic dw ?
	Fim_Sec		db  ?
	Fim_Min		db  ?
	total_fim dw  ?
	Car_Cria  db  ?
	carFich 	db 	?
	var1			dw 	?
	handletop dw  ?
	handle  	dw  ?
	filetop10 db  "top10.txt", 0
	filename 	db  "Lab1.txt", 0
	filename_Cria db "f1.txt", 0
	handle_Cria dw ?
	POSy			db	5
	POSx			db	10
	ProxPOSy	db	5
	ProxPOSx	db	10
	Cor 			db  7
	Car				db  32
	POSya			db	5
	POSxa			db	10
	Cria_POSx db  21
	Cria_POSy db  3

dseg    	ends

cseg		segment para public 'code'
		assume  cs:cseg, ds:dseg

;Macro para saber se a proxima posicao esta livre
goto_Prox_xy	macro		ProxPOSx,ProxPOSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,ProxPOSx
		mov		dh,ProxPOSy
		int		10h
		mov 	ah, 08h
		mov		bh,	0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que esta na posicao do Cursor
		mov		Cor, ah	; Guarda a cor que esta na posicao do Cursor
endm
;########################################################################
;Macro para imprimir no final do ecra.
goto_xy_tempo macro
		MOV	AH,02H
		MOV	BH,0
		MOV	DL,1
		MOV	DH,24
		INT	10H
ENDM
;Macro para mudar a posicao do cursor
goto_xy	macro		POSx,POSy
		mov		ah,02h
	 	mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; Ler tecla do ecra
LE_TECLA	PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
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

main		proc
		mov   ax, dseg
		mov 	ds, ax
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

INICIO:
		call 	apaga_ecran
		mov 	POSx, 1
		mov 	POSy, 1
		goto_xy POSx, POSy
		mov		ah, 09h
		lea		dx, buffer
		int		21h
		mov 	ah, 00h
		int 	16h
		mov 	Escolha, al
		cmp 	escolha, 49
		je 		Abre_Default
		cmp 	escolha, 50
		je 		Abre_User
		cmp   escolha, 51
		je    Editar
		cmp 	escolha, 52
		je 		final
		cmp 	escolha, 53
		je 		INICIO_Cria
		cmp 	escolha, 54
		je 		final
		cmp 	al, 48
		jbe 	INICIO ; caso nao escolha uma das opcoes volta ao inicio
		cmp 	al, 54
		jae 	INICIO
;###########################################
;Abertura do labirinto default
Abre_Default:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename
		int		21h
		mov		handle, ax
		goto_xy POSx, POSy

ler_ciclo:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp   ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je   fecha_ficheiro	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov   dl,carFich		; este é o caracter a enviar para o ecran
		int 	21h				; imprime no ecran
		jmp	 	ler_ciclo		; continua a ler o ficheiro
fecha_ficheiro:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Joga
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		mov   ah,3eh
		mov   bx,handle
		int   21h
		jmp		CICLO
;#######################################
;Abertura do labirinto do user
Abre_User:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov   POSx, 5
		mov   POSy, 10
		goto_xy POSx, POSy
ler_ciclo_user:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle_Cria		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp	  ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je	  fecha_ficheiro_user	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov	  dl,carFich		; este é o caracter a enviar para o ecran
		int	  21h				; imprime no ecran
		jmp	  ler_ciclo_user		; continua a ler o ficheiro
fecha_ficheiro_user:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Joga
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		mov   ah,3eh
		mov   bx,handle_Cria
		int   21h
		jmp		CICLO
;########################################
;Jogo em si
CICLO:
		goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado
		int		21H

		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

		goto_xy	POSx,POSy	; Vai para posi��o do cursor
IMPRIME:
		mov		ah, 02h
		mov		dl, 190	; Coloca AVATAR
		int		21H
		goto_xy	POSx,POSy	; Vai para posi��o do cursor

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 		POSya, al

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		ProxPOSx, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 	ProxPOSy, al

LER_SETA:
		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 	AL, 27	; ESCAPE
		JE		INICIO
		jmp		LER_SETA

ESTEND:
		cmp 	al,48h
		jne		BAIXO
		dec 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al, 73
		je    Inicio_C
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		dec 	POSy
		jmp 	CICLO
Inicio_C:
		mov		ah, 2Ch
		int		21h
		mov 	Inic_Min, cl ; minutos quando o utilizador comecou
		mov   Inic_Sec, dh ; segundos quando o utilizador comecou
		mov 	al,Inic_Min ; meter os minutos em al para fazer a multiplicacao
		mov 	bl,60 ; multiplicar por 60
		mul 	bl ; multiplicacao
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		mov   total_Inic, ax
		dec 	POSy
		jmp 	CICLO
Fim_C:
		mov		ah, 2Ch
		int		21h ; vai buscar o tempo inicial
		mov 	Fim_Min, cl ; mete os minutos finais nesta variavel
		mov   Fim_Sec, dh ; mete os segundos finais nesta variavel
		mov 	al,Fim_Min
		mov 	bl,60
		mul 	bl
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		sub   ax, total_Inic
		mov   total_fim, ax
		jmp   FIM

BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 	ProxPOSy	;Baixo
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70 ;verifica se o carater e o final
		je    Fim_B
		cmp   al, 73 ;Verifica se o caracter e o inicial
		je    Inicio_B
		cmp 	al, 20h ; ; Verificacao se esta esta ocupada
		jne 	CICLO
		inc 	POSy
		jmp		CICLO
Inicio_B:
		mov		ah, 2Ch
		int		21h
		mov 	Inic_Min, cl ; minutos quando o utilizador comecou
		mov   Inic_Sec, dh ; segundos quando o utilizador comecou
		mov 	al,Inic_Min ; meter os minutos em al para fazer a multiplicacao
		mov 	bl,60 ; multiplicar por 60
		mul 	bl ; multiplicacao
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		mov   total_Inic, ax
		inc 	POSy
		jmp 	CICLO
Fim_B:
		mov		ah, 2Ch
		int		21h ; vai buscar o tempo inicial
		mov 	Fim_Min, cl ; mete os minutos finais nesta variavel
		mov   Fim_Sec, dh ; mete os segundos finais nesta variavel
		mov 	al,Fim_Min
		mov 	bl,60
		mul 	bl
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		sub   ax, total_Inic
		mov   total_fim, ax
		jmp   FIM

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy
		cmp   al, 70
		je 		Fim_E
		cmp   al, 73
		je    Inicio_E
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		dec		POSx
		jmp		CICLO
Inicio_E:
		mov		ah, 2Ch
		int		21h
		mov 	Inic_Min, cl ; minutos quando o utilizador comecou
		mov   Inic_Sec, dh ; segundos quando o utilizador comecou
		mov 	al,Inic_Min ; meter os minutos em al para fazer a multiplicacao
		mov 	bl,60 ; multiplicar por 60
		mul 	bl ; multiplicacao
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		mov   total_Inic, ax
		dec 	POSx
		jmp 	CICLO
Fim_E:
		mov		ah, 2Ch
		int		21h ; vai buscar o tempo inicial
		mov 	Fim_Min, cl ; mete os minutos finais nesta variavel
		mov   Fim_Sec, dh ; mete os segundos finais nesta variavel
		mov 	al,Fim_Min
		mov 	bl,60
		mul 	bl
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		sub   ax, total_Inic
		mov   total_fim, ax
		jmp   FIM

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA
		inc 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je		Fim_D
		cmp   al, 73
		je    Inicio_D
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		inc   POSx
		jmp   CICLO
Inicio_D:
		mov		ah, 2Ch
		int		21h
		mov 	Inic_Min, cl ; minutos quando o utilizador comecou
		mov   Inic_Sec, dh ; segundos quando o utilizador comecou
		mov 	al,Inic_Min ; meter os minutos em al para fazer a multiplicacao
		mov 	bl,60 ; multiplicar por 60
		mul 	bl ; multiplicacao
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bh
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		mov   total_Inic, ax
		inc 	POSx
		jmp 	CICLO
Fim_D:
		mov		ah, 2Ch
		int		21h ; vai buscar o tempo inicial
		mov 	Fim_Min, cl ; mete os minutos finais nesta variavel
		mov   Fim_Sec, dh ; mete os segundos finais nesta variavel
		mov 	al,Fim_Min
		mov 	bl,60
		mul 	bl
		xor   bx,bx ; mete o bx a 0
		mov   bl,Inic_Sec ; passa o valor dos segundos para bl
		add   ax, bx ; resultado da multiplicacao + segundos iniciais
		sub   ax, total_Inic
		mov   total_fim, ax
		jmp   FIM

		;call		apaga_ecran

		;Obter a posi��o
		;dec		POSy		; linha = linha -1
		;dec		POSx		; POSx = POSx -1

		;mov 	ah,3CH ; Criacao do ficheiro
		;mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		;lea 	dx, filename
		;int		21h
		;mov		handle, ax

;###########################################################
; PARTE RELACIONADA COM A CRIACAO DO LABIRINTO
INICIO_Cria:
		call		apaga_ecran

		;Obter a posi��o
		dec		POSy		; linha = linha -1
		dec		POSx		; POSx = POSx -1

		mov 	ah,3CH ; Criacao do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Legenda
		int		21h
CICLO_Cria:	goto_xy	Cria_POSx,Cria_POSy
IMPRIME_Cria:
		mov		ah, 02h
		mov		dl, Car_Cria
		int		21H
		goto_xy	Cria_POSx,Cria_POSy

		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND_Cria
		cmp 	AL, 27		; ESCAPE
		je		ESCAPE_Cria

UM_Cria:		CMP 		AL, 49		; Tecla 1
		JNE		DOIS_Cria
		mov		Car_Cria, 219	;Caracter CHEIO
		jmp		CICLO_Cria

DOIS_Cria:		CMP 		AL, 50		; Tecla 2
		JNE		TRES_Cria
		mov		Car_Cria, 32		;Espaco
		jmp		CICLO_Cria

TRES_Cria:		CMP 		AL, 51		; Tecla 3
		JNE		QUATRO_Cria
		mov		Car_Cria, 73	;Carater Inicial
		jmp		CICLO_Cria

QUATRO_Cria:	CMP 		AL, 52; Tecla 4
		JNE		NOVE_Cria
		mov		Car_Cria, 70		;Carater final
		jmp		CICLO_Cria

NOVE_Cria:		jmp		CICLO_Cria

ESTEND_Cria:	cmp 		al,48h
		jne		BAIXO_Cria
		cmp  	Cria_POSy, 2
		jbe   CICLO_Cria
		dec		Cria_POSy		;cima
		jmp		CICLO_Cria

BAIXO_Cria:	cmp		al,50h
		jne		ESQUERDA_Cria
		cmp   Cria_POSy, 22
		jae   CICLO_Cria
		inc 	Cria_POSy		;Baixo
		jmp		CICLO_Cria

ESQUERDA_Cria:
		cmp		al,4Bh
		jne		DIREITA_Cria
		cmp   Cria_POSx, 20
		jbe   CICLO_Cria
		dec		Cria_POSx		;Esquerda
		jmp		CICLO_Cria

DIREITA_Cria:
		cmp		al,4Dh
		jne		CICLO_Cria
		cmp   Cria_POSx,60
		jae   CICLO_Cria
		inc		Cria_POSx		;Direita
		jmp		CICLO_Cria

ESCAPE_Cria:
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si
GUARDA_Cria:
		mov 	al, es:[si]
		mov 	ah, es:[si+1]
		mov 	var1,ax
		mov 	ah,40h
		mov 	cx,2
		lea 	dx,var1
		mov		bx,handle_Cria
		int 	21h
		add 	si , 2
		cmp 	si, 3520
		jne 	GUARDA_Cria
		mov		ah,3Eh ; Fecho do ficheiro
		mov		bx,handle_Cria
		int		21h
		jmp 	INICIO

;Editar
;################################
Editar:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov   POSx, 5
		mov   POSy, 10
		goto_xy POSx, POSy
ler_ciclo_edit:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle_Cria		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp	  ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je	  fecha_ficheiro_edit	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov	  dl,carFich		; este é o caracter a enviar para o ecran
		int	  21h				; imprime no ecran
		jmp	  ler_ciclo_edit		; continua a ler o ficheiro
fecha_ficheiro_edit:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Legenda
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		jmp		CICLO_Cria

FIM:
		mov   ah,09h
		mov   ax, total_fim
		mov   bh, 0
		mov   bl, 0
		mov   cx, 5
		int   10h
		mov   ah,09h
		lea 	dx, total_fim
		int   21h
		mov 	ah,09h ;display da mensagem de quanto tempo demorou
		lea   dx, Mensagem_Final
		int   21h

FINAL:

		mov		ah,4CH
		INT		21H
main		endp
cseg    	ends
end     	Main
