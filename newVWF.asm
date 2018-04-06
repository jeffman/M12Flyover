@thumb
@org $8FA0000

; Load the letter
ldrb r0,[r7]

; r2 is our shit register
; Let's push r9-r12 for oldMap, tile, letterPos and ramAddr
mov r2,r9
push {r2}
mov r2,r10
push {r2}
mov r2,r11
push {r2}
mov r2,r12
push {r2}
push {r5,r6}

; Load our variables into r9-r12
ldr r3,=#0x203FFF0
ldr r2,[r3]
mov r9,r2
ldrh r2,[r3,4]
mov r10,r2
ldrb r2,[r3,6]
mov r11,r2
mov r12,r3

; r0 = letter
; r1 = 0x8B1B4B0 (letter:tile lookup table)
; r2-r6 = free
; r7 = text read address
; r8 = currMap
; r9 = oldMap
; r10 = tile
; r11 = letterPos
; r12 = ramAddr

; Check for first-ever execute
mov r2,r9
cmp r2,0
bne NOT_VIRGIN
mov r10,r2
mov r11,r2
b SKIP_CHECK

NOT_VIRGIN:
; Check for newline
mov r2,r8
mov r3,r9
sub r2,r2,r3
cmp r2,2
beq SKIP_CHECK
mov r2,r11
cmp r2,0
beq SKIP_CHECK
mov r2,0
mov r11,r2
mov r2,r10
add r2,r2,1
mov r10,r2

SKIP_CHECK:

; Get the letter width
ldr r2,=#0x8F90000
ldrb r6,[r2,r0]

; Get VRAM write address
ldr r2,=#0x6000000
mov r3,r10
lsl r3,r3,1
ldrh r4,[r1,r3]
ldr r3,=#0x30051EC
ldrh r3,[r3]
add r3,r3,r4
lsl r3,r3,5
add r5,r2,r3

; r5 = vramAddr
; r6 = letterWidth

; Store currMap before it gets changed
mov r2,r8
mov r3,r12
str r2,[r3]

; Write the map tiles
; =========
; LOOP TIME
; =========
; r2,r3,r4 are currently free
; We need one register for i, currMap, tile, and some shit registers
; So let's push r0-r1,r5 for now
push {r0,r1}
mov r3,r10
lsl r3,r3,1
ldrh r1,[r1,r3]
mov r0,0
mov r4,r6
add r4,r11
; r2 = is already currMap
; r1 = tile
; r0 = i
; r4 = (letterPos + letterWidth)
ldr r3,=#0x30051EC
ldrh r3,[r3]
add r1,r1,r3
ldr r3,=#0x3005228
ldrh r3,[r3]
orr r1,r3

MAP_LOOP:
lsr r3,r0,3
add r1,r1,r3
strh r1,[r2]
add r1,0x20
add r2,0x40
strh r1,[r2]
sub r2,0x3E
add r0,8
cmp r0,r4
blt MAP_LOOP
pop {r0,r1}

; WELDING TIME
; Get fontRead
push {r7} ; Just in case the game uses it later
ldr r7,=#0x2038000
lsl r2,r0,1
add r2,r2,r1
ldrh r2,[r2]
lsl r2,r2,5
add r7,r7,r2

; r0 = free
; r1 = 0x8B1B4B0 (letter:tile lookup table)
; r2-r4 = free
; r5 = vramAddr
; r6 = letterWidth
; r7 = fontRead
; r8 = currMap
; r9 = oldMap
; r10 = tile
; r11 = letterPos
; r12 = ramAddr

; Upper 8 rows, first column
push {r5-r7}
mov r0,0
mov r3,r5
mov r4,r7
mov r6,r11
; r0 = i
; r2 = tmpRow
; r3 = vramAddr
; r4 = fontRead
; r6 = letterPos

UPPERLOOP1:
; Get the bitmap row that's already there
lsl r2,r0,2
ldr r2,[r2,r3]
; Get the OR operand
lsl r5,r0,2
ldr r5,[r4,r5]
lsl r7,r6,2
lsl r5,r7
; Weld
orr r2,r5
; Store
lsl r5,r0,2
str r2,[r5,r3]
; Loop
add r0,r0,1
cmp r0,8
blt UPPERLOOP1

; Check for second column weld
cmp r6,0
beq SKIP_UPPERLOOP2
; Get new VRAM address
ldr r2,=#0x6000000
mov r3,r10
add r3,r3,1
lsl r3,r3,1
ldrh r0,[r1,r3]
ldr r3,=#0x30051EC
ldrh r3,[r3]
add r3,r3,r0
lsl r3,r3,5
add r3,r2,r3

mov r0,0
; r0 = i
; r2 = tmpRow
; r3 = vramAddr
; r4 = fontRead
; r6 = letterPos
UPPERLOOP2:
; Get value
lsl r2,r0,2
ldr r2,[r4,r2]
mov r5,7
sub r5,r5,r6
lsl r5,r5,2
lsr r2,r5
; Store
lsl r5,r0,2
str r2,[r5,r3]
; Loop
add r0,r0,1
cmp r0,8
blt UPPERLOOP2

