;program realizujący świecenie diodą
;jasność regulowana poprzez PWM

;przerwania co 1000 Hz
;zegar taktowany częstotliwością 10 MHz

.org 00h
	JMP	INIT

.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	; parametry programu
	MOV	TMOD,	#01h	; tryb 16-bitowy
	MOV	TL0,	#0BEh	; 0xFCBE = 64702, dla przerwań co 1 ms (1000 Hz)
	MOV	TH0,	#0FCh
	MOV	R3,	#20	; łączna ilość okresów ON + OFF
	MOV	R2,	#1	; ilość okresów ON

	MOV	A,	R2
	MOV	R0,	A	; R0 zlicza przerwania

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

	MOV	R1,	#1	; wybranie trybu OFF po pierwszym przebiegu

	CLR	P2.1		; dla porównania
	CLR	P2.2		; włączenie diody
	CLR	P2.3		; dla porównania
	
MAIN:
	JMP	MAIN
	
T0_IR:
	MOV	TL0,	#0BEh	; reset zegara
	MOV	TH0,	#0FCh

	DJNZ	R0,	WAIT_1_MS

	MOV	A,	R2
	MOV	R0,	A	; R0 = ON

	DJNZ	R1,	ON
OFF:	MOV	R1,	#2;

	SETB	P2.2

	MOV	A,	R3	; A = ON + OFF
	SUBB	A,	R0	; A = A - R0 = OFF
	MOV	R0,	A	; reset licznika do ilości cykli OFF

	RETI

ON:	CLR	P2.2
	RETI

WAIT_1_MS:
	RETI			; powrót
.end
