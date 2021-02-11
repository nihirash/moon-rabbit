    MODULE VortexProcessor
play:
    call Console.peekC : and a
    jr nz, play

    ld hl, message : call DialogBox.msgNoWait

    ld hl, outputBuffer  : call VTPL.INIT
.loop
    halt : di : call VTPL.PLAY : ei
    call Console.peekC : and a : jp nz, .stop
    jr nc, .loop 
.stop
    call VTPL.MUTE
.wlp
    call Console.peekC : and a
    jr nz, .wlp
    ret

message db "Press key to stop...", 0
    ENDMODULE
    include "player.asm"