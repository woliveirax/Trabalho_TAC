jogo_alternativo proc
			; Reinicia o contador do jogo
			mov Game_Time_h,0
			mov Game_Time_m,0
			mov Game_Time_s,0
			
			; O labirinto por omissao estará guardado dento de um ficheiro chamado def.txt.
			; Este ficheiro so sera alterado quando for feita a alteracao no menu de alterar labirinto por omissao.
	restart:
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
			

	inicio_bonus:		
			;Inicializa posicoes anteriores ( pois no inicio do jogo nao existem posicoes anteriores )
			goto_xy	POSx,POSy	; Vai para nova possi��o
			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 	POSya, al

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
			je  fim

			cmp al, 48
			jb inicio_bonus
			cmp al, 97
			jb	inicio_bonus
			cmp al, 102
			ja  inicio_bonus

			cmp al,27
			jne	inicio_bonus
			jmp fim

	bonus_cima:
			dec 	ProxPOSy
			goto_Prox_xy ProxPOSx,ProxPOSy  ; Mudar de posicao para a seguinte
			
			cmp   	al, 70
			je   	ganhou

			cmp 	al, 20h 				; Verificacao se esta esta ocupada
			jne 	inicio_bonus

	bonus_cima_imprime:
			dec 	POSy
			goto_xy	POSxa,POSya	
			; Vai para a posi��o anterior do cursor
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

			loop bonus_cima
			jmp inicio_bonus

	bonus_baixo:
			inc 	ProxPOSy
			goto_Prox_xy ProxPOSx,ProxPOSy  ; Mudar de posicao para a seguinte

			cmp   al, 70
			je    ganhou

			cmp 	al, 20h ; Verificacao se esta esta ocupada
			jne 	inicio_bonus

	bonus_baixo_imprime:
			inc 	POSy
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

			loop bonus_baixo
			jmp inicio_bonus

	bonus_direita:
			inc 	ProxPOSx
			goto_Prox_xy ProxPOSx,ProxPOSy  ; Mudar de posicao para a seguinte

			cmp   al, 70
			je    ganhou

			cmp 	al, 20h ; Verificacao se esta esta ocupada
			jne		inicio_bonus

	bonus_direita_imprime:
			jne 	inicio_bonus
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

			loop 	bonus_direita
			jmp 	inicio_bonus

	bonus_esquerda:
			dec 	ProxPOSx
			goto_Prox_xy ProxPOSx,ProxPOSy  ; Mudar de posicao para a seguinte

			cmp   al, 70
			je    ganhou

			cmp 	al, 20h ; Verificacao se esta esta ocupada
			jne 	inicio_bonus

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

			loop bonus_esquerda
			jmp inicio_bonus
	
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
			; trata o top 10
			xor si,si
			xor di,di
			call Ler_Dados_Ficheiro_Top10
			call top10_incrementa_novo_jogador
			call Escreve_dados_Ficheiro_Top10

			call apaga_ecran

			goto_xy	37,10
			MOSTRA msgGanhou

			goto_xy 0,14
			MOSTRA	msgInfoWin
			
			mov	ah,0
			call LE_TECLA
			
			call apaga_ecran
			goto_xy 15,5
			call display_TOP10
			
			mov ah,0
			call LE_TECLA
			
	fim:
		ret

jogo_alternativo endp