SKIP_UPPERLOOP2:

; Lower tile
mov r0,4
lsl r0,r0,8
add r3,r3,r0
add r4,r4,r0

mov r0,0
; r0 = i
; r2 = tmpRow
; r3 = vramAddr
; r4 = fontRead
; r6 = letterPos

LOWERLOOP1:
; Get the bitmap row that's already there
lsl r2,r0,2
ldr r2,[r2,r3]
; Get the OR operand
lsl r5,r0,2
ldr r5,[r4,r5]
lsl r7,r6,2
lsl r5,r7
; Weld
orr r2,r5
; Store
lsl r5,r0,2
str r2,[r5,r3]
; Loop
add r0,r0,1
cmp r0,8
blt LOWERLOOP1

; Check for second column weld
cmp r6,0
beq SKIP_LOWERLOOP2
; Get new VRAM address
ldr r2,=#0x6000400
mov r3,r10
add r3,r3,1
lsl r3,r3,1
ldrh r0,[r1,r3]
ldr r3,=#0x30051EC
ldrh r3,[r3]
add r3,r3,r0
lsl r3,r3,5
add r3,r2,r3

mov r0,0
; r0 = i
; r2 = tmpRow
; r3 = vramAddr
; r4 = fontRead
; r6 = letterPos
LOWERLOOP2:
; Get value
lsl r2,r0,2
ldr r2,[r4,r2]
mov r5,7
sub r5,r5,r6
lsl r5,r5,2
lsr r2,r5
; Store
lsl r5,r0,2
str r2,[r5,r3]
; Loop
add r0,r0,1
cmp r0,8
blt LOWERLOOP2

SKIP_LOWERLOOP2:

; FINISHED WELDING
pop {r5-r7}

; Adjust letterPos and tile
mov r0,r11
mov r1,r10
add r0,r0,r6
ADJUSTMENT:
cmp r0,8
blt FINISHED
sub r0,8
add r1,1
b ADJUSTMENT

FINISHED:

; Store them
mov r2,r12
strh r1,[r2,4]
strb r0,[r2,6]

; Lastly, pop our shit (r5-r6, r9-r12)
pop {r7}
pop {r5,r6}
pop {r2}
mov r12,r2
pop {r2}
mov r11,r2
pop {r2}
mov r10,r2
pop {r2}
mov r9,r2

; Branch back to 80CA46B
mov r0,8
lsl r0,r0,8
add r0,0xC
lsl r0,r0,8
add r0,0xA4
lsl r0,r0,8
add r0,0x6B
bx r0










private void VWF ()
{
	byte letter = LoadByte(r7);
	
	int ramAddr = 0x203FFF0;
	// ramAddr       =  Base map write address
	// ramAddr + 4   =  Previous r8
	// ramAddr + 8   =  Tile number
	int tile = LoadHWord(ramAddr + 8);
	byte letterPos = LoadByte(ramAddr + 10);
	int mapAddr = LoadWord(ramAddr);
	
	if (mapAddr == 0)
	{
		mapAddr = r8;
		tile = LoadHWord(0x30051EC);
		letterPos = 0;
		
		// Load some important tiles into VRAM
		// Solid black tile to make text boxes be solid
		CPUSet(0x203BFE0, 0x6000000 + ((LoadHWord(0x30051EC) + 0x1FF) << 5), 8);
		// HP/PP box borders
		CPUSet(0x2039680, 0x6000000 + ((LoadHWord(0x30051EC) + 0x1B4) << 5), 32);
		// Crap at the bottom
		CPUSet(0x203C000, 0x6000000 + ((LoadHWord(0x30051EC) + 0x200) << 5), 512);
		CPUSet(0x203D000, 0x6000000 + ((LoadHWord(0x30051EC) + 0x280) << 5), 512);
		goto skipCheck;
	}
	
	StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) - 1);
	
	if (
		!(((r8 - LoadWord(ramAddr + 4)) == 2) || 
		((r8 - LoadWord(ramAddr + 4)) == 0)) &&
		(letterPos > 0) ||
		(LoadWord(r5) != LoadWord(ramAddr + 12))
		
	{
		// New tile buffer
		// Tiles to avoid: 4D, 53-5F, B4-BF, FD-FF
		tile -= LoadHWord(0x30051EC);
		if (tile == 0x8C) tile = 0x8E;
		else if (tile == 0x92) tile = 0xC0;
		else if (tile == 0x153) tile = 0x180;
		else if (tile == 0x1DC) tile = 0;
		else if ((tile % 32) == 31) tile += 0x21;
		else tile++;
		tile += LoadHWord(0x30051EC);
		
		mapAddr = r8;
		StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) + 1);
	}
	
	skipCheck:
	
	// Weld the letter
	WeldLetter(letter, tile, letterPos);
	
	// Take care of map and letterPos stuff
	StoreHWord(mapAddr, tile | LoadHWord(0x3005228));
	StoreHWord(mapAddr + 0x40, (tile + 0x20) | LoadHWord(0x3005228));
	letterPos += LoadByte(0x8F90000 + letter);
	if (letterPos > 7)
	{
		letterPos -= 8;

		// Tiles to avoid: 4D, 53-5F, B4-BF, FD-FF
		tile -= LoadHWord(0x30051EC);
		if (tile == 0x8C) tile = 0x8E;
		else if (tile == 0x92) tile = 0xC0;
		else if (tile == 0x153) tile = 0x180;
		else if (tile == 0x1DC) tile = 0;
		else if ((tile % 32) == 31) tile += 0x21;
		else tile++;
		tile += LoadHWord(0x30051EC);
		
		if (letterPos == 0 && ENDOFTEXT) goto skipMap
		
		mapAddr += 2;
		StoreHWord(mapAddr, tile | LoadHWord(0x3005228));
		StoreHWord(mapAddr + 0x40, (tile + 0x20) | LoadHWord(0x3005228));
		StoreHWord(r5 + 0x2A, LoadHWord(r5 + 0x2A) + 1);
		
	}
	
	skipMap:
	
	// Store variables
	StoreWord(ramAddr, mapAddr);
	StoreWord(ramAddr + 4, r8);
	StoreHWord(ramAddr + 8, tile);
	StoreByte(ramAddr + 10, letterPos);
}

