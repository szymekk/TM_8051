; echo z przerwaniami
; program odbiera przysłany znak, po czym odsyła go spowrotem


org 00h
	JMP	INIT
org 23h
	JMP	SERIAL_IRQ

.org 30h
INIT:

	MOV	TMOD, #20h		; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV SCON, #50h
	MOV PCON, #00h

	; 256 - (10 000 000/(12*32*1200)) = 234
	; 256 - (10 000 000/(6*32*1200)) = 213
	MOV	TL1,	#213	; 213, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#213	; przy normalnej ilości taktów na cykl (12) trzeba użyć wartości 234

	SETB	EA			; globalne zezwolenie na przerwania
	SETB	ES			; zezwolenie na przerwania od portu szeregowego

	SETB	TR1			; uruchomienie T1 - taktuje on transmisję przez port szeregowy


MAIN:
	JMP	MAIN


SERIAL_IRQ:
	JNB RI, END_SERIAL
	; coś przyszło - RI ustawione
	MOV A, SBUF			; odebranie
	CLR RI

	; najpierw CLR!!!
	CLR TI
	MOV SBUF, A			; odesłanie

END_SERIAL:
	RETI

	
.end
