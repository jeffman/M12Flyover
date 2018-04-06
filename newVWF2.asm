@thumb
@org $8FA0000

push {r0}

ldrb r0,[r7] ; letter r0

push {r1-r7}
mov r1,r8
mov r2,r9
mov r3,r10
mov r4,r11
mov r5,r12
push {r1-r5}

ldr r1,=#0x203FFF0
mov r12,r1 ; ramAddr r12
ldr r2,[r1]
mov r11,r2 ; mapAddr r11
ldrh r3,[r1,8]
mov r10,r3 ; tile r10
ldrb r3,[r1,10]
mov r9,r3  ; letterPos r9

cmp r2,0
bne NOTFIRSTTIME

; First time loading
; First let's check if we need to clear the tiles
push {r0-r6}
ldr r6,=#0x6002000
ldrb r6,[r6]
cmp r6,0
beq NOCLEAR
; Let's call the clearing function
ldr r6,=NOCLEAR+1
b 0x8FA0400

NOCLEAR:
pop {r0-r6}

mov r11,r8
ldr r2,=#0x30051EC
ldrh r2,[r2]
mov r10,r2
mov r2,0
mov r9,r2

; Loading some tiles
push {r0-r3}
mov r4,1
lsl r4,r4,8

; 1
ldr r0,=#0x8B02D64
mov r1,r10
add r1,0xFF
add r1,r1,r4
lsl r1,r1,5
mov r2,6
lsl r2,r2,0x18
add r1,r1,r2
mov r2,8
swi 0xC

; 2
ldr r0,=#0x8B00404
mov r1,r10
add r1,0xB4
lsl r1,r1,5
mov r2,6
lsl r2,r2,0x18
add r1,r1,r2
mov r2,32
swi 0xC

; 3
ldr r0,=#0x8B02D84
mov r1,r10
add r1,0x80
add r1,0x80
add r1,r1,r4
lsl r1,r1,5
mov r2,6
lsl r2,r2,0x18
add r1,r1,r2
mov r2,1
lsl r2,r2,9
swi 0xC

; 4
ldr r0,=#0x8B03D84
mov r1,r10
add r1,0xC0
add r1,0xC0
add r1,r1,r4
lsl r1,r1,5
mov r2,6
lsl r2,r2,0x18
add r1,r1,r2
mov r2,1
lsl r2,r2,9
swi 0xC

pop {r0-r3}
b SKIPCHECK

NOTFIRSTTIME:

; StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) - 1);
ldr r2,[sp,0x24]
ldrh r3,[r2,0x2A]
sub r3,1
strh r3,[r2,0x2A]

; free r1-r7

; 	if (
;		!(((r8 - LoadWord(ramAddr + 4)) == 2) || 
;		((r8 - LoadWord(ramAddr + 4)) == 0)) &&
;		(letterPos > 0))
		
ldr r2,[sp,0x24]
ldr r2,[r2,4]
ldr r3,[r1,12]
cmp r2,r3
bne DO_NEW

ldr r2,[r1,4]
mov r3,r8
sub r3,r3,r2

cmp r3,2
beq SKIPCHECK
cmp r3,0
beq SKIPCHECK
mov r3,r9
cmp r3,0
beq SKIPCHECK

DO_NEW:
mov r3,0
mov r9,r3
mov r4,r0

; mov r0,r10
; mov r1,32
; swi 6
; cmp r1,31
; bne MOD1
; mov r0,0x21
; add r10,r0
; b DONEMOD1
; MOD1:
; mov r0,1
; add r10,r0
; DONEMOD1:

; tile -= LoadHWord(0x30051EC);
ldr r2,=#0x30051EC
ldrh r2,[r2]
mov r1,r10
sub r1,r1,r2
		
	; if (tile == 0x8C) tile = 0x8E;
	mov r6,0x8C
	cmp r1,r6
	bne NEXT_IF1
	mov r1,0x8E
	b DONE_IF
	
	NEXT_IF1:
	; else if (tile == 0x92) tile = 0xC0;
	mov r6,0x92
	cmp r1,r6
	bne NEXT_IF2
	mov r1,0xC0
	b DONE_IF
	
	NEXT_IF2:
	; else if (tile == 0x153) tile = 0x180;
	add r6,0xC1
	cmp r1,r6
	bne NEXT_IF3
	mov r1,r6
	add r1,0x2D
	b DONE_IF
	
	NEXT_IF3:
	; else if (tile == 0x1DC) tile = 0;
	add r6,0x89
	cmp r1,r6
	bne NEXT_IF4
	mov r1,0
	b DONE_IF
	
	NEXT_IF4:
	; else if ((tile % 32) == 31) tile += 0x21;
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
	; else tile++;
	add r1,1
	
