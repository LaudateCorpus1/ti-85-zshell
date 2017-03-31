#include "ti-85.h"


MTEXT_Y = $8333
MTEXT_X = $8334
TEXT_X =  $800D
TEXT_Y =  $800C
TIMER  =  $800E

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
.db     "Counter",0
ProgStart:

   ROM_CALL(CLEARLCD)

   BLACKTEXT

   ld   a,0
   ld   (TEXT_Y),a
   ld   (TEXT_X),a
   ld   hl,0000
   ld   (timer),hl

loop:

   ld a, 0
   ld (text_x),a
   ld (text_y),a

   ROM_CALL(D_HL_DECI)
   inc hl

   call get_key
   cp K_ENTER
   jr nz, loop

   ret

.END
