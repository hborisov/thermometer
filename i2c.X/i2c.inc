;;-------start i2c procedures -------------;;

CODE

i2c_open_port
    movlw       b'10000000'
    banksel     SSPSTAT
    movwf       SSPSTAT

    movlw       b'00101000'
    banksel     SSPCON
    movwf       SSPCON

    movlw       0x09
    banksel     SSPADD
    movwf       SSPADD

    movlw       b'00011000'   ;usart and i2c set
    banksel     TRISC
    movwf       TRISC
    banksel     PORTC
    bsf         PORTC,3
    bsf         PORTC,4

    return


i2c_wait_for_idle

    banksel SSPCON2
    btfsc   SSPCON2,ACKEN
    goto    $-1
    btfsc   SSPCON2,RCEN
    goto    $-3
    btfsc   SSPCON2,PEN
    goto    $-5
    btfsc   SSPCON2,RSEN
    goto    $-7
    btfsc   SSPCON2,SEN
    goto    $-9

    return


i2c_start
    banksel     SSPCON2
    bsf         SSPCON2,SEN
    btfsc       SSPCON2,SEN
    goto        $-1

    banksel PIR1
    bcf     PIR1,SSPIF

    return

i2c_restart

    banksel     SSPCON2
    bsf         SSPCON2,RSEN
    btfsc       SSPCON2,RSEN
    goto        $-1

    return

i2c_stop

    banksel    PIR1
    bcf        PIR1,SSPIF
    banksel    SSPCON2
    bsf        SSPCON2,PEN
    banksel    PIR1
    btfss      PIR1,SSPIF
    goto       $-1

    return

; sends a byte, waits for ack
; the byte to be send must be placed in w before invocation
i2c_send_byte_wait_for_ack
    banksel     SSPBUF
    movwf       SSPBUF

    banksel     PIR1
    bcf         PIR1,SSPIF
    btfss       PIR1,SSPIF
    goto        $-1
    bcf         PIR1,SSPIF

    banksel     SSPCON2
    btfsc       SSPCON2, ACKSTAT
    goto        $-1

    return

; will turn master into receiver so it will start receiving bytes immediately
; byte is placed in i2c_buffer
i2c_receive_byte

    bsf         SSPCON2, RCEN
    btfsc       SSPCON2, RCEN
    goto $-1

    banksel PIR1
    btfss   PIR1,SSPIF
    goto    $-1
    bcf     PIR1,SSPIF


    banksel SSPBUF
    movfw   SSPBUF
    banksel i2c_buffer
    movwf   i2c_buffer

    return

i2c_send_acknowledge
    banksel     SSPCON2
    bcf         SSPCON2, ACKDT
    bsf         SSPCON2, ACKEN
    btfsc       SSPCON2, ACKEN
    goto        $-1

    banksel PIR1
    bcf     PIR1,SSPIF
    return

i2c_send_not_acknowledge
    banksel     SSPCON2
    bsf         SSPCON2, ACKDT
    bsf         SSPCON2, ACKEN
    btfsc       SSPCON2, ACKEN
    goto        $-1

    banksel PIR1
    bcf     PIR1,SSPIF
    return


;;-------end i2c procedures -------------;;


