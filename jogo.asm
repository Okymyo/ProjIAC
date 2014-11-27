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

BUFFER	EQU	500H					; endereco de memoria onde se guarda a tecla
POS_B	EQU 600H					; endereco de memoria onde se guarda posicao do boneco		
LINHA	EQU	8000H					; correspondente a linha 1 antes do ROL

PSCR_I 	EQU 8000H
PSCR_F	EQU 807FH
POUT1	EQU 0A000H					; endereco dos scores
POUT2	EQU	0C000H					; endereco do porto de E/S do teclado
PIN		EQU 0E000H					; endereco do porto de E/S do teclado

; *********************************************************************************
; * Stack 
; *********************************************************************************

PLACE		1000H
pilha:		TABLE 100H				; espaco reservado para a pilha 
SP_inicial:							; endereco para inicializar SP

; *********************************************************************************
; * Dados
; *********************************************************************************

imagem_hexa:	STRING	00H			; imagem em memoria dos displays hexadecimais

PLACE		2000H
boneco_raquete:
			STRING 		1000b
			STRING 		1010b
			STRING 		1111b
			STRING 		0010b
			STRING 		0101b
			
robot_desenho:
			STRING		110b
			STRING		111b
			STRING		110b
			
PLACE		2100H
boneco_tamanho:	
			STRING		4, 5		; Numero de colunas, linhas
			
robot_tamanho:
			STRING		3, 3		; Numero de colunas, linhas
				
PLACE 		2200H
teclado_movimento:					;teclado_movimento com alteracoes linha, coluna
			WORD 0FFFFH				;0
			WORD 0FFFFH				;0
			WORD 0FFFFH				;1
			WORD 0					;1
			WORD 0FFFFH				;2
			WORD 1					;2
			WORD 0					;3
			WORD 0					;3
			WORD 0					;4
			WORD 0FFFFH				;4
			WORD 0					;5
			WORD 0					;5
			WORD 0					;6
			WORD 1					;6
			WORD 0					;7
			WORD 0					;7
			WORD 1					;8
			WORD 0FFFFH				;8
			WORD 1					;9
			WORD 0					;9
			WORD 1					;a
			WORD 1					;a
			WORD 0					;b
			WORD 0					;b
			WORD 0					;c
			WORD 0					;c
			WORD 0					;d
			WORD 0					;d
			WORD 0					;e
			WORD 0					;e
			WORD 0					;f
			WORD 0					;f
			
; **********************************************************************
; * Codigo
; **********************************************************************
PLACE		0H
	MOV 	SP, SP_inicial
	CALL 	reset
	MOV 	R1, 8
	MOV		R2, 17
	CALL	escrever_robot
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
	MOV 	R1, BUFFER				; R1 com endereco de memoria BUFFER 
	MOV		R2, POUT2				; R2 com o endereco do periferico
	MOV 	R3, PIN					; R3 com endereco de input do teclado
	MOV		R4, 0					; R4 vazio, indica a coluna
	MOV		R5, LINHA				; R5 guarda a linha verificada anteriormente
	MOV		R6, 010H   				; R6 indica o caracter premido, 10 indica 'vazio'
	MOV 	R7, 10					; R7 com o valor a comparar
teclado_ciclo:
	ROL		R5, 1					; Alterar linha para verificar a seguinte
	CMP 	R5, R7					; Comparar para saber se ainda "existe" a linha
	JGE		teclado_fim				; Se a linha a verificar for maior que 4, terminar
	MOVB 	[R2], R5				; Escrever no periferico de saida
	MOVB 	R4, [R3]				; Ler do periferico de entrada
	AND 	R4, R4					; Afectar as flags
	JZ 		teclado_ciclo			; Nenhuma tecla premida
teclado_linha:
	ADD		R6, 4
	SHR 	R5, 1
	JNZ		teclado_linha			; Se ainda nao for zero, ainda ha mais a incrementar
teclado_coluna:
	ADD		R6, 1
	SHR 	R4, 1
	JNZ		teclado_coluna			; Se ainda nao for zero, ainda ha mais a incrementar
	MOV		R7, 15H
	SUB		R6, R7					; Incrementamos 1x4 e 1x1 a mais, e o 1 inicial de 'vazio'
