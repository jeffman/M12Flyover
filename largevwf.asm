@thumb
@org $8FA0800

; Objective: load r1 with the letter, load r2 with the width, call 80B3280
push {r4}
mov r0,r2
ldrb r1,[r4]
ldr r2,=#0x8F90100
ldrb r2,[r2,r1]
ldr r4,=RETADDR+1
mov r14,r4
ldr r4,=#0x80B3281
bx r4
RETADDR:

; Old code:
; mov r0,r2
; ldrb r1,[r4]
; add r4,1
; mov r2,12
; bl 80B3280

; Return to 80B348F
pop {r4}
add r4,1
ldr r0,=#0x80B348F
bx r0