; *********************************************************************
; * P R O J E C T O 
; *********************************************************************

; *********************************************************************
; *
; * Modulo: 	lab5.asm
; * Descrição : Exemplifica o acesso a um teclado (Push Matrix).
; *		Lê uma linha do teclado, verificando se há alguma tecla
; *		premida nessa linha.
; *
; * Nota : 	Observar a forma como se acede aos portos de E/S de 8 bits
; *		através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

BUFFER	EQU	100H				; endereço de memória onde se guarda a tecla		
LINHA	EQU	8000H				; correspondente à linha verificada anteriormente

PSCR_I 	EQU 8000H
PSCR_F	EQU 807FH
POUT1	EQU 0A000H				; endereço dos scores
POUT2	EQU	0C000H				; endereço do porto de E/S do teclado
PIN		EQU 0E000H				; endereço do porto de E/S do teclado

; *********************************************************************************
; * Stack 
; *********************************************************************************

PLACE		1000H
pilha:		TABLE 100H		; espaço reservado para a pilha 
SP_inicial:					; endereço para inicializar SP

; *********************************************************************************
; * Dados
; *********************************************************************************

imagem_hexa:	STRING	00H		; imagem em memória dos displays hexadecimais 
					;(inicializada a zero).

; **********************************************************************
; * Código
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
	MOV 	R1, BUFFER			; R1 com endereço de memória BUFFER 
	MOV		R2, POUT2			; R2 com o endereço do periférico
	MOV 	R3, PIN				; ---
	MOV		R4, 0				; R3 vazio, indica a coluna
	MOV		R5, LINHA			; R4 guarda a linha verificada anteriormente
	MOV		R6, 0   			; R5 indica o caracter premido
	MOV 	R7, 10				; R6 com o valor a comparar
teclado_ciclo:
	ROL		R4, 1				; alterar linha para verificar a seguinte
	MOVB 	[R2], R5			; escrever no periférico de saída
	MOVB 	R4, [R3]			; ler do periférico de entrada
	CMP 	R5, R7				; comparar 
	JGE		teclado_fim			; se a linha a verificar for maior que 4, terminar
	AND 	R4, R4				; afectar as flags
	JZ 		teclado_ciclo		; nenhuma tecla premida
teclado_linha:
	ADD		R6, 4
	SHR 	R5, 1
	JNZ		teclado_linha		; se ainda não for zero, ainda há mais a incrementar
teclado_coluna:
	ADD		R6, 1
	SHR 	R4, 1
	JNZ		teclado_coluna		; se ainda não for zero, ainda há mais a incrementar
	SUB		R6, 5				; incrementámos 1x4 e 1x1 a mais
	MOVB	[R1], R6			; escrever para memoria a tecla
teclado_fim:
	POP 	R7					; POP
	POP		R6					; POP?
	POP 	R5					; POP POP POP
	POP 	R4					; POP POP
	POP 	R3					; POP POP BEEP?
	POP 	R2					; POP POP POP POP!
	POP 	R1					; POP
	RET