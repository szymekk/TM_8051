; echo selektywne z przerwaniami
; program odbiera przysłany znak
; jeśli odebrano cyfrę to odsyła ją z powrotem


org 00h
	JMP	INIT
org 23h
	JMP	SERIAL_IRQ

org 30h
INIT:

	MOV	TMOD,	#20h	; tryb 8-bitowy z autoprzeładowaniem dla zegara T1 (dla portu szeregowego)
	MOV	SCON,	#50h
	MOV	PCON,	#00h

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
	JNB	RI,	END_SERIAL
	; coś przyszło - RI ustawione
	MOV	A,	SBUF 		; odebranie
	CLR	RI

	; w A jest to co przyszło
	CLR	C
	CJNE	A,	#58,	TUTAJ_1
	TUTAJ_1:

	JC JEST_MNIEJSZE_LUB_ROWNE_9
	JMP POZA_ZAKRESEM

JEST_MNIEJSZE_LUB_ROWNE_9:
	CLR	C
	CJNE	A,	#48,	TUTAJ_2
	TUTAJ_2:

	JC	POZA_ZAKRESEM

	; odsyłanie
	; najpierw CLR!!!
	CLR	TI
	MOV	SBUF,	A		; odesłanie

POZA_ZAKRESEM:
END_SERIAL:
	RETI


end
