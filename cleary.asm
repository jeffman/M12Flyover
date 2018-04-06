@thumb
@org $8FA1000

mov r0,2
lsl r0,r0,8
add r0,3
lsl r0,r0,8
add r0,0xFF
lsl r0,r0,8
add r0,0xF0
mov r3,0
str r3,[r0]
strh r3,[r0,4]
strb r3,[r0,6]

; Branch back to 80CAA97
mov r0,8
lsl r0,r0,8
add r0,0xC
lsl r0,r0,8
add r0,0xAA
lsl r0,r0,8
add r0,0x97
pop {r3-r5}
push {r0}
push {r3-r5}

; Old code
mov r0,0x2
neg r0,r0
mov r3,r10
and r0,r3
str r0,[r6]
pop {r3-r5}
mov r8,r3
pop {pc}