org 00h
	JMP	INIT


.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 1Bh			; obsługa przerwania od T1
	JMP	T1_IR

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
	;SETB	ET0		; zezwolenie na przerwania od timera 0
	;SETB	TR0		; uruchomienie T0


	;MOV R2, #0		;cyfra
	
	MOV R7, #8		;cyfra na 4
	MOV R6, #6		;cyfra na 3
	MOV R5, #5		;cyfra na 2
	MOV R4, #4		;cyfra na 1
	
	MOV R1, #100		;inicjalizacja licznik przerwań

	MOV	TMOD,	#0x11	; tryb 16-bitowy
	MOV	TL1,	#0x6C	; 0xDF6C = 64702, dla przerwań co 10 ms (100 Hz)
	MOV	TH1,	#0xDF

	SETB	ET1		; zezwolenie na przerwania od timera 1
	SETB	TR1		; uruchomienie T1

	SETB	ET0
	SETB	TR0

MAIN:
	JMP	MAIN




T1_IR:
	MOV	TL1,	#06Ch	; reset zegara
	MOV	TH1,	#0DFh
	
	DJNZ	R1,	KONIEC_T1;

	MOV	R1,	#100;		; reset licznika

	INC	R4
	CJNE R4, #10, OK
	
	MOV	R4,	#0
	INC	R5
	CJNE R5, #10, OK

	MOV	R5,	#0
	INC	R6
	CJNE R6, #10, OK

	MOV	R6, #0
	INC	R7
	CJNE R7, #10, OK

	MOV	R7, #0
	
OK:

KONIEC_T1:
	RETI



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
	MOV	A,	R4
	;MOV	A,	#2
	
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000001b	;włącz pierwszy
	JMP	KONIEC

AFTER_FIRST:
	CJNE R0, #01h, AFTER_SECOND
	MOV	A,	R5
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000010b	;włącz drugi
	JMP	KONIEC

AFTER_SECOND:
	CJNE R0, #02h, FOURTH
	MOV	A,	R6
	MOVC	A,	@A+DPTR
	MOV	P0, 	A	;liczba
	MOV	P1,	#00000100b	;włącz trzeci
	JMP	KONIEC
	
FOURTH:
	MOV	A,	R7
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


