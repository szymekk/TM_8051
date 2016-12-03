;program realizujący PWM przerwania co 1000 Hz
;przyciski P0.0 - P0.3 sterują jasnością PWM

;zegar taktowany częstotliwością 10 MHz

.org 00h
	JMP	INIT

.org 0Bh			; obługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#0x1	; tryb 16-bitowy
	MOV	TL0,	#0xBE	; 0xFCBE = 64702, dla przerwań co 1 ms (1000 Hz)
	MOV	TH0,	#0xFC

	MOV	R2,	#8	; łączna ilość okresów ON + OFF
	MOV	R1,	#5	; początkowa jasność

	CLR	22h.2		; flaga wyboru (1 - ON), (0 - OFF)
	
	MOV	A,	R1
	MOV	R0,	A	; ilość okresów ON w pierwszym przebiegu

	CLR	P2.2
	MOV	P0,	#0xFF

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

MAIN:
	JMP	MAIN



T0_IR:
	MOV	TL0,	#0xBE	; reset zegara
	MOV	TH0,	#0xFC

	DJNZ	R0,	WAIT_1_MS
	
CHECK_BTN:


	MOV	A,	P0
	CJNE	A, #0xFF, CHANGE
	
SET_TIME:
	MOV	A,	R1
	MOV	R0,	A
	
	JBC	0x22.2,	ON	; wybór gałęźi ON/OFF
OFF:	SETB	0x22.2

	SETB	P2.2		; zgaś diodę

	MOV	A,	R2	; A = ON + OFF
	CLR	C
	SUBB	A,	R0	; A = A - R0 = OFF
	MOV	R0,	A	; reset licznika do ilości cykli OFF

	JMP	WAIT_1_MS

ON:	CLR	P2.2		; zapal diodę

WAIT_1_MS:
	MOV	A,	R0
	JZ	CHECK_BTN
	RETI			; powrót




CHANGE:
	MOV	R1,	#2	; R0 = ON
	JNB	P0.0,	SET_TIME
	MOV	R1,	#4
	JNB	P0.1,	SET_TIME
	MOV	R1,	#6
	JNB	P0.2,	SET_TIME
	MOV	R1,	#8
	;MOV	R1,	#0
	JMP	SET_TIME
.end


