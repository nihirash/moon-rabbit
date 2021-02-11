;;; TPA SAFE TcpIP operations
    module TcpIP
START_RESOLVE = 6
GET_DNS_RESULT = 7
TCP_WAIT = 29

OPEN_TCP = 13
CLOSE_TCP = 14
ABORT_TCP = 15
STATE_TCP = 16
SEND_TCP = 17
RECV_TCP = 18

; C - init successful
; Closes all connections
init:
    call UnApi.preinit
    ld hl, api 
    call UnApi.initApi
    ret nc ; If error
    call closeAll
    scf
    ret
    

; HL - domain string
; C - success flag
; L.H.E.D. - IP addr(if no error)
resolveIp:
    ld de, dnsbuff
.loop
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    and a 
    jr nz, .loop
    ld (de), a
    
    ld hl, dnsbuff
    ld a, START_RESOLVE
    ld b, 0
    call UnApi.tpaUnApiCall

    ld a, TCP_WAIT
    call UnApi.tpaUnApiCall
.resolveLoop
    ld a, GET_DNS_RESULT
    ld b, 1
    call UnApi.tpaUnApiCall
    and a  : jp nz, .err
    ld a, b
    cp 2 : jr nz, .resolveLoop
.fin
    scf
    ret
.err
    or a
    ret

; L.H.E.D - IP addr
; BC - port
; Output:
; NZ - error flag
; A - error code
; B - socket id
openTcp:
    ld (.ip), hl 
    ld (.ip + 2), de
    ld (.port), bc
    ld hl, .buff
    ld a, OPEN_TCP
    call UnApi.tpaUnApiCall
    and a : ret nz

    ld a, b
    ld (.socket), a
.establishWait
    call TcpIP.wait

    ld a, (.socket)
    ld b, a
    call TcpIP.stateTcp

    and a 
    ret nz

    ld a, b
    cp 4 
    jr nz, .establishWait
    
    ld a, (.socket)
    ld b, a
    xor a
    ret
.buff
.ip        ds 4
.port      dw 0
.localPort dw #ffff
.timeout   dw 0
.flags     db 0
.socket    db 0

; A - socket
; Output:
; B - connection state
; HL - bytes avail
; IX - free bytes in output buffer
stateTcp:
    ld b, a
    ld hl, 0
    ld a, STATE_TCP
    jp UnApi.tpaUnApiCall
    

; A - socket
; DE - buffer
; HL - data len 
sendTCP:
    push hl
    ld bc, hl
    ex hl, de
    ld de, tcpBuff
    ldir
    pop hl
    ld b, a
    ld de, tcpBuff
    ld c, 0
    ld a, TcpIP.SEND_TCP
    jp UnApi.tpaUnApiCall

; A - socket
; HL - data len
; BC - actually received
recvTCP:
    ld b, a

; 512 Bytes buffer limit
    ld a, h 
    and a  
    jr z, .skip
    ld a, 1
.skip
    ld h, a

    ld a, RECV_TCP
    ld de, tcpBuff
    jp UnApi.tpaUnApiCall


; A - socket id
closeTcp:
    ld b, a
    ld a, CLOSE_TCP
    jp UnApi.tpaUnApiCall


closeAll:
    ld a, CLOSE_TCP
    ld b, 0
    call UnApi.tpaUnApiCall
wait:
    ld a, TCP_WAIT
    jp UnApi.tpaUnApiCall

dnsbuff ds 64
tcpBuff ds 512

api  db "TCP/IP", 0
    endmodule