	org 0

	;LJMP start
start:
	MOV	P0, #0xFE ; 11111110b ; wszystkie świecą
	ACALL	delay
	MOV	P0, #0xFF ; 11111111b ; wszystkie świecą
	ACALL	delay
	LJMP start

; liczba cykli: 1 + 200*(1 + 200*2 + 2) = 80601
; czas opóźnienia 80601 * 12 * 0,05 us = 48360,6 u
; okres = 2 * czas opóźnienia = 96721. us = 96,7212 ms
;delay:
;	MOV	R1, #200
;loop2:	MOV	R0, #200
;	
;loop1:	DJNZ	R0, loop1
;
;	DJNZ	R1, loop2
;	
;	RET


; liczba cykli: 1 + 10*(1 + 200*(1 + 207*2 + 2)) + 2 = 834013
; czas opóźnienia 834013 * 12 * 0,05 us = 500407,8 us = 500,4078 ms
; okres = 2 * czas opóźnienia = 1000,8156 ms = 1,0008156 s
delay:
	MOV	R2, #10
loop3:	MOV	R1, #200
loop2:	MOV	R0, #207
	
loop1:	DJNZ	R0, loop1

	DJNZ	R1, loop2
	
	DJNZ	R2, loop3
	
	RET

end
