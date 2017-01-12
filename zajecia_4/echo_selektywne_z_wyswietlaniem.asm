; echo selektywne z przerwaniami i wyświetlaniem
; odsyła tylko cyfry


org 00h
	JMP	INIT
.org 0Bh			; obsluga przerwania od T0
	JMP	T0_IR
org 23h
	JMP	SERIAL_IRQ

.org 30h
INIT:

	; inicjalizacja warto\u0139ci poczÄtkowej liczbÄ 8654
	MOV R7, #8		; cyfra na 4 (tysiÄcie)
	MOV R6, #6		; cyfra na 3 (setki)
	MOV R5, #5		; cyfra na 2 (dziesiÄtki)
	MOV R4, #4		; cyfra na 1 (jedno\u0139ci)


	MOV	DPTR, #LED_TABLE

						
	;MOV	TMOD,	#20h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV	TMOD,	#21h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
				; T0 w tryb 16-bit
	MOV SCON, #50h
	MOV PCON, #00h

	MOV	TL1,	#212	; 212, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#212

	; przerwania od zegara T0 sluzy do zmiany aktywnego wyswietlacza
	MOV	TL0,	#0xDB	; 0xF7DB = 63451, dla przerwa\u0139 co 2,5 ms (400 Hz) -> ca\u0139o\u0139Ä 100 Hz
	MOV	TH0,	#0xF7

	SETB	EA		; globalne zezwolenie na przerwania

	SETB	ES		; zezwolenie na przerwania od portu szeregowego

	SETB	TR1		; uruchomienie T1

	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

	MOV SBUF, #48



MAIN:
	JMP	MAIN




SERIAL_IRQ:
	JNB RI, NIE_PRZYSZLO
	; coś przyszło - RI ustawione
	MOV A, SBUF ;odbieramy
	CLR RI

; w A jest to co przyszło
	CLR C;
	;SUBB A, #48 ; jeśli przyszla cyfra to w A będzie jej wartość
	
	CJNE A, #58, TUTAJ_1
	TUTAJ_1:

	JC JEST_MNIEJSZE_LUB_ROWNE_9
	JMP POZA_ZAKRESEM

JEST_MNIEJSZE_LUB_ROWNE_9:
	CLR C;
	CJNE A, #48, TUTAJ_2
	TUTAJ_2:

	JC POZA_ZAKRESEM

ODSYLANIE:

	PUSH ACC
	SUBB A, #48
	MOV R7, A
	MOV R6, A
	MOV R5, A
	MOV R4, A
	POP ACC
	;najpierw CLR!!!
	CLR TI
	MOV SBUF, A ;odsyłamy
	JMP END_SERIAL

NIE_PRZYSZLO:
	;sprawdzenie czy wysłano
	JNB TI, NIC
	;wysłano

END_SERIAL:
	RETI
POZA_ZAKRESEM:
	RETI


NIC:
	RETI








T0_IR:
	MOV	TL0,	#0xDB	; reset zegara
	MOV	TH0,	#0xF7

CHOOSE_DISP:
	INC	R0;
	CJNE R0, #04h, CHANGE_DISP
	
	MOV	R0,	#0			; reset licznika cyfr

CHANGE_DISP:
	MOV	P1,	#00000000b	; wy\u0139Äczenie wszystkich wy\u0139wietlaczy
						; \u0139\u017aeby uniknÄÄ po\u0139wiaty


	CJNE R0, #00h, AFTER_FIRST
	MOV	A,	R4			; R4 przechowuje cyfrÄ jedno\u0139ci
	MOVC	A,	@A+DPTR	; dereferencja spod adresu R4 + LED_TABLE
	MOV	P0, 	A		; cyfra jedno\u0139ci (z R4)
	MOV	P1,	#00000001b	; w\u0139Äcz pierwszy wy\u0139wietlacz
	JMP	KONIEC

AFTER_FIRST:
	CJNE R0, #01h, AFTER_SECOND
	MOV	A,	R5
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra dziesÄtek (z R5)
	MOV	P1,	#00000010b	; w\u0139Äcz drugi wy\u0139wietlacz
	JMP	KONIEC

AFTER_SECOND:
	CJNE R0, #02h, FOURTH
	MOV	A,	R6
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra setek (z R6)
	MOV	P1,	#00000100b	; w\u0139Äcz trzeci wy\u0139wietlacz
	JMP	KONIEC
	
FOURTH:
	MOV	A,	R7
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra tysiÄcy (z R7)
	MOV	P1,	#00001000b	; w\u0139Äcz czwarty wy\u0139wietlacz

KONIEC:
	RETI

; tablica przekodowa\u0139
LED_TABLE:
 ; Kgfedcba	- K to kropka
DB 11000000b; 0
DB 11111001b; 1
DB 10100100b; 2
DB 10110000b; 3
DB 10011001b; 4
DB 10010010b; 5
DB 10000010b; 6
DB 11111000b; 7
DB 10000000b; 8
DB 10010000b; 9


.end




