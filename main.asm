    output "moonr.com"
    org 100h
    jp start
    include "vdp/driver.asm"
    include "utils/index.asm"
    include "gopher/render/index.asm"
    include "dos/msxdos.asm"
    include "gopher/engine/history/index.asm"
    include "gopher/engine/urlencoder.asm"
    include "gopher/engine/fetcher.asm"
    include "gopher/engine/media-processor.asm"
    include "unapi/unapi.asm"
    include "unapi/tcp.asm"
    include "gopher/gopher.asm"
    include "player/vortex-processor.asm"
fontName db "font.bin",0
start:  
    call TcpIP.init : jp nc, noTcpIP ; No TCP/IP - no browser! Anyway you can use "useless tcp/ip driver"
    ; Loading font
    ld de, fontName, a, FMODE_NO_WRITE : call Dos.fopen
    push bc
        ld de, font, hl, 2048 :call Dos.fread
    pop bc
    call Dos.fclose

    call TextMode.init
    call History.home
    jp exit
noTcpIP:
    ld hl, .err
    call Console.putStringZ
    rst 0
.err db 13,10,"No TCP/IP implementation found!",13,10,0

outputBuffer:
font:


    display "ENDS: ", $
    display "Buff size", #c000 - $