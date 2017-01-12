; echo selektywne z przerwaniami
; odsyła tylko cyfry


org 00h
	JMP	INIT
org 23h
	JMP	SERIAL_IRQ

.org 30h
INIT:
						
	MOV	TMOD,	#20h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV SCON, #50h
	MOV PCON, #00h

	MOV	TL1,	#212	; 212, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#212

	SETB	EA		; globalne zezwolenie na przerwania

	SETB	ES		; zezwolenie na przerwania od portu szeregowego

	SETB	TR1		; uruchomienie T1

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


.end



