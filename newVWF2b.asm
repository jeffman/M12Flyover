@thumb
@org $8FA0800

; Return to 80BF115
; Increment read address by 1 somewhere
; r3 = read address, swap with r7
; r6 = map address, swap with r8
; r7 = ram thing address, swap with r5
; Use r0 for the shit return register
; Make sure r3 is good for return

push {r1,r3,r5,r7}
mov r5,r7
mov r7,r3
mov r0,r8
push {r0}
mov r8,r6

ldr r0,=RETADDR+1
ldr r1,=#0x8FA0001
bx r1

RETADDR:
pop {r0}
mov r8,r0
pop {r1,r3,r5,r7}
add r3,1
ldr r0,=#0x80BF115
bx r0