#include "ti-85.h"


MTEXT_Y = $8333
MTEXT_X = $8334
TEXT_X =  $800D
TEXT_Y =  $800C

#DEFINE WHITETEXT       set 3,(IY+05)
#DEFINE BLACKTEXT       res 3,(IY+05)
#DEFINE NOTEXTMEM       set 1,(IY+0D)
#DEFINE TEXTMEM         res 1,(IY+0D)

#DEFINE 6rows      res 1,(IY+05) ; Print only 6 rows of the character
#DEFINE 7rows      set 1,(IY+05) ; Print entire 7 rows of the character
#DEFINE COPYprint  res 3,(IY+05) ; Print character over current screen
#DEFINE XORprint   set 3,(IY+05) ; XOR character with current screen


.org    0
.db     "Character Map",0
ProgStart:

   ROM_CALL(CLEARLCD)

   BLACKTEXT

Start:


   ld   a,0
   ld   HL, $0000
   ld   (TEXT_Y), hl

loop1:

   ROM_CALL(TX_CHARPUT)

   inc   a
   cp    128
   jr    nz, loop1

   CALL_(WaitEnter)

   ld    hl, $0000
   ld    (text_y),hl

loop2:

   ROM_CALL(TX_CHARPUT)

   inc    a
   cp     255
   jr     nz, loop2

   CALL_(WaitEnter)

   WHITETEXT


   ld   a,0
   ld   HL, $0000
   ld   (TEXT_Y), hl

loop3:

   ROM_CALL(TX_CHARPUT)

   inc   a
   cp    128
   jr    nz, loop3

   CALL_(WaitEnter)

   ld    hl, $0000
   ld    (text_y),hl

loop4:

   ROM_CALL(TX_CHARPUT)

   inc    a
   cp     255
   jr     nz, loop4

   CALL_(WaitEnter)

   ret

WaitEnter:

KeyLoop:
   call GET_KEY
   cp   K_ENTER
   jr   nz, KeyLoop
   ret                    ;Return from sub-routine (or to ZShell)

String:
   .db  "Boo Wuz Here",0         ;String to use, with a 0 at the end

.END