private void WeldLetter(byte letter, int tile, int letterPos)
{
	// r0 is letter
	// r1 is tile
	// r2 is letterPos
	
	// Letter should be the letter value from 0-255
	// Tile should be a tile # in VRAM, 0-0x7FF
	// Letterpos should be a pixel position within the tile to start welding to, 0-7
	
	int vramAddr = 0x6000000;
	int fontAddr = 0x2038000;
	int blankRow = 0x44444444;
	
	int tmpTile = 0;
	int tmpFont = 0;
	int tile2 = 0;
	byte letterTile = LoadByte(0x8B1B4B0 + (letter << 1));
	
	// Loop for two tiles, upper and lower
	for (int t = 0; t < 2; t++)
	{
		// Loop for 8 rows
		for (int y = 0; y < 8; y++)
		{
			// Get the row from font data
			tmpFont = LoadWord(fontAddr + (t << 10) + (letterTile << 5) + (y << 2));
			
			// Weld
			
				// Left
				tmpTile = LoadWord(vramAddr + (t << 10) + (tile << 5) + (y << 2));
				tmpTile |= (tmpFont << (letterPos << 2));
				tmpTile |= (blankRow >> ((8 - (letterWidth + letterPos)) << 2));
				StoreWord(vramAddr + (t << 10) + (tile << 5) + (y << 2), tmpTile);
				
				// if (letterPos + letterWidth <= 8) goto skipRight
				
				// Right
				// Tiles to avoid: 4D, 53-5F, B4-BF, FD-FF
				tile2 = tile - LoadHWord(0x30051EC);
				if (tile2 == 0x8C) tile2 = 0x8E;
				else if (tile2 == 0x92) tile2 = 0xC0;
				else if (tile2 == 0x153) tile2 = 0x180;
				else if (tile2 == 0x1DC) tile2 = 0;
				else if ((tile2 % 32) == 31) tile2 += 0x21;
				else tile2++;
				tile2 += LoadHWord(0x30051EC);
				
				tmpTile = LoadWord(vramAddr + (t << 10) + (tile2 << 5) + (y << 2));
				tmpTile |= (tmpFont >> ((8 - letterPos) << 2));
				tmpTile |= (blankRow << (letterPos << 2));
				StoreWord(vramAddr + (t << 10) + (tile2 << 5) + (y << 2), tmpTile);
				
				skipRight:
		}
	}
}

/*
				if ((tile % 32) == 31)
				{
					// Next tile is an extra row down
					tmpTile = LoadWord(vramAddr + (t << 10) + ((tile + 0x21) << 5) + (y << 2));
					tmpTile |= (tmpFont >> ((8 - letterPos) << 2));
					tmpTile |= (blankRow << (letterPos << 2));
					StoreWord(vramAddr + (t << 10) + ((tile + 0x21) << 5) + (y << 2), tmpTile);
				}
				else
				{
					// Next tile is fine
					tmpTile = LoadWord(vramAddr + (t << 10) + ((tile + 1) << 5) + (y << 2));
					tmpTile |= (tmpFont >> ((8 - letterPos) << 2));
					tmpTile |= (blankRow << (letterPos << 2));
					StoreWord(vramAddr + (t << 10) + ((tile + 1) << 5) + (y << 2), tmpTile);
				}
*/