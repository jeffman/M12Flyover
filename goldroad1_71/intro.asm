;; ---------------------------------------------------------------------------------
;;
;;	text effect intro
;;	by rob ware
;;	with goldroad ARM 1.7
@arm
@fsize	32

@equ	oam_table	=	0x03000000


;;@textarea	0x08000000 + (256*1024)


;;-------------------------------------------------------------
;;	program entry point
	
	b	agb_main

@dup	dcb 0xba,0x0

agb_main:

;	load gfx

	addr	r0,intro_pal
	ldr	r1,=#0x05000200
	mov	r2,512
	bl	dma_copy_32

	addr	r0,intro_sprite_data_start
	ldr	r1,=#0x06010000
	ldr	r2,=intro_sprite_data_end-intro_sprite_data_start
	bl	dma_copy_32

;	clear oam
	bl	clear_oam
	bl	wait_vbl
	bl	copy_oam

; 	enable display

	mov	r0,0x04000000
	ldr	r1,=#(1<<12)|(1<<6)		
	strh 	r1,[r0]

;	intro

	mov	r2,#0x0
	addr	r3,intro_sprite_pattern

	addr	r0,oam_table

	;; fill the first rotation matrix (normal size)
	mov	r4,#0x100
	mov	r5,#0x0
	strh	r4,[r0,#6]
	strh	r4,[r0,#30]
	strh	r5,[r0,#14]
	strh	r5,[r0,#22]		

.intro_loop:

	;; make offset to current sprite

	addr	r0,oam_table
	add	r0,r0,r2 lsl #3

	;; sprite attribute #0	(256 col,rotation,double size, ypos)	

	mov	r1,#8
	add	r1,r1,r2,lsl #4
	ldr	r1,[r3,r1]
	orr	r1,r1,#(0x3000|0x100|0x200)	
	strh	r1,[r0,#0]

	;; sprite attribute #1	(size,rotation matrix,xpos)	

	mov	r1,#4
	add	r1,r1,r2,lsl #4
	ldr	r1,[r3,r1]
	orr	r1,r1,0x4000

	;; set to rotation matrix #1

	orr	r1,r1,1<<9
	strh	r1,[r0,#2]

	;; sprite attribute #3 (chracter num)

	ldr	r1,[r3,r2,lsl #4]
	strh	r1,[r0,#4]
	
	; manipulate matrix #1

	addr	r7,oam_table
	add	r7,r7,32
	mov	r4,10
	mov	r5,0x7E
	mov	r6,0

.inner_loop
	
	strh	r5,[r7,#6]
	strh	r5,[r7,#30]
	strh	r6,[r7,#14]
	strh	r6,[r7,#22]		

	bl	wait_vbl
	bl	copy_oam

	add	r5,r5,0xd	
	subs	r4,r4,#1
	bne	inner_loop

	;; return sprite to maxtrix #0

	ldrh	r1,[r0,#2]
	eor	r1,r1,(1<<9)
	strh	r1,[r0,#2]

	;; loop for all the letters

	add	r2,r2,#1
	cmp	r2,#8
	bne	intro_loop

	mov	r2,#0x0

.mosaic_loop1

	mov	r0,0x04000000
	orr	r1,r2,r2,lsl #4
	mov	r1,r1,lsl #8
	strh	r1,[r0,#0x4c]

	bl	wait_vbl
	bl	wait_vbl

	add	r2,r2,#1
	cmp	r2,#7	
	bne	mosaic_loop1

.mosaic_loop2

	mov	r0,0x04000000
	orr	r1,r2,r2,lsl #4
	mov	r1,r1,lsl #8
	strh	r1,[r0,#0x4c]

	bl	wait_vbl
	bl	wait_vbl

	subs	r2,r2,#1
	bpl	mosaic_loop2

	
	mov	r2,120
.pause
	bl	wait_vbl
	subs	r2,r2,#1	
	bne	pause

	b	agb_main

;	b	0x080000C0

intro_sprite_pattern:
/*
	@DCD	0,	30,	65,	0	;	f
	@DCD	8,	50,	65,	0	;	o
	@DCD	8,	70,	65,	0	;	o
	@DCD	16,	90,	65,	0	;	l
	@DCD	24,	110,	65,	0	;	s
	@DCD	32,	130,	65,	0	;	g
	@DCD	8,	150,	65,	0	;	o
	@DCD	16,	170,	65,	0	;	l
	@DCD	40,	190,	65,	0	;	d
*/
	@DCD	32,	35,	65,	0	;	g
	@DCD	8,	55,	65,	0	;	o
	@DCD	16,	75,	65,	0	;	l
	@DCD	40,	95,	65,	0	;	d
	@DCD	48,	115,	65,	0	;	r
	@DCD	8,	135,	65,	0	;	o
	@DCD	56,	155,	65,	0	;	a
	@DCD	40,	175,	65,	0	;	d



;; ------------------------------------------------------------
;;   wait vbl	(busy loop version)
;;
wait_vbl:
	
	stmfd	r13!,{r0,r1}
	mov	r0,#0x04000000
.wait1
	ldrh	r1,[r0,#0x4]
	tst	r1,#0x1
	bne	wait1
.wait2
	ldrh	r1,[r0,#0x4]
	tst	r1,#0x1
	beq	wait2
	
	ldmfd	r13!,{r0,r1}
	bx	lr


;;------------------------------------------------------------
;;     copy oam
;;
copy_oam:

	stmfd	r13!,{r0-r2,lr}

	addr	r0,oam_table
	mov	r1,#0x07000000
	ldr	r2,=(128*8)
	bl	dma_copy_32

	ldmfd	r13!,{r0-r2,lr}
	bx	lr

;; ------------------------------------------------------------
;; clear oam
;;
clear_oam:

	stmfd	r13!,{r0-r2,lr}

	addr	r0,oam_table
	mov	r1,128
	mov	r2,#160
	mov	r3,#240
	mov	r4,#0
.clear
	strh	r2,[r0],#2
	strh	r3,[r0],#2
	strh	r4,[r0],#2
	strh	r4,[r0],#2

	subs	r1,r1,#1
	bne	clear

	ldmfd	r13!,{r0-r2,lr}
	bx	lr


;; -----------------------------------------------------------
;;	dma 32-bit copy (channel 3)
;;	r0 = src
;;	r1 = dest
;;	r2 = size in bytes

dma_copy_32:	

	stmfd	r13!,{r0-r3}

	mov	r3,#0x04000000
	str	r0,[r3,#0xd4]
	str	r1,[r3,#0xd8]
	mov	r2,r2,lsr #2
	strh	r2,[r3,#0xdc]
	mov	r2,%1000010000000000
	strh	r2,[r3,#0xde]	
		
	ldmfd	r13!,{r0-r3}
	bx	lr

;;-------------------------------------------------------------
;;	includes
@pool

@include 	introdata.inc








