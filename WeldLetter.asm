@thumb
@org $8F9FC00

; Weldletter

; Begin
push {r0-r7}
mov r3,r8
mov r4,r9
mov r5,r10
mov r6,r11
mov r7,r12
push {r3-r7}


ldr r3,=#0x6000000
mov r8,r3          ; vramAddr r8
ldr r3,=#0x8AFED84
mov r9,r3          ; fontAddr r9
ldr r3,=#0x44444444
mov r12,r3         ; blankRow r12
ldr r7,=#0x8F90000
ldrb r7,[r7,r0]    ; letterWidth r7
lsl r0,r0,1
ldr r5,=#0x8B1B4B0
ldrh r0,[r5,r0]    ; letterTile r0
mov r3,0           ; t r3
                   ; tile r1
mov r10,r2         ; letterPos r10
                   ; free r2,r5,r6
                   
T_LOOP:

mov r4,0           ; y r4

Y_LOOP:

; tmpFont = LoadWord(fontAddr + (t << 10) + (letterTile << 5) + (y << 2));
lsl r5,r4,2
lsl r6,r0,5
add r5,r5,r6
lsl r6,r3,10
add r5,r9
ldr r5,[r5,r6] ; tmpFont r5
mov r11,r5     ; tmpFont r11

; tmpTile = LoadWord(vramAddr + (t << 10) + (tile << 5) + (y << 2));
lsl r2,r4,2
lsl r6,r1,5
add r2,r8
add r2,r2,r6
lsl r6,r3,10
ldr r2,[r2,r6] ; tmpTile r2

; tmpTile &= ((1 << (letterPos << 2)) - 1);
push {r5}
mov r6,1
mov r5,r10
lsl r5,r5,2
lsl r6,r5
sub r6,1
and r2,r6
pop {r5}

; tmpTile |= (tmpFont << (letterPos << 2));
mov r6,r10
lsl r6,r6,2
lsl r5,r6
orr r2,r5 ; tmpTile r2

; tmpTile |= (blankRow >> ((8 - (letterWidth + letterPos)) << 2));
; mov r5,r7
; add r5,r10
; mov r6,8
; sub r5,r6,r5
; lsl r5,r5,2
; mov r6,r12
; lsr r6,r5
; orr r2,r6

; StoreWord(vramAddr + (t << 10) + (tile << 5) + (y << 2), tmpTile);
lsl r5,r4,2
lsl r6,r1,5
add r5,r8
add r5,r5,r6
lsl r6,r3,10
str r2,[r5,r6]

; if (letterPos + letterWidth <= 8) goto skipRight
; mov r2,r10
; add r2,r2,r7
; cmp r2,8
; ble FINISHCHECK

; free r2,r5,r6
;				// Right
;				// Tiles to avoid: 4D, 53-5F, B4-BF, FD-FF
;				tile2 = tile - LoadHWord(0x30051EC);
;				if (tile2 == 0x8C) tile2 = 0x8E;
;				else if (tile2 == 0x92) tile2 = 0xC0;
;				else if (tile2 == 0x153) tile2 = 0x180;
;				else if (tile2 == 0x1DC) tile2 = 0;
;				else if ((tile2 % 32) == 31) tile2 += 0x21;
;				else tile2++;
;				tile2 += LoadHWord(0x30051EC);

; tile2 = tile - LoadHWord(0x30051EC);
push {r1}
ldr r2,=#0x30051EC
ldrh r2,[r2]
sub r1,r1,r2
		
	; if (tile2 == 0x8C) tile2 = 0x8E;
	mov r6,0x8C
	cmp r1,r6
	bne NEXT_IF1
	mov r1,0x8E
	b DONE_IF
	
	NEXT_IF1:
	; else if (tile2 == 0x92) tile2 = 0xC0;
	mov r6,0x92
	cmp r1,r6
	bne NEXT_IF2
	mov r1,0xC0
	b DONE_IF
	
	NEXT_IF2:
	; else if (tile2 == 0x153) tile2 = 0x180;
	add r6,0xC1
	cmp r1,r6
	bne NEXT_IF3
	mov r1,r6
	add r1,0x2D
	b DONE_IF
	
	NEXT_IF3:
	; else if (tile2 == 0x1DC) tile2 = 0;
	add r6,0x89
	cmp r1,r6
	bne NEXT_IF4
	mov r1,0
	b DONE_IF
	
	NEXT_IF4:
	; else if ((tile2 % 32) == 31) tile2 += 0x21;
	push {r0,r1,r3}
	mov r0,r1
	mov r1,32
	swi 6
	cmp r1,31
	pop {r0,r1,r3}
	bne NEXT_IF5
	add r1,0x21
	b DONE_IF
	
	NEXT_IF5:
	; else tile2++;
	add r1,1
	
; tile2 += LoadHWord(0x30051EC);
DONE_IF:
ldr r2,=#0x30051EC
ldrh r2,[r2]
add r1,r1,r2

; tmpTile = LoadWord(vramAddr + (t << 10) + (tile2 << 5) + (y << 2));
lsl r5,r4,2
lsl r6,r1,5
add r5,r5,r6
add r5,r8
lsl r6,r3,10
ldr r5,[r5,r6] ; tmpTile r5

; tmpTile &= ((0xFFFFFFFF >> (letterPos << 2)) << (letterPos << 2));
mov r6,0
sub r6,1
mov r2,r10
lsl r2,r2,2
lsr r6,r2
lsl r6,r2
and r5,r6

; tmpTile |= (tmpFont >> ((8 - letterPos) << 2));
; mov r2,r11     ; tmpFont r2
mov r6,r10     ; letterPos r6
mov r2,8
sub r6,r2,r6
lsl r6,r6,2
mov r2,r11
lsr r2,r6
orr r2,r5 ; tmpTile r2

; tmpTile |= (blankRow << (letterPos << 2));
mov r5,r10
lsl r5,r5,2
mov r6,r12
lsl r6,r5
orr r2,r6

; StoreWord(vramAddr + (t << 10) + (tile2 << 5) + (y << 2), tmpTile);
lsl r5,r4,2
lsl r6,r1,5
add r5,r5,r6
add r5,r8
lsl r6,r3,10
str r2,[r5,r6]

pop {r1}

; y++
add r4,1
cmp r4,8
blt Y_LOOP

; t++
add r3,1
cmp r3,2
blt T_LOOP

; End
pop {r3-r7}
mov r8,r3
mov r9,r4
mov r10,r5
mov r11,r6
mov r12,r7
pop {r0-r7}
bx r7