#include "ti-85.h"


mtext_y = $8333
mtext_x = $8334
TEXT_X =  $800D
TEXT_Y =  $800C
max_x  =  128
max_y  =  64

ballx = $80EA                  ;The ball's current X position
bally = $80EB                  ;The ball's current Y position
lastx = $80EE
lasty = $80EF

dy = $80EC             ;1=Upwards, 2=Downwards
dx = $80ED             ;1=Left, 2=Right


#DEFINE WHITETEXT       set 3,(IY+05)
#DEFINE BLACKTEXT       res 3,(IY+05)
#DEFINE NOTEXTMEM       set 1,(IY+0D)
#DEFINE TEXTMEM         res 1,(IY+0D)

#DEFINE 6rows      res 1,(IY+05) ; Print only 6 rows of the character
#DEFINE 7rows      set 1,(IY+05) ; Print entire 7 rows of the character
#DEFINE COPYprint  res 3,(IY+05) ; Print character over current screen
#DEFINE XORprint   set 3,(IY+05) ; XOR character with current screen

#DEFINE nprint(x,y,n) ld a,x \ ld (text_x),a \ ld a,y \ ld (text_y),a \ ld hl, n \  ROM_CALL(D_HL_DECI)
.org    0
.db     "In Progress",0

ProgStart:

   ROM_CALL(CLEARLCD)

   ld   a,4          ;mem page 4
   out  (5),a        ;for graphics
   ld   a,1
   ld   (dx),a
   ld   (dy),a
   ld   a,max_x/2
   ld   (ballx),a
   ld   a,max_y/2
   ld   (bally),a

Loop:

   CALL_(long_Delay)


   CALL_(eraseIt)
   CALL_(drawit)


KeyLoop:
   call GET_KEY
   cp   K_EXIT
   jr   z,Done
   ;cp   K_ENTER
   ;jr   nz, KeyLoop

CheckX:
   ld a, (dx)
   cp 2
   jr z, DecX

IncX:
   ld a,(ballx)
   inc a
   ld (ballx),a

   cp max_x-1
   jr nz, CheckY

   ld a, 2
   ld (dx),a
   jr CheckY

DecX:

   ld a,(ballx)
   dec a
   ld (ballx),a

   cp 1
   jr nz, CheckY

   ld a,1
   ld (dx),a
   jr CheckY

CheckY:
   ld a, (dy)
   cp 2
   jr z, DecY

IncY:

   ld a,(bally)
   inc a
   ld (bally),a

   cp max_y-1
   jr nz, loop

   ld a, 2
   ld (dy),a
   jr loop

DecY:

   ld a,(bally)
   dec a
   ld (bally),a

   cp 1
   jr nz, loop

   ld a,1
   ld (dy),a
   jr loop

Done:
   ret                    ;Return from sub-routine (or to ZShell)


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

EraseIt:
   ld a, (lastx)
   ld b, a
   ld a, (lasty)
   ld c, a
   CALL_(DelPixel)
   ret

DrawIt:
   ld a, (ballx)
   ld b,a
   ld (lastx),a

   ld a, (bally)
   ld c,a
   ld (lasty),a

   CALL_(PutPixel)
   ret

PutPixel:

   push bc                  ;Save away, so it can be used again
   ROM_CALL(FIND_PIXEL)     ;Get the pixel offset
   ld   de,$FC00
   add  hl,de               ;Point into the graphics memory
   or   (HL)                ;A now contains the modified screen byte
   ld   (HL),A              ;Write back to screen to update
   pop  bc                  ;Restore
   ret


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


GetPixel:

   push bc                  ;Store away, so it can be used again
   ROM_CALL(FIND_PIXEL)     ;Get the pixel offset
   ld   de,$FC00
   add  hl,de               ;Point into graphics memory
   and  (hl)                ;ACC is ACC AND the memory
   pop  bc                  ;Restore
   ret

WaitEnter:

  call get_key
  cp   K_ENTER
  jr   nz, WaitEnter
  ret

.end
