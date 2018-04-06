@thumb
@org $80FD000
; @org $8FA0C00

; Entry at 80B324E
; Return to 80B3259
; Overwritten code:
; add r0,r10
; add r2,r2,r0
; add r1,r1,r2
; add r1,r1,r3
; ldrb r0,[r1]
; strb r0,[r4]

; Time to do some shuffling. This will get lr back with it's original value 
push {r5,LR}          ; We're going to use r5, so we need to keep it in 
                      ; r13 is the SP, r14 is LR 
ldr r5,[sp,#0x08]     ; Load r5 with our former LR value? 
mov r14,r5            ; Move the former LR value back into LR 
ldr r5,[SP,#0x04]     ; Grab the LR value for THIS function 
str r5,[SP,#0x08]     ; Store it over the previous one 
pop {r5}              ; Get back r5 
add SP,#0x04          ; Get the un-needed value off the stack 

; Objective: check if the pixel position&1==1, if so, weld the data
add r1,r1,r3
ldrb r0,[r1]
; r1 = font load address
; r4 = font write address
push {r5,r6,r7}
ldr r5,=#0x30051D4
ldr r5,[r5]
mov r6,0x90
lsl r6,r6,6
add r5,r5,r6
ldrh r5,[r5]
mov r6,1
and r5,r6
cmp r5,1
bne EVEN_POS

ldrb r5,[r4]
mov r6,0xF
and r5,r6
lsl r6,r0,4
orr r5,r6
mov r6,0xFF
and r5,r6
strb r5,[r4]

mov r7,r4
mov r6,3
and r7,r6
cmp r7,3
bne OLD_ADDR
mov r7,r4
add r7,0x1C
b OK_ADDR

OLD_ADDR:
mov r7,r4

OK_ADDR:
ldrb r5,[r7,1]
mov r6,0xF0
and r5,r6
lsr r6,r0,4
orr r5,r6
strb r5,[r7,1]
b END

EVEN_POS:
strb r0,[r4]

END:
pop {r5,r6,r7}
pop {r15}