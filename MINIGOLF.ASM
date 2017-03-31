;+----------------------------------
;| TI-85 Mini Golf for Zshell 4.0
;| Chris Bowron / Digital Dreamland 1996
;|
;| Digital Dreamland Wrecking Crew:
;|		Chris "MAD Hacker" Bowron
;|		Aaron "Mr. Happy" Baird
;|		Ethan "Oracle" Aubin
;|  	Michael "Pseudosane" "Kewl" Kyle
;+---------------------------------
;| Last Modification : Jan 29, 1996
;|
;| "When I think back to all the crap I learned in high school,
;| it's a wonder I can think at all."
;|					Paul Simon
;|
;| A Man's Got To Believe In Something,
;| I Believe I'll Go Golfing...
;|


#include "ti-85.h"
#include "tidefs.h"

;+
;| Variables (Memory Locations)
;+

BaseMem   = $80DF             ; fill in l8r
						; 128 free bytes in text mem

BallX     = BaseMem
BallY     = BaseMem+1
IncX      = BaseMem+2     ; {-2,-1,0,1,2}
IncY      = BaseMem+3     ; {-2,-1,0,1,2}
LastX     = BaseMem+4
LastY     = BaseMem+5
HoleX     = BaseMem+6
HoleY     = BaseMem+7
CurrHole  = BaseMem+10
Dir       = BaseMem+11
CursorX   = BaseMem+12
CursorY   = BaseMem+13
Strength  = BaseMem+14

Flag   		= BaseMem+15
Way     	= BaseMem+16


.org 0
.db "DDL Mini-Golf V 1.29",0
;+-----
;| Code Starts Here
;+-----
ProgStart:

    ROM_CALL(ClearLCD)

	CALL_(DoTitle)
	CALL_(DoGame)

	ret

;+------
;| Play Game (Main Stuff)
;+------
DoGame:

	CALL_(DrawHole)
    CALL_(WaitKey)

GameLoop:

    ;CALL_(GetDirection)
    ;CALL_(GetStrength)
    ;CALL_(UpdateBall)

	ret
;+-----
;| Draw Current Hole
;+-----
DrawHole:

	ld a, 4
    out (5),a

    ROM_CALL(ClearLCD)

	ld  hl, Dir
    ld  a, 1
    ld (hl), a                ;    Default Direction = 1

	ld  hl, (PROGRAM_ADDR)
    ld  de, Hole1
    add hl, de

    ld  a, (HL)
    ld (ballx), a
    inc hl

    ld  a, (hl)
    ld (bally), a
    inc hl

    ld  a, (hl)
    ld  (holex), a
    inc hl

    ld  a, (hl)
    ld  (holey), a
    inc hl

	ld b, (hl)
	inc hl

    ld c, (hl)		; Starting points
	inc hl

	CALL_(SafePutP)

DrawLoop:

    ld  a, (hl)

    cp  255
    jr  z, DoHole        ; If D = 255 Then Exit Loop


    ld  d, a
    inc hl

    ld  a, (hl)
    cp  255

    jr  z, DoHole
    ld  e, a
    inc hl

    CALL_(Line)


	ld b,d
	ld c,e				; BC=DE

    CALL_(WaitKey)
	cp K_EXIT
    jr nz, DrawLoop


DoHole:
    ld a, (holex)
    ld b, a                   ; b = holex
    ld a, (holey)
	ld c, a                  ; c = holey

    dec c
    dec c

	ld d, b
    ld e, c					; DE=BC

    dec d
    dec d
    inc b
    inc b

    ld a, 4
DHLoop:
	push af

    CALL_(Line)

    inc c
    inc e
    pop af

    dec a

	cp 0
    jr nz, DHLoop

HoleDone:

DrawBall:

    ld a, (ballx)
    ld b, a
	ld (lastx),a

    ld a, (bally)
    ld (lasty),a
	ld c, a

    CALL_(SafePutP)      ; Draw Ball At (BallX, Bally)

	ret

;+-----
;| Draw Line From (B,C) to (D,E)   [[[Hopefully]]]
;| Bresenham's line algorithm
;| by Stephane JANTZEN
;| Stephane.Jantzen@scinfo.u-nancy.fr
;+-----
Line:                           ;beginning of the line routine
        push    BC
        push    DE
		push 	HL

        ld 		h,b
		ld 		l,c


        ld      A,D
        sub     H
        jr      NC,DXpositive    ;delta_x > 0
DXNegative:
        neg
DXPositive:
        ld      B,A              ;B <- |delta_x|
        ld      A,E
        sub     L
        jr      NC,DYpositive    ;delta_y > 0
DYNegative:
        neg
DYPositive:                
        sub     B               ;|delta_y|
        jr      C,DeltaX        ;|delta_x| > |delta_y|
DeltaY:
        ld      A,H             ;if |delta_x| < |delta_y| then
        ld      H,L             ;then values x and y are swapped
        ld      L,A             ;so the loop will always be performed on the
        ld      A,D             ;x value. A flag must be set to
        ld      D,E             ;remind that data must be drawn (y,x)
        ld      E,A             ;instead of (x,y)

        ld      A,$01
        ld      (Flag),A        ;the Flag !!!
