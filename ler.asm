
variaveis para Ler ficheiro TOP 10
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
		
	ler_tempo:
	
		mov 		cx, 9							;; vai ler 8 bytes de cada vez para preencher a hora
		lea			dx, tempo_top10
		jmp 		ler_ciclo2
		
		
	ler_ciclo1:									; contador vai servir para defenir o numero de bits que se vai ler do ficheiro de cada vez;
			
		cmp			contador, 2				; se contador for igual a 1 vai para ler nome
		je			ler_nome
		
		cmp 		contador, 1				; se contador for igual a 2 vai para ler tempo
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