teclado_fim:
	MOVB 	R8, [R1]				; Guardar tecla premida anteriormente (ou 10 caso vazia)
	MOVB	[R1], R6				; Escrever para memoria a tecla que pode ser nulo (10)
	ADD 	R1, 1
	MOVB 	[R1], R8				; Escrever para memoria a tecla premida anteriormente
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
	MOV 	R1, PSCR_I 				; Primeiro endereco do ecra
	MOV 	R2, PSCR_F				; Ultimo endereco do ecra
	MOV		R3, 0
	MOV		R4, 1
ciclo_limpeza:
	MOVB	[R1], R3				; Apagar o byte
	ADD		R1, R4					; Avancar para o proximo byte
	CMP 	R1, R2					; Comparar o endereco actual com o ultimo
	JLE		ciclo_limpeza			; Caso nao seja o ultimo, continuar a limpar
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET


escrever_pixel:
	PUSH 	R1 						; Guarda a linha
	PUSH 	R2						; Guarda a coluna
	PUSH 	R3						; Guarda o valor (aceso ou apagado)
	PUSH 	R4						; Registo auxiliar 1
	PUSH 	R5						; Registo auxiliar 2
	PUSH	R6						; Registo auxiliar 3
	
	; Byte a alterar = L*4 + C/8 + 8000H
	MOV 	R5, 4
	MUL 	R1, R5					; L*4
	
	MOV		R5, 8
	MOV		R4, R2	
	DIV 	R4, R5					; C/8
	ADD 	R1, R4					; L*4 + C/8

	MOV 	R5, 8000H
	ADD 	R1, R5					; L*4 + C/8 + 8000H
	
	; Fazer modulo, visto que MOD causa problemas (acusa negativo quando resto 0)
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
	MOVB 	R6, [R1]				; Guardar o valor anterior do byte
	AND 	R3, R3
	JZ 		escrever_desligar
escrever_ligar:
	OR 		R4, R6					; Mascara para preservar o valor anterior
	JMP		escrever_fim
escrever_desligar:
	MOV 	R5, 0FFH
	XOR 	R4, R5
	AND 	R4, R6					; Mascara para preservar o valor anterior
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
	PUSH	R1 						; Linha para funcao escrever_pixel
	PUSH 	R2						; Coluna para funcao escrever_pixel
	PUSH 	R3						; Aceso ou apagado para funcao escrever_pixel
	PUSH 	R4						; Guardar coluna canto superior esquerdo
	PUSH 	R5						; Valor de auxilio
	PUSH 	R6						; Contador de colunas
	PUSH 	R7						; Contador de linhas
	PUSH 	R8						; Mascara
	PUSH 	R9						; Posicao de desenho de tenista em memoria
	SUB 	R1, 1
	MOV 	R4, R2
	MOV		R7, boneco_tamanho	
	ADD		R7, 1
	MOVB	R7, [R7]				; Numero maximo de linhas
	ADD 	R7, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	MOV 	R9, boneco_raquete
escrever_boneco_linha:
	SUB 	R7, 1					; Subtrair 1 ao contador para verificar se existem mais linhas
	JZ		escrever_boneco_fim		; Caso tenham acabado as linhas, terminar
	MOVB 	R5, [R9]
	ADD 	R9, 1
	MOV		R6, boneco_tamanho	
	MOVB	R6, [R6]				; Numero maximo de colunas
	ADD 	R6, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	ADD 	R1, 1
	MOV 	R2, R4
escrever_boneco_coluna:
	MOV 	R3, R5
	MOV 	R8, 1
	AND 	R3, R8					; Isolar bit de menor valor
	CALL 	escrever_pixel
	ADD 	R2, 1
	SHR 	R5, 1					; Avancar para o proximo bit
	SUB 	R6, 1					; Subtrair 1 ao contador para verificar se existem mais colunas
	JNZ 	escrever_boneco_coluna	; Caso haja mais colunas para desenhar, continuar
	JMP 	escrever_boneco_linha	; Caso tenha terminado a linha, terminar ciclo
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
	
apagar_boneco:
	PUSH	R1 						; Linha para funcao escrever_pixel
	PUSH 	R2						; Coluna para funcao escrever_pixel
	PUSH 	R3						; Apagado para funcao escrever_pixel
	PUSH 	R4						; Valores de auxilio
	PUSH 	R5
	PUSH	R6
	SUB 	R1, 1
	MOV		R3, 0					; Apagar sempre o pixel
	MOV		R6, R2
	MOV		R5, boneco_tamanho	
	ADD		R5, 1
	MOVB	R5, [R5]				; Numero maximo de linhas
	ADD 	R5, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
