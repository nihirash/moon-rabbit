    module Console
KEY_UP = 30
KEY_DN = 31
KEY_LT = 29
KEY_RT = 28

newLine:
    ld a, CR
    call putC
    ld a, LF
putC:
    ld e, a 
    ld c, 2
    jp BDOS

getC:
    ld ix, #9f
    jp biosC

peekC:
    ld c, 6, e, #ff
    jp BDOS 

putStringZ:
    ld a, (hl)
    and a
    ret z
    push hl
    call putC
    pop hl
    inc hl
    jr putStringZ

    endmodule