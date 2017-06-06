bonus:
		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 		POSya, al

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		ProxPOSx, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 	ProxPOSy, al

		mov ah,1
		call LE_TECLA

		cmp al, 48
		mov cx, 1
		je bonus_cima

		cmp al, 49
		mov cx, 2
		je bonus_cima

		cmp al, 50
		mov cx, 3
		je bonus_cima

		cmp al, 51
		mov cx, 4
		je bonus_cima

		cmp al, 52
		mov cx, 1
		je bonus_baixo

		cmp al, 53
		mov cx, 2
		je bonus_baixo

		cmp al, 54
		mov cx, 3
		je bonus_baixo

		cmp al, 55
		mov cx, 4
		je bonus_baixo

		cmp al, 56
		mov cx, 1
		je bonus_direita

		cmp al, 57
		mov cx, 2
		je bonus_direita

		cmp al, 97
		mov cx, 3
		je bonus_direita

		cmp al, 98
		mov cx, 4
		je bonus_direita

		cmp al, 99
		mov cx, 1
		je bonus_esquerda

		cmp al, 100
		mov cx, 2
		je bonus_esquerda

		cmp al, 101
		mov cx, 3
		je bonus_esquerda

		cmp al, 102
		mov cx, 4
		je bonus_esquerda

		cmp al,27
		je  INICIO

		cmp al, 48
		jb bonus
		cmp al, 97
		jb	bonus
		cmp al, 102
		ja  bonus

		cmp al,27
		je  INICIO

bonus_cima:
		dec 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_cima_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	bonus


bonus_cima_imprime:
		dec 	POSy
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

		call imprime1
		loop bonus_cima
		jmp bonus

bonus_cima_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_cima_imprime

bonus_baixo:
		inc 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_baixo_inicio
		cmp 	al, 20h 				; Verificacao se esta esta ocupada
		jne 	bonus

bonus_baixo_imprime:
		inc 	POSy
		goto_xy	POSxa,POSya				; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car					; Repoe Caracter guardado
		int		21H

		goto_xy	POSx,POSy				; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh,0					; numero da p�gina
		int		10h
		mov		Car, al					; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah					; Guarda a cor que est� na posi��o do Cursor

		goto_xy	POSx,POSy				; Vai para posi��o do cursor

		call imprime1
		loop bonus_baixo
		jmp bonus

bonus_baixo_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_cima_imprime

bonus_direita:
		inc 	ProxPOSx
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_direita_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada

bonus_direita_imprime:
		jne 	bonus
		inc 	POSx
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

		call 	imprime1
		loop 	bonus_direita
		jmp 	inicio_bonus

bonus_direita_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_direita_imprime

bonus_esquerda:
		dec 	ProxPOSx
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al, 73
		je    bonus_esquerda_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	bonus
bonus_esquerda_imprime:
		dec 	POSx
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

		call imprime1
		loop bonus_esquerda
		jmp bonus
bonus_esquerda_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_esquerda_imprime
