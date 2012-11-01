;+--------------------------------------------
;| Password Protection For TI-85, Via Zshell
;| Chris Bowron / Digital Dreamland 1996
;| ai150@detroit.freenet.org
;|
;|  "When Privacy Is Outlawed, Only Outlaws
;|             Will Have Privacy"
;|
;|  "Living is easy with eyes closed,
;|    Misunderstanding all you see"
;|                     John Lennon
;|
;|  "Anyone who says they can see through
;|        women is missing alot"
;|                     Groucho Marx
;+--------------------------------------------
;|Don't laugh, this is my first 'real' program
;+--------------------------------------------
;| Last Modification Jan 24, 1996 Circa 9:30 PM
;+----------------------------------------------
;| To Do List:
;|    Change Password From Program (e.g. Choose Shutdown or Change PW) - Done
;|    Distribute (String & Source) - In Progress
;|    Fathom How The Hell It Actually Works - Slowly, but Surely
;|    Self Encrypting????  - Pipe Dream :)
;|    Makes Wads Of Cash - Working on It
;|

#INCLUDE "TI-85.H"

#define RECALC     ld   hl,ZS_BITS  \ set  0,(hl)
#define WARPOUT    ld   hl,ZS_BITS  \ set  1,(hl)

TEXT_X =  $800D
TEXT_Y =  $800C

.org 0
.db "DDL PW Protect v1.24",0

;+------
;| Start Here Buddy,
;+------


ProgStart:

    ROM_CALL(ClearLCD)
	ld  a,0
    ld  (text_x),a
    ld  (text_y),a
    ld  hl, (PROGRAM_ADDR)
    ld  de, MenuStr
    add hl, de
	ROM_CALL(D_ZT_STR)

    CALL_(WaitKey)

    cp K_EXIT
    jr z, OutOfHere

    cp K_3
    jr z, Menu3

    cp K_1
	jr z, Menu1

    cp K_2
	jr z, Menu2

    jr ProgStart

Menu1:
	CALL_(ShutDown)
    jr OutOfHere

Menu2:
    CALL_(ChangePassword)
	jr ProgStart

Menu3:

OutOfHere:

	CALL_(DispCorrect)
	CALL_(WaitKey)

	RECALC               ;Recalculate CheckSum
   	WARPOUT

	ret

;+-----
;| Change Password
;+-----
ChangePassword:

	ROM_CALL(ClearLCD)

    ld 	hl, (PROGRAM_ADDR)
    ld 	de, CurrentStr
    add hl, de
    ld  a,0
    ld  (text_x),a
    ld  a,4
    ld  (text_y),a
	ROM_CALL(D_ZT_STR)

    CALL_(GetPassword)
    CALL_(CheckPW)
    cp 0
    jr nz, WrongPW

    ROM_CALL(ClearLCD)

    ld 	hl, (PROGRAM_ADDR)
    ld 	de, NewStr
    add hl, de
    ld  a,0
    ld  (text_x),a
    ld  a,4
    ld  (text_y),a
    ROM_CALL(D_ZT_STR)

    CALL_(GetPassword)

    ROM_CALL(ClearLCD)

    ld a,0
    ld (text_x),a
    ld (text_y),a

    ld hl, (PROGRAM_ADDR)
    ld de, DummyStr
    add hl, de

    ROM_CALL(D_ZT_STR)

    ld a,0
    ld (text_x),a
    ld a,1
    ld (text_y),a

    ld hl, (PROGRAM_ADDR)
    ld de, YesNoStr
    add hl, de

    ROM_CALL(D_ZT_STR)

PWCKeyLoop:

	CALL_(WaitKey)

    cp K_1
    jr z, ChangeIt

    cp K_2
    jr z, DontDoIt

    cp K_EXIT
    jr z, DontDoIt

    jr PWCKeyLoop

ChangeIt:

	CALL_(DummyStr2PWStr)
    jr CPWExit

DontDoIt:

	ld 	hl, (PROGRAM_ADDR)
    ld 	de, NoChangeStr
    add hl, de
	ROM_CALL(D_ZT_STR)
	CALL_(WaitKey)
    jr  CPWExit

WrongPW:

	CALL_(DispWrong)
   	CALL_(WaitKey)

CPWExit:

    ret
;+----
;| Copy Password From DummyStr to PWStr
;+----
DummyStr2PWStr:
	ld  hl, (PROGRAM_ADDR)
    ld  de, DummyStr
    add hl, de				; HL Points To DummyStr
    ex  de, hl				; DE Points To DummyStr

    ld  hl, (PROGRAM_ADDR)
    ld  bc, PWStr
    add hl, bc				; HL Points To PWStr

    ld b, 8					; 8 Chars For PW
