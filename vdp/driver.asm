; Colourful pseudo-text code
VDP_DATA_PORT    = #98
VDP_COMMAND_PORT = #99
    module TextMode


    macro vdp_reg reg, value
    di
    ld a, value
    out (VDP_COMMAND_PORT), a
    nop
    ld a, #80 or reg
    ei
    out (VDP_COMMAND_PORT), a
    endm

init:
    call vdpWait
    vdp_reg 1, 48 ; Shutdown screen
    xor a
    ld (#f3dc), a, (#f3dd), a
    vdp_reg 0, 4

    ld hl, #1000 : call vdpSetWrite
    ld bc, 2048 : ld hl, font
.fontLoop
    ld a, (hl)
    out (VDP_DATA_PORT), a
    nop
    inc hl : dec bc
    ld a, b : or c : jr nz, .fontLoop
cls:
    vdp_reg 1, 48 ; Shutdown screen
    ld hl, #0000 : call vdpSetWrite
    ld bc, #90D ; To the end attrs
.loop
    xor a 
    out (VDP_DATA_PORT), a
    nop
    dec bc
    ld a, b : or c : jr nz, .loop
    ld hl, 0, (coords), hl
    vdp_reg 2, 3
    vdp_reg 4, 2
    vdp_reg 7, #F1    ; Color 1
    vdp_reg 12, #F4   ; Color 2
    vdp_reg 13, #f0   ; Flashing using as second color
    ; Set attrs begin to #800
    vdp_reg 3,  #20 or #7  ; A13-A9 bits and 111 for attributes address bus
    vdp_reg 10, #00        ; 00000 and A16-A14 for attributes address bus
    vdp_reg 1, 112 ; Screen 0/Text 2
    ret

; A - line
usualLine:
    push af
    xor a
    ld (fillLineColor.loop + 1), a
    pop af
    jr fillLineColor
; A - line
highlightLine:
    push af
    ld a, #ff
    ld (fillLineColor.loop + 1), a
    pop af
fillLineColor:
    ld h, 0, l, a
    and a : jr z, .skip
    add hl, hl
    ld bc, hl
    add hl, hl
    add hl, hl
    add hl, bc ; x10
.skip
    ld a, h : add #8 : ld h, a
    call vdpSetWrite

    ld b, 10
.loop
    ld a, #ff
    out (VDP_DATA_PORT), a
    nop
    djnz .loop
    ret

printZ:
    ld a, (hl) : and a : ret z
    push hl
    call putC
    pop hl
    inc hl
    jr printZ


; A - char
putC:
    cp 13 : jr z, .nl
    push af
    ld de, (coords)
    call xyToAddr
    call vdpSetWrite
    pop af
    out (VDP_DATA_PORT), a
    ld a, (coords)
    inc a
    cp 80 : jr nz, .write
.nl
    ld hl, coords + 1
    inc (hl)
    xor a
.write 
    ld (coords), a
    ret

fillLine:
    ld l, h, h, 0
    dup 4
    add hl, hl
    edup
    push bc
    ld bc, hl
    add hl,hl 
    add hl,hl
    add hl, bc
    ex af, af'
    call vdpSetWrite
    ex af, af'
    ld b, 80
.loop
    out (VDP_DATA_PORT), a
    nop 
    djnz .loop
    pop bc
    ret

; DE - coord(E - X, D - Y)
xyToAddr:
    ld h, 0, l, d
    dup 4
    add hl, hl
    edup
    push bc
    ld bc, hl
    add hl,hl 
    add hl,hl
    add hl, bc
    ld d, 0
    add hl, de
    pop bc
    ret

vdpWait:
    vdp_reg 15, 2
    di
    in a, (VDP_COMMAND_PORT)
    rrca
    vdp_reg 15, 0
    ei
    jr c, vdpWait

    ret

;
; Set VDP address counter to write from address AHL (17-bit)
; Enables the interrupts
;
vdpSetWrite:
    di
    ld a, l : out (VDP_COMMAND_PORT), a
    nop : nop
    ld a, h : or #40 : out (VDP_COMMAND_PORT), a
    nop
    ei
    ret

vdpSetRead:
    ld a, l : out (VDP_COMMAND_PORT), a
    nop
    ld a, h  : out (VDP_COMMAND_PORT), a
    ret

gotoXY:
    ld (coords), de
    ret

coords dw 0

    endmodule

exit:
    vdp_reg 1, 48 ; Shutdown screen
    ld c, 0
    or a : ld ix, #0185
	call callSub
    rst 0