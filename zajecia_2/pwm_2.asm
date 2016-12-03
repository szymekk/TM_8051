;program realizujący PWM przerwania co 1000 Hz

;zegar taktowany częstotliwością 10 MHz

.org 00h
	JMP	INIT

.org 0Bh			; obługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#01h	; tryb 16-bitowy

	MOV	TL0,	#0BEh	; 0xFCBE = 64702, dla przerwań co 1 ms (1000 Hz)
	MOV	TH0,	#0FCh

	CLR	P2.2

	MOV	R2,	#8	; łączna ilość okresów ON + OFF
	MOV	R0,	#7	; ilość okresów ON

	;MOV	R1,	#1
	CLR	22h.2		; flaga wyboru (1 - ON), (0 - OFF)
	
	;MOV	R0,	#7	; inicjalizacja licznika przerwań

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

;*****TEST********************
	;CLR P0.0
	MOV P0, #0FFh
;*****TEST********************	
MAIN:
	JMP	MAIN
	
T0_IR:
	MOV	TL0,	#0BEh	; reset zegara
	MOV	TH0,	#0FCh

	DJNZ	R0,	WAIT_1_MS
SKIP:
	MOV	R0,	#2	; R0 = ON
	JNB	P0.0,	LED
	MOV	R0,	#4
	JNB	P0.1,	LED
	MOV	R0,	#6
	JNB	P0.2,	LED
	;MOV	R0,	#8	;R0 się zeruje!!!
	MOV	R0,	#0	;R0 się zeruje!!!

;LED:	DJNZ	R1,	ON
;OFF:	MOV	R1,	#2;
LED:	JBC	22h.2,	ON
OFF:	SETB	22h.2

	SETB	P2.2		; zgaś diodę

	MOV	A,	R2	; A = ON + OFF
	SUBB	A,	R0	; A = A - R0 = OFF
	MOV	R0,	A	; reset licznika do ilości cykli OFF

	JMP WAIT_1_MS

ON:	CLR	P2.2		; zapal diodę
	

WAIT_1_MS:
	MOV	A,	R0
	JZ	SKIP
	RETI			; powrót
.end

