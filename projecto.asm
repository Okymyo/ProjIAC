; *********************************************************************
; *
; * IST-UL
; *
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
BUFFER	EQU	100H	; endereço de memória onde se guarda a tecla		
LINHA	EQU	8000H	; correspondente à linha verificada anteriormente
PINPOUT	EQU	8000H	; endereço do porto de E/S do teclado

; **********************************************************************
; * Código
; **********************************************************************
PLACE		0
início:		
; inicializações gerais
	MOV 	R1, BUFFER	; R1 com endereço de memória BUFFER 
	MOV		R2, PINPOUT	; R2 com o endereço do periférico
reset:
	MOV		R3, 0		; R3 vazio, indica a coluna
	MOV		R4, LINHA	; R4 indica a linha verificada anteriormente
	MOV		R5, 0   	; R5 indica o caracter premido
	MOV 	R6, 10
; corpo principal do programa
ciclo:
	ROL		R4, 1		; alterar linha para verificar a seguinte
	MOVB 	[R2], R4	; escrever no periférico de saída
	MOVB 	R3, [R2]	; ler do periférico de entrada
	CMP 	R4, R6		; comparar 
	JGE		reset		; se o R4 for > 5, reset porque a linha não existe
	AND 	R3, R3		; afectar as flags
	JZ 		ciclo		; nenhuma tecla premida
linha:
	ADD		R5, 4
	SHR 	R4, 1
	JNZ		linha		; se ainda não for zero, ainda há mais a incrementar
coluna:
	ADD		R5, 1
	SHR 	R3, 1
	JNZ		coluna		; se ainda não for zero, ainda há mais a incrementar
	SUB		R5, 5		; incrementámos 1x4 e 1x1 a mais
	MOVB	[R1], R5	; escrever para memoria a tecla
	JMP 	reset		; fazer reset aos registos