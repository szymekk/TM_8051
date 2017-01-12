; echo selektywne z przerwaniami i wyświetlaniem
; program odbiera przysłany znak
; jeśli odebrano cyfrę to odsyła ją spowrotem i wyświetla
; wyświetlanie na czterech wyświetlaczach siedmiosegmentowych


org 00h
	JMP	INIT
.org 0Bh			; obsluga przerwania od T0
	JMP	T0_IR
org 23h
	JMP	SERIAL_IRQ

.org 30h
INIT:

	; inicjalizacja wartości na wyświetlaczach liczbą 8654
	MOV R7, #8			; cyfra na 4 (tysiące)
	MOV R6, #6			; cyfra na 3 (setki)
	MOV R5, #5			; cyfra na 2 (dziesiątki)
	MOV R4, #4			; cyfra na 1 (jedności)

	MOV	DPTR, #LED_TABLE

	MOV	TMOD, #21h		; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
						; T0 w trybie 16-bitowy (dla wyświetlaczy)
	MOV SCON, #50h
	MOV PCON, #00h

	MOV	TL1,	#213	; 213, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#213	; przy normalnej ilości taktów na cykl (12) trzeba użyć wartości 234

	; przerwanie od zegara T0 sluzy do zmiany aktywnego wyswietlacza
	MOV	TL0,	#0xDB	; 0xF7DB = 63451, dla przerwań co 2,5 ms (400 Hz) -> całość 100 Hz
	MOV	TH0,	#0xF7	; przy 6 taktach na cykl daje to całość 200 Hz

	SETB	EA			; globalne zezwolenie na przerwania
	SETB	ES			; zezwolenie na przerwania od portu szeregowego
	SETB	ET0			; zezwolenie na przerwania od timera 0

	SETB	TR0			; uruchomienie T0
	SETB	TR1			; uruchomienie T1


MAIN:
	JMP	MAIN


SERIAL_IRQ:
	JNB RI, END_SERIAL
	; coś przyszło - RI ustawione
	MOV A, SBUF 		; odebranie
	CLR RI

	; w A jest to co przyszło
	CLR C;	
	CJNE A, #58, TUTAJ_1
	TUTAJ_1:

	JC JEST_MNIEJSZE_LUB_ROWNE_9
	JMP POZA_ZAKRESEM

JEST_MNIEJSZE_LUB_ROWNE_9:
	CLR C;
	CJNE A, #48, TUTAJ_2
	TUTAJ_2:

	JC POZA_ZAKRESEM

	; wyświetlanie
	PUSH ACC
	SUBB A, #48			; odejmij 48 - wartość znaku '0'
	MOV R7, A
	MOV R6, A
	MOV R5, A
	MOV R4, A
	POP ACC

	; odsyłanie
	; najpierw CLR!!!
	CLR TI
	MOV SBUF, A 		; odesłanie

POZA_ZAKRESEM:
END_SERIAL:
	RETI


T0_IR:
	MOV	TL0,	#0xDB	; reset zegara
	MOV	TH0,	#0xF7

CHOOSE_DISP:
	INC	R0;
	CJNE R0, #04h, CHANGE_DISP
	
	MOV	R0,	#0			; reset licznika cyfr

CHANGE_DISP:
	MOV	P1,	#00000000b	; wyłączenie wszystkich wyświetlaczy
						; żeby uniknąć poświaty

	CJNE R0, #00h, AFTER_FIRST
	MOV	A,	R4			; R4 przechowuje cyfrę jedności
	MOVC	A,	@A+DPTR	; dereferencja spod adresu R4 + LED_TABLE
	MOV	P0, 	A		; cyfra jedności (z R4)
	MOV	P1,	#00000001b	; włącz pierwszy wyświetlacz
	JMP	KONIEC

AFTER_FIRST:
	CJNE R0, #01h, AFTER_SECOND
	MOV	A,	R5
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra dzisiątek (z R5)
	MOV	P1,	#00000010b	; włącz drugi wyświetlacz
	JMP	KONIEC

AFTER_SECOND:
	CJNE R0, #02h, FOURTH
	MOV	A,	R6
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra setek (z R6)
	MOV	P1,	#00000100b	; włącz trzeci wyświetlacz
	JMP	KONIEC
	
FOURTH:
	MOV	A,	R7
	MOVC	A,	@A+DPTR
	MOV	P0, 	A		; cyfra tysięcy (z R7)
	MOV	P1,	#00001000b	; włącz czwarty wyświetlacz

KONIEC:
	RETI

; tablica przekodowań
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