apagar_boneco_linha:
	SUB 	R5, 1
	JZ		apagar_boneco_fim
	MOV		R4, boneco_tamanho	
	MOVB	R4, [R4]				; Numero maximo de colunas
	ADD 	R4, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	ADD 	R1, 1
	MOV		R2, R6
apagar_boneco_coluna:
	CALL 	escrever_pixel
	ADD 	R2, 1
	SUB 	R4, 1
	JNZ 	apagar_boneco_coluna
	JMP 	apagar_boneco_linha
apagar_boneco_fim:
	POP		R6
	POP 	R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET

escrever_robot:
	PUSH	R1 						; Linha para funcao escrever_pixel
	PUSH 	R2						; Coluna para funcao escrever_pixel
	PUSH 	R3						; Aceso ou apagado para funcao escrever_pixel
	PUSH 	R4						; Guardar coluna canto superior esquerdo
	PUSH 	R5						; Valor de auxilio
	PUSH 	R6						; Contador de colunas
	PUSH 	R7						; Contador de linhas
	PUSH 	R8						; Mascara
	PUSH 	R9						; Posicao de desenho de tenista em memoria
	SUB 	R1, 1
	MOV 	R4, R2
	MOV		R7, robot_tamanho	
	ADD		R7, 1
	MOVB	R7, [R7]				; Numero maximo de linhas
	ADD 	R7, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	MOV 	R9, robot_desenho
escrever_robot_linha:
	SUB 	R7, 1					; Subtrair 1 ao contador para verificar se existem mais linhas
	JZ		escrever_robot_fim		; Caso tenham acabado as linhas, terminar
	MOVB 	R5, [R9]
	ADD 	R9, 1
	MOV		R6, robot_tamanho	
	MOVB	R6, [R6]				; Numero maximo de colunas
	ADD 	R6, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	ADD 	R1, 1
	MOV 	R2, R4
escrever_robot_coluna:
	MOV 	R3, R5
	MOV 	R8, 1
	AND 	R3, R8					; Isolar bit de menor valor
	CALL 	escrever_pixel
	ADD 	R2, 1
	SHR 	R5, 1					; Avancar para o proximo bit
	SUB 	R6, 1					; Subtrair 1 ao contador para verificar se existem mais colunas
	JNZ 	escrever_robot_coluna	; Caso haja mais colunas para desenhar, continuar
	JMP 	escrever_robot_linha	; Caso tenha terminado a linha, terminar ciclo
escrever_robot_fim:
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
	
apagar_robot:
	PUSH	R1 						; Linha para funcao escrever_pixel
	PUSH 	R2						; Coluna para funcao escrever_pixel
	PUSH 	R3						; Apagado para funcao escrever_pixel
	PUSH 	R4						; Valores de auxilio
	PUSH 	R5
	PUSH	R6
	SUB 	R1, 1
	MOV		R3, 0					; Apagar sempre o pixel
	MOV		R6, R2
	MOV		R5, robot_tamanho	
	ADD		R5, 1
	MOVB	R5, [R5]				; Numero maximo de linhas
	ADD 	R5, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
apagar_robot_linha:
	SUB 	R5, 1
	JZ		apagar_robot_fim
	MOV		R4, robot_tamanho	
	MOVB	R4, [R4]				; Numero maximo de colunas
	ADD 	R4, 1					; Adicionar um porque se realiza uma subtraccao (de 1) a mais
	ADD 	R1, 1
	MOV		R2, R6
apagar_robot_coluna:
	CALL 	escrever_pixel
	ADD 	R2, 1
	SUB 	R4, 1
	JNZ 	apagar_robot_coluna
	JMP 	apagar_robot_linha