; tile += LoadHWord(0x30051EC);
DONE_IF:
ldr r2,=#0x30051EC
ldrh r2,[r2]
add r1,r1,r2
mov r10,r1

mov r0,r4
mov r11,r8

; StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) + 1);
ldr r1,[sp,0x24]
ldrh r2,[r1,0x2A]
add r2,1
strh r2,[r1,0x2A]

SKIPCHECK:
; free r1-r7

mov r1,r10
mov r2,r9
ldr r7,=WELDRETURN
add r7,1
b #0x8F9FC00
WELDRETURN:

; free r1-r7
; r1 is already tile
ldr r2,=#0x3005228
ldrh r2,[r2]
orr r1,r2
mov r2,r11
strh r1,[r2]
add r1,0x20
add r2,0x40
strh r1,[r2]

mov r1,r9
ldr r2,=#0x8F90000
ldrb r2,[r2,r0]
add r1,r1,r2
mov r9,r1
cmp r1,7
ble STILLGOOD
sub r1,8
mov r9,r1

; mov r0,r10
; mov r1,32
; swi 6
; cmp r1,31
; bne MOD2
; mov r0,0x21
; add r10,r0
; b DONEMOD2
; MOD2:
; mov r0,1
; add r10,r0
; DONEMOD2:

; tile -= LoadHWord(0x30051EC);
ldr r2,=#0x30051EC
ldrh r2,[r2]
mov r1,r10
sub r1,r1,r2
		
	; if (tile == 0x8C) tile = 0x8E;
	mov r6,0x8C
	cmp r1,r6
	bne NEXT_IF1b
	mov r1,0x8E
	b DONE_IFb
	
	NEXT_IF1b:
	; else if (tile == 0x92) tile = 0xC0;
	mov r6,0x92
	cmp r1,r6
	bne NEXT_IF2b
	mov r1,0xC0
	b DONE_IFb
	
	NEXT_IF2b:
	; else if (tile == 0x153) tile = 0x180;
	add r6,0xC1
	cmp r1,r6
	bne NEXT_IF3b
	mov r1,r6
	add r1,0x2D
	b DONE_IFb
	
	NEXT_IF3b:
	; else if (tile == 0x1DC) tile = 0;
	add r6,0x89
	cmp r1,r6
	bne NEXT_IF4b
	mov r1,0
	b DONE_IFb
	
	NEXT_IF4b:
	; else if ((tile % 32) == 31) tile += 0x21;
	push {r0,r1,r3}
	mov r0,r1
	mov r1,32
	swi 6
	cmp r1,31
	pop {r0,r1,r3}
	bne NEXT_IF5b
	add r1,0x21
	b DONE_IFb
	
	NEXT_IF5b:
	; else tile++;
	add r1,1
	
; tile += LoadHWord(0x30051EC);
DONE_IFb:
ldr r2,=#0x30051EC
ldrh r2,[r2]
add r1,r1,r2
mov r10,r1

mov r0,r9
cmp r0,0
bne NOTSOGOOD

ldr r0,[sp,0x2C]
ldrb r1,[r0,2]
ldrb r0,[r0,1]
cmp r1,0xFF
bne NOTSOGOOD
cmp r0,0
beq STILLGOOD

NOTSOGOOD:
mov r0,2
add r11,r0
mov r0,r11
mov r1,r10
ldr r2,=#0x3005228
ldrh r2,[r2]
orr r1,r2
strh r1,[r0]
add r1,0x20
add r0,0x40
strh r1,[r0]

; StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) + 1);
ldr r0,[sp,0x24]
ldrh r1,[r0,0x2A]
add r1,1
strh r1,[r0,0x2A]

STILLGOOD:

mov r0,r12
mov r1,r11
str r1,[r0]
mov r1,r8
str r1,[r0,4]
mov r1,r10
strh r1,[r0,8]
mov r1,r9
strb r1,[r0,10]

ldr r1,[sp,0x24]
ldr r1,[r1,4]
str r1,[r0,12]

pop {r1-r5}
mov r8,r1
mov r9,r2
mov r10,r3
mov r11,r4
mov r12,r5
pop {r1-r7}
pop {pc}