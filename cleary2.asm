@thumb
@org $8FA0400

; Entry at 80B87B6
; Return to 80B87C1
; Overwritten code:
; ldr r0,[r4]
; mov r5,0x80
; lsl r5,r5,3
; orr r0,r5
; str r0,[r4]
; ldr r0,[r6,8]

; Objective: clear out the bytes at 203FFF0, clear out the text tiles in VRAM
push {r0-r5}
ldr r0,=#0x203FFF0
mov r1,0
str r1,[r0]
str r1,[r0,4]
strh r1,[r0,8]
strb r1,[r0,10]
str r1,[r0,12]

; Clear first block of tiles (we can't overwrite the window border tiles

; Tiles 0 to 92
ldr r0,=#0x6000000
ldr r1,=#0x30051EC
mov r4,r0
mov r5,r1
ldrh r1,[r1]
lsl r1,r1,5
add r1,r0,r1
mov r0,0
push {r0}
mov r0,sp
ldr r2,=#0x1000498
swi 0xC

; Second block: tiles 9B to B2
mov r1,r5
ldrh r1,[r1]
add r1,0x9B
lsl r1,r1,5
add r1,r4,r1
mov r0,sp
ldr r2,=#0x10000C0
swi 0xC

; Third block: tiles BB to 153
mov r1,r5
ldrh r1,[r1]
add r1,0xBB
lsl r1,r1,5
add r1,r4,r1
mov r0,sp
ldr r2,=#0x10004C8
swi 0xC

; Fourth block: tiles 15D to 173
mov r1,r5
ldrh r1,[r1]
add r1,0xAE
add r1,0xAF
lsl r1,r1,5
add r1,r4,r1
mov r0,sp
ldr r2,=#0x10000B8
swi 0xC

; Fifth block: 17D to 1DC
mov r1,r5
ldrh r1,[r1]
add r1,0xBE
add r1,0xBF
lsl r1,r1,5
add r1,r4,r1
mov r0,sp
ldr r2,=#0x1000300
swi 0xC

; Sixth block: 1E0 to 1EC
mov r1,r5
ldrh r1,[r1]
add r1,0xF0
add r1,0xF0
lsl r1,r1,5
add r1,r4,r1
mov r0,sp
ldr r2,=#0x1000068
swi 0xC

; End
add sp,4
pop {r0-r5}

add r2,r1,r3
strh r0,[r2]
mov r2,0xC9
lsl r2,r2,1
add r0,r1,r2
ldrh r0,[r0]
add r3,8
add r1,r1,r3

bx r6