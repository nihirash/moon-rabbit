    module UnApi
EXTBIOS = #FFCA
TPASLOT1 = #F342
MAPPER = #0402
ARG = #F847
DISCOVER = #2222
ENABLE_SLOT = #0024
TPA_SLOT_1 = #F342

preinit:
    ld de, MAPPER
    xor a
    call EXTBIOS
    or a
    jr z, .noMapper
    
    ld bc, 30 ; skip all_segs mapper
    add hl, bc
    ld de, put_p1 ; replace direct routines
    ld c, 6
    ldir

    call get_p1
    ld (tpa_seg_1), a
    or a
    ret
.noMapper
    scf
    ret

; HL - string to implementation
initApi:
    ld de, ARG
    ld bc, 15
    ldir
.copied
    xor a
    ld (de), a
    ld b, a
    ld de, DISCOVER
    call EXTBIOS
    ld a, b 
    or a
    ld (.num + 1), a
    ret z
    
    ld a, 1 ; First implementation
    ld de, DISCOVER
    call EXTBIOS

    ld (unapiCall + 1), hl ; Store address
    ld c, a
    ld a, h
    cp #c0
    ld a, c
    jr c, .noP3
    
    ld a, #c9
    ld (setUnApi), a
    jr .okSet
.noP3
    ld (unApiSlot + 1), a
    ld a, b
    cp #ff
    jr nz, .noRom

    ld a, #c9
    ld (unApiSeg), a
    jr .okSet
.noRom
    ld (unApiSeg + 1), a
.okSet
    scf
.num
    ld a, 0
    ret

setUnApi:
    ld a, (unapi_is_set)
    or a 
    ret nz
    dec a
    ld (unapi_is_set), a
unApiSlot:
    ld a, 0
    ld h, #40
    call ENABLE_SLOT
unApiSeg
    ld a, 0
    jp put_p1

callUnApi:
    ex af, af'
    exx
    call setUnApi
    ei
    ex af, af'
    exx
unapiCall:
    jp 0

tpaUnApiCall:
    call callUnApi
exit:
    push af, bc, de, hl
    xor a 
    ld (unapi_is_set), a
    ld a, (TPA_SLOT_1)
    ld h, #40
    call ENABLE_SLOT
    ld a, (tpa_seg_1)
    call put_p1
    pop hl, de, bc, af
    ret 

put_p1:
    out (#fe), a
    ret
get_p1:
    in a, (#fe)
    ret

tpa_seg_1 db 0
unapi_is_set db 0
    endmodule