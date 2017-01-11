



org 00h
	JMP	INIT


.org 0Bh			; obs\u0142uga przerwania od T0
	JMP	T0_IR

.org 30h
INIT:

			;Kgfedcba	- K to kropka
	MOV	P0, 	#01000000b
	;MOV	P1,	#00001001b	;wybór wyswietlacza
	MOV	P1,	#00000000b	;wybór wyswietlacza


	;MOV	DPTR, #LED_TABLE
	;MOV	P

MAIN:
	JMP	MAIN

T0_IR:
	MOV	TL0,	#0xBE	; reset zegara
	MOV	TH0,	#0xFC

	DJNZ	R0,	KONIEC

	MOV	R0,	#100	; reset licznika

KONIEC:
	RETI





	

LED_TABLE:
DB 11000000b; 0
DB 11111001b; 1
DB 10100100b; 2
DB 10110000b; 3
DB 10011001b; 4
DB 10010010b; 5
DB 10000010b; 6
DB 11111000b; 7
DB 10000000b; 8
DB 10000010b; 9

.end