DeltaX:
        ld      A,D
        sub     H
        jr      NC,TestDY        ;x1 < x2
TestDX:
        ex		DE,HL
TestDY:
        ld      A,E
        sub     L
        ld      A,$01
        jr      NC,StoreA
        neg                     ;y1 > y2 : in case2 the 'y' variable
StoreA:
        ld      (Way),A
InitLine:
        ld      B,H
        ld      C,L
        ld      A,E
        sub     L
        jr      NC,EndInit
        ld      A,L
        ld      L,E
        ld      E,A
EndInit:
        ld      A,E
        sub     L
        rla
        ld      L,A             ;value to add in case1 (d < 0)
        add     A,H
        sub     D
        ld      E,A             ;'d' variable is initialised
        add     A,H
        sub     D
        ld      H,A             ;value to add in case2 (d >= 0)
Loop:
        ld      A,B
        sub     D
        jr      NC,EndLine       ;the line is completely drawn.
        ld      A,(Flag)
        or      A
        push    AF
        push    BC
        jr      Z,DrawPoint
        ld      A,B
        ld      B,C
        ld      C,A
DrawPoint:
        CALL_(PointOn)
        pop     BC
        pop     AF
TestD:
        bit     7,E
        jr      NZ,Case1
Case2:                          ;d >= 0
        ld      A,E
        add     A,H
        ld      E,A
        ld      A,(Way)
        add     A,C
        ld      C,A
        jr      EndLoop
Case1:                          ;d < 0
        ld      A,E
        add     A,L
        ld      E,A
EndLoop:
        inc     B
        jr      Loop
EndLine:
        pop 	HL
        pop     DE
        pop     BC

        ret                     ;end of the circle routine

PointOn:
        push    DE              ;MUST NOT BE REMOVED
        push    HL              ;MUST NOT BE REMOVED
        ROM_CALL(FIND_PIXEL)
        ld      DE,$FC00
        add     HL,DE
        or      (HL)
        ld      (HL),A
        pop     HL              ;MUST NOT BE REMOVED
        pop     DE              ;MUST NOT BE REMOVED
        ret

	ret

;+-----
;| Get Direction
;+-----
GetDirection:

    ld a, (BallX)
    ld b, a
    ld a, (BallY)
    ld c,a

    ld a, (Dir)
    
    ld hl, (PROGRAM_ADDR)
    ld de, DirTable


GDLookLoop:
	inc hl
    inc hl

	dec a
    cp 0
    jr nz, GDLookLoop         ; Set UP HL --> IncX, IncY

	ld a, (hl)                    ; a = IncX

    add a,a                        ; a * 2
    add a,a                        ; a * 4
    add a,b                        ; b = b + 4 * IncX
	ld  b, a

    inc hl
    ld  a, (hl)                    ; A = IncY

    add a,a
    add a,a                   ; a * 4
    add a,c                   ; c = c + 4 * IncX
    ld  c,a

	ld a, b
    ld (CursorX),a            ; CursorX = BallX + 4 * IncX
    ld a, c
    ld (CursorY),a            ; CursorY = BallY + 4 * IncY

	CALL_(DrawCursor)        ; Draw It Durn it!

	CALL_(WaitKey)           ; Key A Key Press
	cp K_ENTER
    jr z, GDExit              ; If Enter Exit Loop

    cp K_LEFT
    jr z, DecDir

    cp K_RIGHT
    jr z, IncDir

    jr GetDirection

DecDir:

    ld a, (Dir)
    cp 1
    jr DDLoopAround
	dec a
    ld (dir),a
	jr GetDirection

DDLoopAround:
    ld a, 16
	ld (dir),a
    jr GetDirection

IncDir:
	ld a, (Dir)
    cp 16
    jr IDLoopAround
    inc a
    ld (dir),a
    jr GetDirection

IDLoopAround:

    ld a, 1
    ld (Dir),a

	jr GetDirection

GDExit:

	ret

;+-----
;| Draw Cursor at CursorX, CursorY
;+-----
DrawCursor:

	ld hl, CursorX
    ld b, (hl)
    ld hl, CursorY
    ld c, (hl)

    dec b
    dec b
	ld a, 5
DCXLoop:
	CALL_(PutPixel)          ; draw point at (b,c)
	inc b
    dec a
    cp 0
    jr nz, DCXLoop       ; repeat 5x's

	dec b
    dec b                ; b = CursorX

	ld a, 5
DCYLoop:
	CALL_(PutPixel)          ; draw (b,c)
	inc c
    dec a
    cp 0
    jr nz, DCYLoop       ; repeat 5x's

DCDone:

	ret                      ; Cursor is drawn

;+-----
;| Get Strength
;+-----
GetStrength:

	ld a,10
    ld (mtext_y),a
    ld a,50
    ld (mtext_x),a

   	ld  hl, (PROGRAM_ADDR)
    ld  de, StrengthStr
    add hl, de					; HL = *("Strength")


    ROM_CALL(D_ZM_STR)			; Print "Strength" At (50,10)

