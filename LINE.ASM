From list-zshell-owner@kuai.se  Mon Jan 29 13:36:48 1996
Return-Path: list-zshell-owner@kuai.se
Received: from tao.kuai.se (root@tao.kuai.se [193.45.137.18]) by detroit.freenet.org (8.6.10/869.2) with ESMTP id NAA07846; Mon, 29 Jan 1996 13:36:23 -0500
Received: (from root@localhost) by tao.kuai.se (8.6.12/8.6.9) id PAA26920 for list-zshell-outgoing; Mon, 29 Jan 1996 15:44:25 +0100
From: Stephane Jantzen <Stephane.Jantzen@scinfo.u-nancy.fr>
Message-Id: <199601291458.PAA10458@pollux.scinfo.u-nancy.fr>
Subject: LZ: Graphical routines : sources
To: list-zshell@kuai.se
Date: Mon, 29 Jan 1996 15:58:43 +0100 (MET)
In-Reply-To: <01BAEDB0.F7661780@ppp-6.kajen.com> from "Oskar Liljeblad" at Jan 28, 96 06:46:02 pm
X-Mailer: ELM [version 2.4 PL25]
Content-Type: text
Sender: owner-list-zshell@kuai.se
Precedence: bulk
Reply-To: list-zshell@kuai.se

This message comes from the List-ZShell mailing list:

Hi !

Here are the sources for line and circle, implemented using Bresenham's algo-
rithms. Thanx to Christophe Bouron, who gave me the final optimisation. The 
latest versions of Line and Circle haven't been extensively tested, so they 
might hide bugs, but this is quite unprobable.

Just notice that huge objects (e.g. long lines or big circles) cannot be perfor-
med properly. This is not a bug, but a limitation of the speed and size optimi-
zation. The final sizes for Line and Circle are now 108 and 116 bytes. Do you
think it is not short enough yet ?

;------------------------------
; Bresenham's line algorithm 
; by Stephane JANTZEN
; Stephane.Jantzen@scinfo.u-nancy.fr
;
; first release : 07/15/95
; last modified : 01/29/96
;------------------------------
;
; Optimized implementation of 
; Bresenham's line algorithm
;
; * parameters : 
;    - HL : coordinates of the 1st point
;    - DE : coordinates of the 2nd point
;
; * code size : 108 bytes
;
; Thanx to Christophe Bouron for having helped me optimizing this more.
;

#include "ti-85.h"

        .org    $00
        .db     "Line",0

Flag    =$80DF
Way     =$80E0

Start:                          ;test routine
        ld      A,$04
        out     ($05),A
        ROM_CALL(CLEARLCD)
        ld      H,$00
        ld      L,$0A
        ld      D,$2f
        ld      E,$00
        CALL_(Line)
        CALL_(Wait)
        ret

Line:                           ;beginning of the line routine
        push    DE
        push    HL

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
        ex	DE,HL
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
        pop     HL
        pop     DE
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

Wait:
        call    GET_KEY
        or      A
        jr      Z,Wait
        ret

        .end


;------------------------------
; Bresenham's circle algorithm 
; by Stephane JANTZEN
; Stephane.Jantzen@scinfo.u-nancy.fr
;
; first release : 07/15/95
; last modified : 01/29/96
;------------------------------
;
; Optimized implementation of
; Bresenham's circle algorithm
;
; * parameters : 
;    - D : x coordinate of center
;    - E : y coordinate of center
;    - B : radius - allow djnz's              
;
; * code size : 116 bytes
;

#include "ti-85.h"

        .org    0
        .db     "Circle",0
 
;------------------------------
; test procedure
;------------------------------

Start:                          
        ld      A,4
        out     (5),A
        ROM_CALL(CLEARLCD)
        ld      DE,$4020                ;coordinates of center
        ld      B,$15                   ;radius
LoopE:
        CALL_(Circle)
        djnz    LoopE
Wait:
        call    GET_KEY
        or      A
        ret     NZ
        jr      Wait

;------------------------------
; beginning of circle
;------------------------------
 
Circle:                         
        push    BC              ;can be removed
        push    DE              ;can be removed              
        ld      H,0
        ld      L,B
        rlc     B
        ld      A,$03
        sub     B
        push    AF
Loop:
        ld      A,D             ;Point #1
        add     A,H
        ld      B,A
        ld      A,E
        add     A,L
        ld      C,A
        CALL_(PointOn)
        
        ld      A,E             ;Point #2
        sub     L
        ld      C,A
        CALL_(PointOn)
        
        ld      A,D             ;Point #4
        sub     H
        ld      B,A
        CALL_(PointOn)
        
        ld      A,E             ;Point #3
        add     A,L
        ld      C,A
        CALL_(PointOn)
        
        ld      A,D             ;Point #5
        add     A,L
        ld      B,A
        ld      A,E
        add     A,H
        ld      C,A
        CALL_(PointOn)
        
        ld      A,E             ;Point #6
        sub     H
        ld      C,A
        CALL_(PointOn)
        
        ld      A,D             ;Point #8
        sub     L
        ld      B,A
        CALL_(PointOn)
        
        ld      A,E             ;Point #7
        add     A,H
        ld      C,A
        CALL_(PointOn)
        
        ld      A,H             ;is the circle finished ?
        sub     L
        jr      NC,EndCircle     ;yes
        pop     AF
        ld      B,A
        ld      A,H
        bit     7,B
        jr      Z,Pos
Neg:                            ;case d<0
        rla
        rla
        add     A,B
        add     A,$06
        push    AF
        jr      EndC
Pos:                            ;case d>=0
        sub     L
        rla
        rla
        add     A,B
        add     A,$0A
        push    AF
        dec     L
EndC:                           ;one loop has been performed
        inc     H
        jr      Loop            
EndCircle:
        pop     AF              ;MUST NOT BE REMOVED
        pop     DE              ;can be removed
        pop     BC              ;can be removed
        ret

;------------------------------
; End of circle
;------------------------------

PointOn:
        push    HL              ;MUST NOT BE REMOVED
        push    DE              ;MUST NOT BE REMOVED
        ROM_CALL(FIND_PIXEL)
        ld      DE,$FC00
        add     HL,DE
        or      (HL)
        ld      (HL),A
        pop     DE              ;MUST NOT BE REMOVED
        pop     HL              ;MUST NOT BE REMOVED
        ret

        .end

-- 
-------------------------------------------------------------------------------
             Stephane JANTZEN - Stephane.Jantzen@scinfo.u-nancy.fr
    French Student in Computer Engineering School looking for a placement in 
                     <<< MINNESOTA >>>. Just mail me !
-------------------------------------------------------------------------------

