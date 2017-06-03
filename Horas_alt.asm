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

		;####################################################################################################################

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

MOSTRA MACRO str

	mov ah,09h
	lea dx, str 
	int 21h

endm

