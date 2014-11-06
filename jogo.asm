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
ciclo:
	CALL	teclado
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
	ROL		R5, 1				; alterar linha para verificar a seguinte
	CMP 	R5, R7				; comparar para saber se ainda "existe" a linha
	JGE		teclado_fim			; se a linha a verificar for maior que 4, terminar
	MOVB 	[R2], R5			; escrever no periferico de saída
	MOVB 	R4, [R3]			; ler do periferico de entrada
	AND 	R4, R4				; afectar as flags
	JZ 		teclado_ciclo		; nenhuma tecla premida
teclado_linha:
	ADD		R6, 4
	SHR 	R5, 1
	JNZ		teclado_linha		; se ainda nao for zero, ainda ha mais a incrementar
teclado_coluna:
	ADD		R6, 1
	SHR 	R4, 1
	JNZ		teclado_coluna		; se ainda nao for zero, ainda ha mais a incrementar
	SUB		R6, 15H				; incrementamos 1x4 e 1x1 a mais, e o 1 inicial de 'vazio'
teclado_fim:
	MOVB	[R1], R6			; escrever para memoria a tecla que pode ser nulo (10)
	POP 	R7					; POP
	POP		R6					; POP?
	POP 	R5					; POP POP POP
	POP 	R4					; POP POP
	POP 	R3					; POP POP BEEP?
	POP 	R2					; POP POP POP POP!
	POP 	R1					; POP
	RET
	
	
escrever_pixel: 				; escrever_pixel(linha,coluna)
	MOV R1, linha
	MOV R2, coluna
	PUSH R3
	MOV R3, R2
	
	MUL R1, 4      				; multiplicar 4 a R1
	ADD R1, 8000H 				; somar 8000H a R1
	DIV R3, 8000H  				; dividir 8000H a R3
	ADD R1, R3	   				; somar R3 a R1
	MOD R2, 8      				; resto da divisão de R2 por 8
	
	POP R3
	RET

	CALL escrever_pixel
