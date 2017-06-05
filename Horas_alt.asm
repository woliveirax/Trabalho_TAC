.8086
.model small
.stack 2048

dseg	segment para public 'data'
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
		NUMDIG			db		0								; controla o numero de digitos do numero lido
		MAXDIG			db		4								; Constante que define o numero MAXIMO de digitos a ser aceite
		Game_Time_s		dw		0								; segundos
		Game_Time_m		dw		0								; minutos
		Game_Time_h		dw		0								; horas
		POSx			db		0
		POSy			db		0

		;####################################################################################################################

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

MOSTRA MACRO str

	mov ah,09h
	lea dx, str 
	int 21h

endm


goto_xy	macro	POSx,POSy
		mov		ah,02h	;indica que é para mudar o cursor.
		mov		bh,0	;Numero página.
		mov		dl,POSx	;Pos X do ecrã, vai de 0 a 80
		mov		dh,POSy ;Pos Y do ecrã, vai de 0 a 25
		int		10h		;interrupt call
endm



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
;########################################################################

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


Main  proc
		mov		ax, dseg
		mov		ds,ax

		mov 	ax,0B800h	;move o ponteiro para memoria de video para ax
		mov		es,ax		;move o ponteiro para memoria de video de ax para ES

		call 	apaga_ecran
		
		mov 	ah,1
		call	LE_TECLA
	fim:
		mov		ah,4CH
		int		21H

Main	endp
Cseg	ends
end	Main