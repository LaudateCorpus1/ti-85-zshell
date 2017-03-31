; Check Scan Codes and Translation
;
;
#INCLUDE "ti-85.h"
#INCLUDE "tidefs.h"

.ORG 0
.db "Char Routines",0

Start:

	ROM_CALL(ClearLCD)

Main:
	CALL_(WaitKey)

	cp K_EXIT
	jr z, Done

	ROM_CALL(TX_CHARPUT)

	ld hl, $8001
	ld a, (hl)

	ROM_CALL(TX_CHARPUT)

	jr Main

Done:

	ret
;+------
;| Wait Until Keypressed (A = Scan code)
;+------
WaitKey:

   call get_key
   cp K_NOKEY
   jr z, WaitKey
   ret

.end


