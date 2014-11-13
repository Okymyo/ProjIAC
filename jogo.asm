; *********************************************************************
; * P R O J E C T O 
; *********************************************************************

; *********************************************************************
; GRUPO 2:
; 81900 - Nuno Anselmo
; 81938 - Mariana Silva
; 82583 - Miguel Elvas
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

BUFFER	EQU	500H				; endereco de memoria onde se guarda a tecla
POS_B	EQU 600H				; endereco de memoria onde se guarda posicao do boneco		
LINHA	EQU	8000H				; correspondente a linha 1 antes do ROL

PSCR_I 	EQU 8000H
PSCR_F	EQU 807FH
POUT1	EQU 0A000H				; endereco dos scores
POUT2	EQU	0C000H				; endereco do porto de E/S do teclado
PIN		EQU 0E000H				; endereco do porto de E/S do teclado

; *********************************************************************************
; * Stack 
; *********************************************************************************

PLACE		1000H
pilha:		TABLE 100H			; espaco reservado para a pilha 
SP_inicial:						; endereco para inicializar SP

; *********************************************************************************
; * Dados
; *********************************************************************************

imagem_hexa:	STRING	00H		; imagem em memoria dos displays hexadecimais

PLACE		2000H
boneco_raquete:	STRING 		10000000b
			STRING 		10100000b
			STRING 		11110000b
			STRING 		00100000b
			STRING 		01010000b
			STRING 		00000000b
			STRING 		00000000b
			STRING 		00000000b
				
PLACE 		2100H

;teclado_movimento com alteracoes linha, coluna
teclado_movimento: STRING 0FFH, 0FFH;0
			STRING 0FFH, 0			;1
			STRING 0FFH, 1			;2
			STRING 0, 0				;3
			STRING 0, 0FFH			;4
			STRING 0, 0				;5
			STRING 0, 1				;6
			STRING 0, 0				;7
			STRING 1, 0FFH			;8
			STRING 1, 0				;9
			STRING 1, 1				;a
			STRING 0, 0				;b
			STRING 0, 0				;c
			STRING 0, 0				;d
			STRING 0, 0				;e
			STRING 0, 0				;f
			
; **********************************************************************
; * Codigo
; **********************************************************************
PLACE		0H
MOV SP, SP_inicial
CALL limpar_ecra
ciclo:
	CALL	teclado
	CALL	processar_movimento
	JMP		ciclo
teclado:		
	PUSH	R1
	PUSH 	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH	R7
	PUSH 	R8
	MOV 	R1, BUFFER			; R1 com endereco de memoria BUFFER 
	MOV		R2, POUT2			; R2 com o endereco do periferico
	MOV 	R3, PIN				; R3 com endereco de input do teclado
	MOV		R4, 0				; R4 vazio, indica a coluna
	MOV		R5, LINHA			; R5 guarda a linha verificada anteriormente
	MOV		R6, 010H   			; R6 indica o caracter premido, 10 indica 'vazio'
	MOV 	R7, 10				; R7 com o valor a comparar
teclado_ciclo:
	ROL		R5, 1				; Alterar linha para verificar a seguinte
	CMP 	R5, R7				; Comparar para saber se ainda "existe" a linha
	JGE		teclado_fim			; Se a linha a verificar for maior que 4, terminar
	MOVB 	[R2], R5			; Escrever no periferico de saida
	MOVB 	R4, [R3]			; Ler do periferico de entrada
	AND 	R4, R4				; Afectar as flags
	JZ 		teclado_ciclo		; Nenhuma tecla premida
teclado_linha:
	ADD		R6, 4
	SHR 	R5, 1
	JNZ		teclado_linha		; Se ainda nao for zero, ainda ha mais a incrementar
teclado_coluna:
	ADD		R6, 1
	SHR 	R4, 1
	JNZ		teclado_coluna		; Se ainda nao for zero, ainda ha mais a incrementar
	MOV		R7, 15H
	SUB		R6, R7				; Incrementamos 1x4 e 1x1 a mais, e o 1 inicial de 'vazio'
teclado_fim:
	MOVB 	R8, [R1]			; Guardar tecla premida anteriormente (ou 10 caso vazia)
	MOVB	[R1], R6			; Escrever para memoria a tecla que pode ser nulo (10)
	ADD 	R1, 1
	MOVB 	[R1], R8			; Escrever para memoria a tecla premida anteriormente
	POP 	R8
	POP 	R7
	POP		R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET
	
	
limpar_ecra:
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
	MOV 	R1, PSCR_I 			; Primeiro endereco do ecra
	MOV 	R2, PSCR_F			; Ultimo endereco do ecra
	MOV		R3, 0
	MOV		R4, 1
ciclo_limpeza:
	MOVB	[R1], R3			; Apagar o byte
	ADD		R1, R4				; Avancar para o proximo byte
	CMP 	R1, R2				; Comparar o endereco actual com o ultimo
	JLE		ciclo_limpeza		; Caso nao seja o ultimo, continuar a limpar
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET


