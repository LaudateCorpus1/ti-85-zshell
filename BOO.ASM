#include "ti-85.h"


Y_Coord = $8333
X_Coord = $8334

.org    0
.db     "In Progress",0
ProgStart:

   ROM_CALL(CLEARLCD)

   ld   hl,STRING         ;Offset of the string, defined within "myself"
   ld   de,(PROGRAM_ADDR) ;Address of program start, defined in TI-85.H
   add  hl,de
   ld   a, 0
   ld   (X_Coord), a
   ld   (Y_Coord), a
   ROM_CALL(D_ZM_STR)     ;Display the string

   ld   a,4
   out  (5),a

   ld   b,10
   ld   c,50                ;Put pixel at (10,50)
   ROM_CALL(FIND_PIXEL)
   or   (hl)
   ld   (hl),a

KeyLoop:
   call GET_KEY
   cp   K_ENTER
   jr   nz, KeyLoop
   ret                    ;Return from sub-routine (or to ZShell)

String:
   .db  "Boo Wuz Here",0         ;String to use, with a 0 at the end

.END