CILoop:

	ld a, (de)
    ld (hl), a				; PWStr[8-b] = DummyStr[8-b]

    inc hl
    inc de

	djnz CILoop

	ld 	hl, (PROGRAM_ADDR)
    ld 	de, ChangeStr
    add hl, de
	ROM_CALL(D_ZT_STR)
    CALL_(WaitKey)

	ret

;+-----
;| Shut Down Calculator, Prompting For PW When Turned ON
;+-----
ShutDown:

   ROM_CALL(ClearLCD)
   CALL_(DispInfo)

MajorLoop:

   CALL_(PowerDown)

   CALL_(GetPassWord)

   CALL_(CheckPW)

   cp 0
   jr z, CorrectPW

WrongStinkingPW:

   CALL_(DispWrong)
   CALL_(WaitKey)
   ROM_CALL(ClearLCD)
   CALL_(DispInfo)

   jr MajorLoop

CorrectPW:

ReturnCalc:

   ret

;+------
;| Display Program Info
;+------
DispInfo:

   ld  a, 0
   ld  (text_x),a
   ld  (text_y),a
   ld  de, InfoStr
   ld  hl, (PROGRAM_ADDR)
   add hl, de
   ROM_CALL(D_ZT_STR)
   ret

;+------
;| Display Incorrect PW Info
;+------
DispWrong:

   ROM_CALL(ClearLCD)

   ld  a, 0
   ld  (text_x),a
   ld  (text_y),a
   ld  de, WrongPWStr
   ld  hl, (PROGRAM_ADDR)
   add hl, de
   ROM_CALL(D_ZT_STR)
   ret

;+------
;| Display Correct PW Info
;+------
DispCorrect:

   ROM_CALL(ClearLCD)

   ld  a, 0
   ld  (text_x),a
   ld  (text_y),a
   ld  de, CorrectPWStr
   ld  hl, (PROGRAM_ADDR)
   add hl, de
   ROM_CALL(D_ZT_STR)

   ret

;+------
;| Wait Until Keypressed (A = Scan code)
;+------
WaitKey:

   call get_key
   cp K_NOKEY
   jr z, WaitKey
   ret

;+------
;| Wait Till Key Pressed Or LCD Is On / Currently Unused
;+------
;WaitOn:
;
;    in a, (3)
;
;    bit 1, a			; Is LCD On?
;    jr nz, ExitWO
;
;    bit 0, a
;    jr  nz, ExitWO		; Has On Been Pressed?
;
;    bit 3, a
;    jr  z, ExitWO	    ; Is On Pressed NOW...
;
;	call GET_KEY
;    cp 0
;    jr z, WaitOn
;
;ExitWO:
;
;	ret
;
;+------
;| Shut Down Calculator
;+------
PowerDown:

    DI

   	ld a, 00000001b
	OUT  ($03),A
		 ;76543210
    ld a, 00000000
    	 ;   ||||
         ;	 ||++---Low Resistance
		 ;	 ++---- 10 Byte Buffer
    out (4),a

	EX	AF,AF'		; 4B59
	EXX			; 4B5A

    ;ld a, $40		; Doesn't work correctly
    ;out (6),a

	EI
	HALT

TurnOn:

   	;DI

    ld 	a,  $16			; Normal Buffer Mode
    out (4),a

   	ld  a, $41
   	out (6),a

	ld a, 00001011b      ;LCD On
   	out (3),a

   	;EI

   	ret
;+------
;| Get Password From Calculator
;+------
GetPassWord:

   ld  a, 0
   ld  (text_x),a
   ld  a, 5
   ld  (text_y),a
   ld  hl, (PROGRAM_ADDR)
   ld  de, PromptStr
   add hl,de

   ROM_CALL(D_ZT_STR)           ; print prompt

   CALL_(GetString)             ; DummyStr = Entered Password

   ret

;+------
;| Get String Into DummyStr
;+------
GetString:
   ld   hl,(PROGRAM_ADDR)
   ld   de, DummyStr
   add  hl, de          ; HL Points To DummyStr

   push hl              ; start of DummyStr

   ld   b, 8            ; Zero Out DummyStr

FillLoop:
   inc hl
   ld  a,0
   ld  (hl), a
   djnz FillLoop

   pop hl