GSRestart:


    ld a, 100
    ld (mtext_x),a
    ld a, '|'
    ROM_CALL(M_CHARPUT)			; Boundary Brackets

    ld a, 70
    ld (mtext_x),a
    ld a, '|'
    ROM_CALL(M_CHARPUT)			; Print "|"


    ld a,0
    ld (Strength),a

    CALL_(WaitKey)

GSLoop:

	CALL_(Delay)


    ;ld a, (mtext_x)
    ;inc a
    ;ld (mtext_x),a				; Increase MTEXT_X

    ld a, '|'					; Print "|"
    ROM_CALL(M_CHARPUT)

    ld a, (strength)
    inc a
    ld (strength),a				; Increase Strength

    cp 30
    jr z, GSRestart				; If a=30 then startover

    call get_key
    cp 0
    jr z, GSLoop				; Loop if no key pressed

	ret

;+-----
;| Update Ball Positioning
;+-----
UpdateBall:

	ld a,(ballx)
    ld b,a					; B=BALLX

    ld a,(bally)			; C=BALLY
    ld c,a

    ld a,(incx)				; D=INCX
    ld d,a

    ld a,(incy)				; E=INCY
	ld e,a

    ld a, (strength)		; A = Strength
							; e.g. number of loops
UPLoop:

	push af

	ld a, (ballx)
    add a,d
    ld (ballx),a
	ld b,a

    ld a,(bally)
    add a,e
    ld (bally),a
	ld c,a

    CALL_(SafePutP)

    CALL_(CheckX)
    CALL_(CheckY)

    pop af
    dec a
    cp 0
    jr nz, UPLoop		; Loop Till A=0

	ret
;+-----
;| Check X (Did we hit anything)
;+-----
CheckX:

	ret
;+-----
;| Check Y (Did we hit anything)
;+-----
CheckY:

	ret
;+-----
;| Display Title Information
;+-----
DoTitle:

	ld  hl, (PROGRAM_ADDR)
    ld  de, TitleStr
    add hl, de
    ld    a,0
    ld    (text_x),a
    ld    (text_y),a

    ROM_CALL(D_ZT_STR)        ; Display Title Str
	CALL_(WaitKey)           ; Wait For Key Press
	ret

;+-----
;| Wait For Key, return in register A
;+-----
WaitKey:

    call get_key
    cp 0
    jr z, WaitKey

    ret

;+-----
;| Safe Put Pixel
;+-----
SafePutP:
	ld a, 4
    out (5),a

    push de
    push hl

    CALL_(PutPixel)

    pop hl
    pop de

    ret

;+-----
;| Delay
;| (from Texanoid by Magnus Hagander)
;+-----
Delay:
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


#include "grafx.h"       ;   Putpixel, DelPixel, GetPixel ...


;+-----
;| Constants and Saved Parameters
;+
TitleStr:
	;        123456789012345678901
    .db     "     DDL Mini-Golf   "	;1
    .db		"      (C) 1996       " ;2
    .db     "  Christopher Bowron " ;3
    .db     "  Digital Dreamland  " ;4
    .db     "       MCMXCVI       " ;5
	.db     "  [Share And Enjoy]  " ;6
    .db 0

StrengthStr:
	.db "Stregth:",0
HoleStr:
	.db "Hole:",0
StrokeStr:
	.db "Strokes:",0

DirTable:   ; IncX, IncY for all 16 directions    IncX & IncY  = {-2,2}

    ; 15 16 1 2  3
    ; 14 \ \|/ / 4
    ;    \ \|/ /
    ; 13 ---+--- 5
    ;    / /|\ \
    ; 12 / /|\ \ 6
    ; 11 10 9 8  7

    .db  0, 2                ; 1
    .db 1, 2                  ; 2
    .db 2, 2                 ; 3
    .db 2, 1                ; 4
    .db 0, 2                ; 5
    .db 2, -1               ; 6
	.db 2, -2             ; 7
    .db 1, -2               ; 8
    .db 0, -2               ; 9
    .db -1,-2                ; 10
    .db -2,-2                ; 11
    .db -2,-1                ; 12
    .db -2, 0                ; 13
    .db -2, 1                ; 14
    .db -2, 2                ; 15
    .db -1, 2                ; 16

Hole1:
    ;   +-----+
    ;   |  O  |
    ;   |     |
    ;   |     |
    ;   |  .  |
    ;   +-----+
    .db 64, 16                         ;    ballx, bally
    .db 64, 56                     ;    holex, holey
    .db 32, 10                      ;    startx,starty
    .db 32, 60                         ;    linex, liney
    .db 50, 60                  ;
    .db 50, 10                         ;
    .db 32, 10                      ;
    .db 255                     ;    end

Hole2:

Hole3:

Hole4:

Hole5:

Hole6:

Hole7:

Hole8:

Hole9:

.end


