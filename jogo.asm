; *********************************************************************
; * P R O J E C T O 
; *********************************************************************
;
;
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

BUFFER	EQU	100H				; endereco de memoria onde se guarda a tecla		
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
					;(inicializada a zero).

; **********************************************************************
; * Codigo
; **********************************************************************
PLACE		0
MOV SP, SP_inicial
CALL limpar_ecra
ciclo:
	CALL	teclado
	MOV 	R1, 0H
	MOV	 	R2, 8H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 1H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 0H
	MOV 	R3, 0
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 1H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 0H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 1H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 0H
	MOV 	R3, 1
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 1H
	MOV 	R3, 0
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 0H
	MOV 	R3, 0
	CALL 	escrever_pixel
	MOV 	R1, 0H
	MOV	 	R2, 1H
	MOV 	R3, 0
	CALL 	escrever_pixel
	JMP		ciclo
teclado:		
	PUSH	R1
	PUSH 	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH	R7
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
	MOVB 	[R2], R5			; Escrever no periferico de saída
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
	MOVB	[R1], R6			; Escrever para memoria a tecla que pode ser nulo (10)
	POP 	R7					; POP
	POP		R6					; POP?
	POP 	R5					; POP POP POP
	POP 	R4					; POP POP
	POP 	R3					; POP POP BEEP?
	POP 	R2					; POP POP POP POP!
	POP 	R1					; POP
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
	MOVB	[R1], R3
	ADD		R1, R4
	CMP 	R1, R2
	JLE		ciclo_limpeza
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


	
escrever_pixel2: 				; escrever_pixel(linha,coluna)
	;R1 linha
	;R2 coluna
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV R3, R2
	MOV R4, 4
	MUL R1, R4					; multiplicar 4 a R1
	MOV R4, 8000H
	ADD R1, R4					; somar 8000H a R1
	MOV R4, 8
	DIV R2, R4					; dividir 8 a R3
	ADD R2, R1					; somar R3 a R1
	MOD R2, R4					; resto da divisão de R2 por 8
	
	MOVB [R1], R2
	
	POP R4
	POP R3
	POP R2
	POP R1
	RET

prototipo_mascaras:
	
	