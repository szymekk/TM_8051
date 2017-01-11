org 00h
	JMP	INIT


.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 30h
INIT:
	MOV	TMOD,	#0x1	; tryb 16-bitowy
	MOV	TL0,	#0xDB	; 0xF7DB = 63451, dla przerwań co 2,5 ms (400 Hz) -> całość 100 Hz
	MOV	TH0,	#0xF7

			;Kgfedcba	- K to kropka
	MOV	P0, 	#01000000b	;liczba
	MOV	P1,	#00001001b	;wybór wyswietlacza

	


	MOV	DPTR, #LED_TABLE

	MOV R0, #0;		; inicjalizacja licznik wyboru zegara

	SETB	EA		; globalne zezwolenie na przerwania
	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

MAIN:
	JMP	MAIN

T0_IR:
	MOV	TL0,	#0xDB	; reset zegara
	MOV	TH0,	#0xF7

CHOOSE_DISP:
	INC	R0;
	CJNE R0, #04h, CHANGE_DISP
	
	MOV	R0,	#0	; reset licznika

CHANGE_DISP:
	MOV	P1,	#00000000b	;wyłączenie wszystkich



	CJNE R0, #00h, AFTER_FIRST
	MOV	A,	#4
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000001b	;włącz pierwszy
	JMP	KONIEC

AFTER_FIRST:
	CJNE R0, #01h, AFTER_SECOND
	MOV	A,	#5
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000010b	;włącz drugi
	JMP	KONIEC

AFTER_SECOND:
	CJNE R0, #02h, FOURTH
	MOV	A,	#6
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000100b	;włącz trzeci
	JMP	KONIEC
	
FOURTH:
	MOV	A,	#7
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00001000b	;włącz czwarty

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

