;program realizujący wyświetlanie liczby 4321

org 00h
	JMP	INIT

org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

org 30h
INIT:
	;P1 służy do wyboru wyświetlacza
	;P0 służy do wyboru segmentów wyświetlacza
	;Kgfedcba	- K to kropka
	
	;przykładowo:
				;Kgfedcba	- K to kropka
	;MOV	P0,	#01000000b	;cyfra zero z kropką
	;MOV	P1,	#00001001b	;wybór wyświetlaczy pierwszego i czwartego


	MOV R0, #0;		; inicjalizacja licznik wyboru wyświetlacza
	
	;przerwania od zegara T0 służą do zmiany aktywnego wyświetlacza
	MOV	TMOD,	#0x01	; tryb 16-bitowy T0
	MOV	TL0,	#0xDB	; 0xF7DB = 63451, dla przerwań co 2,5 ms (400 Hz) -> całość 100 Hz
	MOV	TH0,	#0xF7

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
	CJNE R0,#04h, CHANGE_DISP
	
	MOV	R0,	#0	; reset licznika

CHANGE_DISP:
	MOV	P1,	#00000000b	;wyłączenie wszystkich wyświetlaczy
						;żeby uniknąć poświaty

	CJNE R0,#00h, AFTER_FIRST
	MOV	P0,	#11111001b	;cyfra jeden
	MOV	P1,	#00000001b	;włącz pierwszy wyświetlacz
	JMP	KONIEC

AFTER_FIRST:	;wyświetlacz drugi lub trzeci lub czwarty

	CJNE R0,#01h, AFTER_SECOND
	MOV	P0,	#10100100b	;cyfra dwa
	MOV	P1,	#00000010b	;włącz drugi wyświetlacz
	JMP	KONIEC

AFTER_SECOND:	;wyświetlacz trzeci lub czwarty

	CJNE R0,#02h, FOURTH
	MOV	P0,	#10110000b	;cyfra trzy
	MOV	P1,	#00000100b	;włącz trzeci wyświetlacz
	JMP	KONIEC
	
FOURTH:			;wyświetlacz czwarty

	MOV	P0,	#10011001b	;cyfra cztery
	MOV	P1,	#00001000b	;włącz czwarty wyświetlacz

KONIEC:
	RETI

end
