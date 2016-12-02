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

	MOV R1, #1
	MOV R0, #7		; inicjalizacja licznika przerwać
				; sto przerwań mija co 100 ms (10 Hz)

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0
	
MAIN:
	JMP	MAIN
	
T0_IR:
	MOV	TL0,	#0BEh	; reset zegara
	MOV	TH0,	#0FCh

	DJNZ	R0,	WAIT_1_MS
	
	DJNZ	R1,	ON
	MOV	R1,	#2;

OFF:	SETB	P2.2
	MOV	R0,	#3	; reset licznika do 3 ms ON
	RETI
	
ON:	CLR	P2.2
	MOV	R0,	#7	; reset licznika do 7 ms ON
	RETI


WAIT_1_MS:
	RETI			; powrót

.end