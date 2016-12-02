org 0

LJMP start

org 100h
start:
mov P0, #0x00 ; 00000000b ; wszystkie swieca
;mov P1, #0x55 ; b01010101
mov P1, 01010111b
mov P2, #0xF0 ; b11110000
mov P3, #01111110b ; b11000011

loop:
LJMP loop

end
