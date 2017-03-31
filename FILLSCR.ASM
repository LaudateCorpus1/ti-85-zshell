#include "ti-85.h"


mtext_y = $8333
mtext_x = $8334
TEXT_X =  $800D
TEXT_Y =  $800C
max_x  =  128
max_y  =  64

#DEFINE WHITETEXT       set 3,(IY+05)
#DEFINE BLACKTEXT       res 3,(IY+05)
#DEFINE NOTEXTMEM       set 1,(IY+0D)
#DEFINE TEXTMEM         res 1,(IY+0D)

#DEFINE 6rows      res 1,(IY+05) ; Print only 6 rows of the character
#DEFINE 7rows      set 1,(IY+05) ; Print entire 7 rows of the character
#DEFINE COPYprint  res 3,(IY+05) ; Print character over current screen
#DEFINE XORprint   set 3,(IY+05) ; XOR character with current screen


.org    0
.db     "In Progress",0
ProgStart:

   ROM_CALL(CLEARLCD)

   ld   a,4          ;mem page 4
   out  (5),a        ;for graphics

Start:

   ld c, 0

loop1:

   ld b, 0

loop2:

   CALL_(GetPixel)
   cp 0
   jr nz, Erase

;Draw:

   CALL_(PutPixel)
   jr Cont

Erase:

   CALL_(DelPixel)

Cont:

   call GET_KEY
   cp   K_ENTER
   jr   z,Done

   inc  b
   ld   a,b
   cp   max_x
   jr   nz, loop2

   inc  c
   ld   a,c
   cp   max_y
   jr   nz, loop1

   jr   Start


Done:
   ret                    ;Return from sub-routine (or to ZShell)

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

.end
