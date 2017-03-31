;+----------
;| Cheesy Side Scrolling Stars
;|
#include "ti-85.h"
#include "tidefs.h"
max_x = 128
max_y = 64

ArrayStart = $80DF		; Table Of Data for 'Stars'
						; Stored as X, then Y,
                        ; Then next Star... 10 stars?
                        ; room for 84 stars

TIMER = $8008
.org    0
.db     "Stars",0

ProgStart:

   ROM_CALL(CLEARLCD)

   ;ld   a,4          ;mem page 4
   ;out  (5),a        ;for graphics

   ;CALL_(SetUpStars)
   ;CALL_(DrawStars)

   CALL_(GetRandom)
   ld hl, 0
   ld l,a


   ld (text_x),a
   ld (text_y),a

   CALL_(D_HL_DECI)


   CALL_(WaitKey)

ExitMain:
   ret

;+----
;|  Set Up Stars...
;+----
SetUpStars:
    ld b, 20
    ld hl, ArrayStart

SUSLoop:
    push bc

	CALL_(GetRandom)
    ld (hl),a		; x = rand between 0-127

    inc hl
    CALL_(GetRandom)
    sra a
	ld (hl),a 		; y = rand between 0-63
    inc hl

	pop bc
	djnz SUSLoop

SUSExit:

	ret

;+----
;| Get Random Number (Uses Blink Timer) / A = Random Number
;+----
GetRandom:
    push hl
	ld hl, timer
    ld a, (hl)
    pop hl
	ret
;+----
;|  Draw Stars...
;+----
DrawStars:

	ld   a,4          ;mem page 4
   	out  (5),a        ;for graphics

	ld b,20
DSLoop:
	push bc

    ld b,(hl)
	inc hl
    ld c,(hl)
    inc hl
	CALL_(PutPixel)

    pop  bc
	djnz DSLoop

DSExit:

	ret

;+----
;|  Long Delay
;+----
Long_Delay:
    push af
    push bc
    ld   bc,30000
Long_Delay_Loop:
    dec  bc
    ld   a,b
    or   c
    jr   nz,Long_Delay_Loop
    pop  bc
    pop  af
    ret


;+----
;|  Put Pixel (B,C)
;+----
PutPixel:

   push bc                  ;Save away, so it can be used again
   ROM_CALL(FIND_PIXEL)     ;Get the pixel offset
   ld   de,$FC00
   add  hl,de               ;Point into the graphics memory
   or   (HL)                ;A now contains the modified screen byte
   ld   (HL),A              ;Write back to screen to update
   pop  bc                  ;Restore
   ret

;+----
;|  Erase Pixel At (B,C)
;+----
DelPixel:

   push bc                  ;Save away, so it can be used again
   ROM_CALL(FIND_PIXEL)     ;Get the pixel offset
   ld   de,$FC00
   add  hl,de               ;Point into graphics memory
   xor  255                 ;Invert the accumulator
   and  (hl)                ;A now contains the modified screen byte
   ld   (hl),a              ;Write back to screen to update
   pop  bc                  ;Restore
   ret


;+----
;|  Get Pixel At (B,C)
;+----
GetPixel:

   push bc                  ;Store away, so it can be used again
   ROM_CALL(FIND_PIXEL)     ;Get the pixel offset
   ld   de,$FC00
   add  hl,de               ;Point into graphics memory
   and  (hl)                ;ACC is ACC AND the memory
   pop  bc                  ;Restore
   ret

;+----
;|  Wait For Key Press
;+----
WaitKey:

  call get_key
  cp   K_NOKEY
  jr   z, WaitKey
  ret

.end
