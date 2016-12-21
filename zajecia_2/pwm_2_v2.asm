;program realizujący świecenie diodą z różną jasnością poprzez modulację PWM
;przyciski P0.0 - P0.7 sterują jasnością

;przerwania co 1000 Hz
;zegar taktowany częstotliwością 10 MHz

.org 00h
	JMP	INIT

.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#0x1	; tryb 16-bitowy
	MOV	TL0,	#0xBE	; 0xFCBE = 64702, dla przerwań co 1 ms (1000 Hz)
	MOV	TH0,	#0xFC

	MOV	R2,	#20	; łączna ilość okresów ON + OFF
	MOV	R1,	#5	; początkowa jasność

	CLR	22h.2		; flaga wyboru (1 - ON), (0 - OFF)
	
	MOV	A,	R1
	MOV	R0,	A	; ilość okresów ON w pierwszym przebiegu

	CLR	P2.1		; dla porównania
	CLR	P2.2
	CLR	P2.1		; dla porównania
	
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
	
	JBC	0x22.2,	ON	; wybór gałęzi ON/OFF
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
	MOV	R1,	#1	; R1 = ON
	JNB	P0.0,	SET_TIME
	MOV	R1,	#2
	JNB	P0.1,	SET_TIME
	MOV	R1,	#3
	JNB	P0.2,	SET_TIME	
	MOV	R1,	#5
	JNB	P0.3,	SET_TIME
	MOV	R1,	#7
	JNB	P0.4,	SET_TIME
	MOV	R1,	#9
	JNB	P0.5,	SET_TIME
	MOV	R1,	#12
	JNB	P0.6,	SET_TIME
	MOV	R1,	#15
	JNB	P0.7,	SET_TIME
	MOV	R1,	#20
	
	JMP	SET_TIME
.end