escrever_pixel:
	PUSH 	R1 					; Guarda a linha
	PUSH 	R2					; Guarda a coluna
	PUSH 	R3					; Guarda o valor (aceso ou apagado)
	PUSH 	R4					; Registo auxiliar 1
	PUSH 	R5					; Registo auxiliar 2
	PUSH	R6					; Registo auxiliar 3
	
	; Byte a alterar = L*4 + C/8 + 8000H
	MOV 	R5, 4
	MUL 	R1, R5				; L*4
	
	MOV		R5, 8
	MOV		R4, R2	
	DIV 	R4, R5				; C/8
	ADD 	R1, R4				; L*4 + C/8

	MOV 	R5, 8000H
	ADD 	R1, R5				; L*4 + C/8 + 8000H
	
	; Fazer modulo, visto que MOD causa problemas (8%8 != 0? e 0%8 != 0?)
	; a%b = a - (a/b)*b
	MOV 	R5, 8
	MOV 	R6, R2
	DIV 	R6, R5
	MUL 	R6, R5
	SUB 	R2, R6
	
	MOV 	R5, 1
	MOV 	R4, 80H
	AND	 	R2, R2
	JZ	 	escrever_memoria
escrever_ciclo:
	SHR 	R4, 1
	SUB 	R2, 1
	JNZ 	escrever_ciclo
escrever_memoria:
	MOVB 	R6, [R1]			; Guardar o valor anterior do byte
	AND 	R3, R3
	JZ 		escrever_desligar
escrever_ligar:
	OR 		R4, R6				; Mascara para preservar o valor anterior
	JMP		escrever_fim
escrever_desligar:
	MOV 	R5, 0FFH
	XOR 	R4, R5
	AND 	R4, R6				; Mascara para preservar o valor anterior
escrever_fim:
	MOVB 	[R1], R4
	
	POP		R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET
	
	
escrever_boneco:
	PUSH	R1 					; Linha para funcao escrever_pixel
	PUSH 	R2					; Coluna para funcao escrever_pixel
	PUSH 	R3					; Aceso ou apagado para funcao escrever_pixel
	PUSH 	R4					; Guardar coluna canto superior esquerdo
	PUSH 	R5					; Valores de auxilio
	PUSH 	R6
	PUSH 	R7
	PUSH 	R8
	PUSH 	R9
	SUB 	R1, 1
	MOV 	R4, R2
	MOV 	R7, 9				; HARDCODED - Numero MAXIMO de linhas de boneco (+1)
	MOV 	R9, boneco_raquete
escrever_ciclo_linha:
	SUB 	R7, 1
	JZ		escrever_boneco_fim
	MOVB 	R5, [R9]
	ADD 	R9, 1
	MOV 	R6, 9				; HARDCODED - Numero MAXIMO de colunas de boneco (+1)
	ADD 	R1, 1
	MOV 	R2, R4
escrever_ciclo_coluna:
	MOV 	R3, R5
	MOV 	R8, 1
	AND 	R3, R8
	CALL 	escrever_pixel
	ADD 	R2, 1
	SHR 	R5, 1
	SUB 	R6, 1
	JNZ 	escrever_ciclo_coluna
	JMP 	escrever_ciclo_linha
escrever_boneco_fim:
	POP 	R9
	POP 	R8
	POP 	R7
	POP 	R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET
	
processar_movimento:
	PUSH 	R1
	PUSH 	R2
	PUSH 	R3
	PUSH 	R4
	MOV		R3, BUFFER
	MOVB 	R3, [R3]			; R3 possui a tecla carregada actualmente
	MOV 	R2, BUFFER
	ADD 	R2, 1				; R2 possui a tecla carregada anteriormente
	MOVB	R2, [R2]
	CMP 	R3, R2				; Apenas se processa se a tecla premida anteriormente for maior que a premida
	JGE 	movimento_fim		; pois 10H (nula) e maior que todas as teclas premidas.
								; Se a tecla premida for nula, sera maior ou igual, logo jump
								; Se a tecla premida nao mudar, sera igual, logo jump.
	MOV 	R1, POS_B
	MOVB	R1, [R1]
	MOV 	R2, POS_B
	ADD 	R2, 1
	MOVB	R2, [R2]
	MOV 	R4, teclado_movimento
	SHL		R3, 1
	ADD		R3, R4
	MOVB	R3, [R3]
	ADD 	R1, R3
	ADD 	R3, 1
	ADD 	R2, R3
	CALL 	escrever_boneco
	MOV 	R3, POS_B
	MOVB	[R3], R1
	ADD		R3, 1
	MOVB	[R3], R2
movimento_fim:
	POP R4
	POP R3
	POP R2
	POP R1
	RET