; program wysyłający ten sam znak przez port szeregowy


org 00h
	JMP	INIT

.org 30h
INIT:
						
	MOV	TMOD,	#20h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV SCON, #50h
	MOV PCON, #00h

	;MOV	TL1,	#234	; 0xEA = 234, dla 1200 baud przy 10 MHz i 12 taktów na cykl
	;MOV	TH1,	#234

	MOV	TL1,	#212	; 212, dla 1200 baud przy 10 MHz i 6 taktów na cykl
	MOV	TH1,	#212

	SETB	TR1		; uruchomienie T1

	MOV SBUF, #48


MAIN:
	JNB	TI,	CZEKAJ	; jeszcze nie wysłano, czekaj
	;najpierw CLR!!!
	CLR TI
	MOV SBUF, #48		;znak 0
	

CZEKAJ:
	JMP	MAIN


.end

