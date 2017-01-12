; program wysyłający ten sam znak przez port szeregowy


org 00h
	JMP	INIT

.org 30h
INIT:

	MOV	TMOD, #20h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV SCON, #50h
	MOV PCON, #00h

	; 256 - (10 000 000/(12*32*1200)) = 234
	; 256 - (10 000 000/(6*32*1200)) = 213
	MOV	TL1,	#213	; 213, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#213	; przy normalnej ilości taktów na cykl (12) trzeba użyć wartości 234

	SETB	TR1			; uruchomienie T1 - taktuje on transmisję przez port szeregowy


MAIN:
	JNB	TI,	MAIN		; jeszcze nie wysłano, czekaj
	; najpierw CLR!!!
	CLR TI
	MOV SBUF, #48		; wysłanie znaku '0'


.end
