; program migający diodą ze stałą częstotliwością
; co 2^16 cykli zegarowych dioda zmienia stan

; zegar 10 Mhz
.org 00h
	JMP	INIT

.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#01h	; tryb 16-bitowy
	MOV	TL0,	#00h	; zerowanie zegara
	MOV	TH0,	#00h

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0
MAIN:
	JMP	MAIN
	
T0_IR:
	MOV	TL0,	#00h	; zerowanie zegara
	MOV	TH0,	#00h

	CPL	P2.2

	RETI			; powrót

.end