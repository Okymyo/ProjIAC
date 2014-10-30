; *********************************************************************
; *
; * IST-UL
; *
; *********************************************************************

; *********************************************************************
; *
; * Modulo: 	lab5.asm
; * Descri��o : Exemplifica o acesso a um teclado (Push Matrix).
; *		L� uma linha do teclado, verificando se h� alguma tecla
; *		premida nessa linha.
; *
; * Nota : 	Observar a forma como se acede aos portos de E/S de 8 bits
; *		atrav�s da instru��o MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
BUFFER	EQU	100H	; endere�o de mem�ria onde se guarda a tecla		
LINHA	EQU	8000H	; correspondente � linha verificada anteriormente
PINPOUT	EQU	8000H	; endere�o do porto de E/S do teclado

; **********************************************************************
; * C�digo
; **********************************************************************
PLACE		0
in�cio:		
; inicializa��es gerais
	MOV 	R1, BUFFER	; R1 com endere�o de mem�ria BUFFER 
	MOV		R2, PINPOUT	; R2 com o endere�o do perif�rico
reset:
	MOV		R3, 0		; R3 vazio, indica a coluna
	MOV		R4, LINHA	; R4 indica a linha verificada anteriormente
	MOV		R5, 0   	; R5 indica o caracter premido
	MOV 	R6, 10
; corpo principal do programa
ciclo:
	ROL		R4, 1		; alterar linha para verificar a seguinte
	MOVB 	[R2], R4	; escrever no perif�rico de sa�da
	MOVB 	R3, [R2]	; ler do perif�rico de entrada
	CMP 	R4, R6		; comparar 
	JGE		reset		; se o R4 for > 5, reset porque a linha n�o existe
	AND 	R3, R3		; afectar as flags
	JZ 		ciclo		; nenhuma tecla premida
linha:
	ADD		R5, 4
	SHR 	R4, 1
	JNZ		linha		; se ainda n�o for zero, ainda h� mais a incrementar
coluna:
	ADD		R5, 1
	SHR 	R3, 1
	JNZ		coluna		; se ainda n�o for zero, ainda h� mais a incrementar
	SUB		R5, 5		; increment�mos 1x4 e 1x1 a mais
	MOVB	[R1], R5	; escrever para memoria a tecla
	JMP 	reset		; fazer reset aos registos