GSLoop:

   push hl

   ld a, 'Ú'
   ROM_CALL(TX_CHARPUT)
   ld hl, (TEXT_X)
   dec hl
   ld (TEXT_X), hl
   pop hl


   CALL_(GetLetter)
   cp 0
   jr z, HopOut

   cp K_EXIT
   jr z, HopOut

   ld (hl),a

   inc b
   inc hl

   ld a, b      ; Check If 8 Chars entered
   cp 8
   jr nz, GSLoop

HopOut:

   ld  a, 0
   ld  (hl),a   ;  Set to Null

   ret

;+----
;| Check if DummyStr=PWStr
;+----
CheckPW:
   ld   hl, (PROGRAM_ADDR)
   ld   de, DummyStr
   add hl, de
   ex  de, hl           ; DE Points To DummyStr


   ld  hl, (PROGRAM_ADDR)
   ld  bc, PWStr
   add hl, bc           ; HL Points To PWStr

CheckLoop:

   ld a, (hl)           ; HL to PWStr
   ld b, a              ; DE to DummyStr
   ex de, hl            ;  Switch

   ld a,(hl)            ; HL to DummyStr
   ex de, hl            ; DE Points to PWStr

   cp b
   jr nz, NotEqual

Equal:                  ; DE[n] = HL[n]

   inc de               ; increase pointers
   inc hl


   cp 0                 ; If Zero Return 0
   jr nz, CheckLoop     ; A = 0
                        ; EOS
   ld b,0
   jr BaBoom

NotEqual:

   ld b, 1              ; If Not = Then Return 1

BaBoom:

   ld a,b               ; ret b as acc
   ret

;+-------
;| Get One Letter & Translate
;| This routine and LetterTable from Magnus Hagander's Texanoid Game
;+-------
GetLetter:
   push hl
   push bc
   ld   hl,(PROGRAM_ADDR)
   ld   de,LetterTable-1 ;Point to one before, since we always inc once
   add  hl,de                   ;HL now points right

ConvertLoop:
   push hl
   CALL Get_Key                 ;ACC holds key
   pop  hl

   cp   K_EXIT                  ;temp
   jr   z, Shazam

   cp   0
   jr   z,ConvertLoop

   push hl                      ;save away...
   ld   b,a
   ld   c,0

ConversionLoop:
   inc  hl
   djnz ConversionLoop          ;After this, we have the correct offset...
   ld   a,(HL)
   pop  hl
   cp   255
   jr   z,ConvertLoop           ;Invalid key

   ROM_CALL(TX_CHARPUT)         ;Show the char

Shazam:

   pop  bc
   pop  hl

   ret                          ;Value is in acc


;+-------
;|  Stuff That's Useful
;+-------
InfoStr:
       ;123456789012345678901 ;
   .db "  Password  Protect  "
   .db "  Digital Dreamland  "
   .db " Christopher  Bowron "
   .db 0                       ; End String

MenuStr:
   	   ;123456789012345678901
   .db " DDL Password Protect"
   .db "      Ver 1.24       "
   .db "1. Shut Down         "
   .db "2. Change Password   "
   .db "3. Quit              "
   .db 0

NewStr:
   .db "New ",0
CurrentStr:
   .db "Current ",0
PromptStr:
   .db "Password:",0

PWStr: ;1234567
   .db 'B','O','O',0,0,0,0,0,0        ; Allow for 8 chars + Null Byte

DummyStr:
   .db 0,0,0,0,0,0,0,0,0        ; Temp Work Space

YesNoStr:
	   ;123456789012345678901
   .db "^Is This Correct?    "
   .db "1. Yes               "
   .db "2. No                "
   .db 0

ChangeStr:
   .db "Password Changed",0

NoChangeStr:
   .db "Password Not Changed",0


WrongPWStr:
   .db "Incorrect PW!",0

CorrectPWStr:
       ;123456789012345678901
   .db " Thank You For Using " ;1
   .db "    DDL Products     " ;2
   .db "    DDL MCMXCVI      " ;3
   .db "                     " ;4
   .db "  [Share And Enjoy]  " ;5
   .db "ai150@               " ;6
   .db "detroit.freenet.org  " ;7
   .db 0

LetterTable:                                ; For converting keys into letters
   .db 255,255,255,255
   .db 255,255,255,255
   .db 000,'X','T','O'
   .db 'J','E',255,255
   .db ' ','W','S','N'
   .db 'I','D',255,255
   .db 'Z','V','R','M'
   .db 'H','C',255,255
   .db 'Y','U','Q','L'
   .db 'G','B',255,255
   .db 255,255,'P','K'
   .db 'F','A',255,255
   .db 255,255,255,255
   .db 255,255,255,255

.end