apagar_robot_fim:
	POP		R6
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
	PUSH	R5
	PUSH	R6
	PUSH	R7
	PUSH	R8
	PUSH	R9
	MOV		R3, BUFFER
	MOVB 	R3, [R3]				; R3 possui a tecla carregada actualmente
	MOV 	R2, BUFFER
	ADD 	R2, 1					; R2 possui a tecla carregada anteriormente
	MOVB	R2, [R2]
	CMP 	R3, R2					; Apenas se processa se a tecla premida anteriormente for maior que a premida
	JGE 	movimento_fim			; pois 10H (nula) e maior que todas as teclas premidas.
									; Se a tecla premida for nula, sera maior ou igual, logo jump
									; Se a tecla premida nao mudar, sera igual, logo jump.
	MOV 	R1, POS_B
	MOVB	R1, [R1]				; Guardar em R1 a linha actual
	MOV 	R2, POS_B
	ADD 	R2, 1
	MOVB	R2, [R2]				; Guardar em R2 a coluna actual
	
	MOV		R7, R1					; Guardar em R7 a linha actual	(para limpeza)
	MOV		R8, R2					; Guardar em R8 a coluna actual (para limpeza)
	
	MOV 	R4, teclado_movimento	; Endereco onde se guarda tabela de movimentos
	SHL		R3, 2					; Multiplicar por 4 (2 words, 2 bytes por word)
	ADD		R4, R3					; Somar para obter endereco de movimento para a tecla carregada
	MOV		R4, [R4]				; Guardar deslocamento para linha
	ADD 	R1, R4					; Aplicar o deslocamento da linha
	ADD 	R3, 2					; Preparar para avancar para proximo word
	MOV		R4, teclado_movimento	; Repetir passos anteriores mas agora para o endereco seguinte (+2)
	ADD		R4, R3
	MOV		R4, [R4]
	ADD 	R2, R4					; Aplicar o deslocamento da coluna

	MOV		R5, 21H					; 33 em hexadecimal, dimensao horizontal maxima do ecra (31) + erros na subtracção (subtrai +2)
	MOV		R6, boneco_tamanho
	MOVB	R6, [R6]
	SUB		R5, R6					; Obter coluna mais a direita possivel para canto superior esquerdo
	MOV 	R6, robot_tamanho
	MOVB	R6, [R6]
	SUB		R5, R6
	CMP		R2, R5
	JZ		falha_ver_horizontal	; Se exceder à direita, terminar
	CMP		R2, 0
	JGE		termina_ver_horizontal
falha_ver_horizontal:
	MOV		R2, R8
termina_ver_horizontal:

	MOV		R5, 21H					; 33 em hexadecimal, dimensao vertical maxima do ecra (31) + erros na subtracção (subtrai +2)
	MOV		R6, boneco_tamanho
	ADD		R6, 1
	MOVB	R6, [R6]
	SUB		R5, R6					; Obter linha mais a baixo possivel para canto superior esquerdo
	CMP		R1, R5
	JZ		falha_ver_vertical		; Se exceder à direita, terminar
	CMP		R1, 0
	JGE		termina_ver_vertical
falha_ver_vertical:
	MOV		R1, R7
termina_ver_vertical:	
	MOV		R9, R1					; Trocar R1 com R7
	MOV		R1, R7
	MOV		R7, R9
	MOV		R9, R2					; Trocar R2 com R8
	MOV		R2, R8
	MOV		R8, R9
	CALL	apagar_boneco			; Limpar boneco actual (para redesenhar)
	MOV		R9, R1					; Trocar R1 com R7
	MOV		R1, R7
	MOV		R7, R9
	MOV		R9, R2					; Trocar R2 com R8
	MOV		R2, R8
	MOV		R8, R9
	CALL 	escrever_boneco			; Escrever o novo boneco apos os deslocamentos
	MOV 	R3, POS_B
	MOVB	[R3], R1				; Guardar a linha actual em memoria
	ADD		R3, 1
	MOVB	[R3], R2				; Guardar a coluna actual em memoria
movimento_fim:
	POP		R9
	POP		R8
	POP		R7
	POP		R6
	POP		R5
	POP 	R4
	POP 	R3
	POP 	R2
	POP 	R1
	RET

reset:
	PUSH 	R1
	PUSH 	R2
	CALL 	limpar_ecra				; Executar a limpeza de ecra para reiniciar
	MOV 	R2, 0
	MOV 	R1, POS_B
	MOV 	[R1], R2				; Reinicializar posicao do boneco para 0,0
	MOV		R1, 0
	CALL 	escrever_boneco			; Desenhar o boneco para inicializar
	POP 	R2
	POP 	R1
	RET