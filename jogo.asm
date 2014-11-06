; *********************************************************************
; * P R O J E C T O 
; *********************************************************************
;
;
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

BUFFER	EQU	100H				; endere�o de mem�ria onde se guarda a tecla		
LINHA	EQU	8000H					; correspondente � linha 1 antes do ROL

PSCR_I 	EQU 8000H
PSCR_F	EQU 807FH
POUT1	EQU 0A000H				; endere�o dos scores
POUT2	EQU	0C000H				; endere�o do porto de E/S do teclado
PIN		EQU 0E000H				; endere�o do porto de E/S do teclado

; *********************************************************************************
; * Stack 
; *********************************************************************************

PLACE		1000H
pilha:		TABLE 100H		; espa�o reservado para a pilha 
SP_inicial:					; endere�o para inicializar SP

; *********************************************************************************
; * Dados
; *********************************************************************************

imagem_hexa:	STRING	00H		; imagem em mem�ria dos displays hexadecimais 
					;(inicializada a zero).

; **********************************************************************
; * C�digo
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
	MOV 	R1, BUFFER			; R1 com endere�o de mem�ria BUFFER 
	MOV		R2, POUT2			; R2 com o endere�o do perif�rico
	MOV 	R3, PIN				; R3 com endere�o de input do teclado
	MOV		R4, 0				; R4 vazio, indica a coluna
	MOV		R5, LINHA			; R5 guarda a linha verificada anteriormente
	MOV		R6, 0   			; R6 indica o caracter premido
	MOV 	R7, 10				; R7 com o valor a comparar
teclado_ciclo:
	ROL		R5, 1				; alterar linha para verificar a seguinte
	CMP 	R5, R7				; comparar para saber se ainda "existe" a linha
	JGE		teclado_fim			; se a linha a verificar for maior que 4, terminar
	MOVB 	[R2], R5			; escrever no perif�rico de sa�da
	MOVB 	R4, [R3]			; ler do perif�rico de entrada
	AND 	R4, R4				; afectar as flags
	JZ 		teclado_ciclo		; nenhuma tecla premida
teclado_linha:
	ADD		R6, 4
	SHR 	R5, 1
	JNZ		teclado_linha		; se ainda n�o for zero, ainda h� mais a incrementar
teclado_coluna:
	ADD		R6, 1
	SHR 	R4, 1
	JNZ		teclado_coluna		; se ainda n�o for zero, ainda h� mais a incrementar
	SUB		R6, 5				; increment�mos 1x4 e 1x1 a mais
	MOVB	[R1], R6			; escrever para memoria a tecla
	; este MOVB tem de ser movido para teclado_fim, para fazer update mesmo quando
	; nenhuma tecla � premida. Apenas est� aqui por motivos de teste!
teclado_fim:
	POP 	R7					; POP
	POP		R6					; POP?
	POP 	R5					; POP POP POP
	POP 	R4					; POP POP
	POP 	R3					; POP POP BEEP?
	POP 	R2					; POP POP POP POP!
	POP 	R1					; POP
	RET