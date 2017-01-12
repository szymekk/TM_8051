; echo z przerwaniami


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


NIC:
	RETI


.end


