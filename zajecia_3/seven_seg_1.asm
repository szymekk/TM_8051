;program wyświetlający dwie cyfry zero
;na miejscu cyfry jednostek i dziesiątek


org 00h
	JMP	INIT

org 30h
INIT:
			;Kgfedcba	- K to kropka
	MOV	P0,	#01000000b	;cyfra zero
	MOV	P1,	#00000011b	;wybór wyświetlaczy - pierwszy i drugi

MAIN:
	JMP	MAIN

end
