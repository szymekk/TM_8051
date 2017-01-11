; program realizujący licznik
; wartość aktualna wyświetlana jest na czterech wyświetlaczach
; co sekundę wartość wyświetlana jest zwiększana o jeden
; używa tablicy przekodowań (etykieta LED_TABLE)


org 00h
	JMP	INIT


.org 0Bh			; obsługa przerwania od T0
	JMP	T0_IR

.org 1Bh			; obsługa przerwania od T1
	JMP	T1_IR

.org 30h
INIT:
	; P1 służy do wyboru wyświetlacza
	; P0 służy do wyboru segmentów wyświetlacza
	; Kgfedcba	- K to kropka
	
	; przykładowo:
			   ; Kgfedcba	- K to kropka
	; MOV	P0, #01000000b	; cyfra zero z kropką
	; MOV	P1,	#00001001b	; wybór wyswietlaczy pierwszego i czwartego

	; DPTR wskazuje na tablicę przekodowań
	MOV	DPTR, #LED_TABLE

	MOV R0, #0;		; inicjalizacja licznik wyboru zegara
	
	
	; przerwania od zegara T0 służa do zmiany aktywnego wyświetlacza

	; inicjalizacja wartości początkowej liczbą 8654
	MOV R7, #8		; cyfra na 4 (tysiącie)
	MOV R6, #6		; cyfra na 3 (setki)
	MOV R5, #5		; cyfra na 2 (dziesiątki)
	MOV R4, #4		; cyfra na 1 (jedności)
	
	
	MOV R1, #100		; inicjalizacja licznika przerwań
						; odmierzającego jedną sekundę
						; co sekundę zwiększa się wartość do wyświetlenia na liczniku

						
	MOV	TMOD,	#0x11	; tryb 16-bitowy dla obu zegarów

	; przerwania od zegara T0 służa do zmiany aktywnego wyświetlacza
	MOV	TL0,	#0xDB	; 0xF7DB = 63451, dla przerwań co 2,5 ms (400 Hz) -> całość 100 Hz
	MOV	TH0,	#0xF7

	; przerwania od zegara T1 służa do zmiany wartości licznika
	MOV	TL1,	#0x6C	; 0xDF6C = 64702, dla przerwań co 10 ms (100 Hz)
	MOV	TH1,	#0xDF

	SETB	EA		; globalne zezwolenie na przerwania
	
	SETB	ET1		; zezwolenie na przerwania od timera 1
	SETB	TR1		; uruchomienie T1

	SETB	ET0		; zezwolenie na przerwania od timera 0
	SETB	TR0		; uruchomienie T0

	
MAIN:
	JMP	MAIN


T1_IR:
	MOV	TL1,	#06Ch	; reset zegara
	MOV	TH1,	#0DFh
	
	DJNZ	R1,	KONIEC_T1;

	MOV	R1,	#100;		; reset licznika przerwać

	; zwiększenie wartości na liczniku
	
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
	MOV	P0, 	A		; cyfra dziesątek (z R5)
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
DB 10000010b; 9

.end
