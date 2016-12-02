;program migający diodą ze stałą częstotliwością wynoszącą 5 Hz
;zmiana stanu diody z częstotliwością 10 Hz

;zegar taktowany częstotliwością 10 MHz

.org 00h
	JMP	INIT

.org 0Bh			; obługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#01h	;tryb 16-bitowy

	MOV	TL0,	#0BEh	; 0xFCBE = 64702, dla przerwań co 1 ms (1000 Hz)
	MOV	TH0,	#0FCh

	MOV R0, #100;		; inicjalizacja licznika przerwać
				; sto przerwań mija co 100 ms (10 Hz)
				; 5 Hz migania diody (czyli 10 Hz zmiana stanu diody)

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0
	
MAIN:
	JMP	MAIN
	
T0_IR:
	MOV	TL0,	#0BEh	; reset zegara
	MOV	TH0,	#0FCh
	
	DJNZ	R0,	koniec;

	MOV	R0,	#100;		; reset licznika
	CPL	P2.2

koniec:
	RETI			; powrót

.end