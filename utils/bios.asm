CALSLT  EQU    0x001C
NMI     EQU    0x0066
EXTROM  EQU    0x015f
EXPTBL  EQU    0xfcc1
H_NMI   EQU    0xfdd6

biosC:				
	LD	IY,($FCC0)
	JP	$001C

callSub:  
		 exx
         ex     af,af'       ; store all registers
         ld     hl,EXTROM
         push   hl
         ld     hl,0xC300
         push   hl           ; push NOP ; JP EXTROM
         push   ix
         ld     hl,0x21DD
         push   hl           ; push LD IX,<entry>
         ld     hl,0x3333
         push   hl           ; push INC SP; INC SP
         ld     hl,0
         add    hl,sp        ; HL = offset of routine
         ld     a,0xC3
         ld     (H_NMI),a
         ld     (H_NMI+1),hl ; JP <routine> in NMI hook
         ex     af,af'
         exx                 ; restore all registers
         ld     ix,NMI
         ld     iy,(EXPTBL-1)
         call   CALSLT       ; call NMI-hook via NMI entry in ROMBIOS
                             ; NMI-hook will call SUBROM
         exx
         ex     af,af'       ; store all returned registers
         ld     hl,10
         add    hl,sp
         ld     sp,hl        ; remove routine from stack
         ex     af,af'
         exx                 ; restore all returned registers
         ret