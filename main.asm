    LIST    P = 16F877A
    INCLUDE <p16f877a.inc>
    INCLUDE <DEV_FAM.INC>	; PIC16 device specific definitions
	INCLUDE <MATH16.INC>    ; PIC16 math library definitions


    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

    ORG     H'0000'
        goto    START

    CBLOCK  H'7A'
        byte1
        byte2
        byte3
        byteW
    ENDC

EEWRITE
        banksel EEDATA
        movwf   EEDATA
        banksel EECON1
        bcf     EECON1, EEPGD
        bsf     EECON1, WREN
;Required Sequence
        bcf     INTCON, GIE
        movlw   0x55
        movwf   EECON2
        movlw   0xAA
        movwf   EECON2
        bsf     EECON1, WR
        bsf     INTCON, GIE
WAIT1   btfsc   EECON1,WR
        goto    WAIT1
        bcf     EECON1, WREN
        banksel PIR2
        bcf     PIR2, EEIF
        banksel EEADR
        incf    EEADR
        return

TXPOLL
    banksel     PIR1
    btfss       PIR1,TXIF
    goto        TXPOLL
    banksel     TXREG
    movwf       TXREG
    return

TXPOLL_DUMMY
    banksel     PIR1
    btfss       PIR1,TXIF
    goto        TXPOLL

RXPOLL
    banksel     PIR1
    btfss       PIR1,RCIF
    goto        RXPOLL
    banksel     RCREG
    movfw       RCREG
    return

start_i2c         MACRO              ;[S]
     banksel     PIR1                                     ;bank0 (bank0? names) be sure
     bcf         PIR1,SSPIF
     banksel     SSPCON2                                    ;bank1
     bsf         SSPCON2,SEN     ;send i2c START [S] bit
     banksel     PIR1                                 ;bank0
     btfss       PIR1,SSPIF         ;start bit cycle complete?
     goto        $-1
       endm


repeated_start_i2c     MACRO
     banksel        SSPCON2                                   ;bank1
     bsf            SSPCON2,RCEN     ;enable receiving at master 16f877
       endm

stop_i2c         MACRO                  ;[P]
     banksel    PIR1                                           ;bank0
     bcf        PIR1,SSPIF
     banksel    SSPCON2                                     ;bank1
     bsf        SSPCON2,PEN         ;send i2c STOP [P] bit
     banksel    PIR1                                           ;bank0
     btfsS      PIR1,SSPIF             ;stop bit cycle completed?
     goto         $-1
           endm

wait_for_ack_i2c         MACRO
     banksel        PIR1                     ;bank0
     bcf            PIR1,SSPIF
     btfsS          PIR1,SSPIF                 ;ACK received?
     goto         $-1
       endm

read_data_i2c MACRO
    banksel     SSPBUF
    movfw       SSPBUF
        endm

read_data_i2cA MACRO
        ;banksel     SSPCON2
        ;bsf         SSPCON2,RCEN
        banksel     PIR1
    LOCAL RWaitA
        btfss       PIR1,SSPIF
        goto        RWaitA
        bcf         PIR1,SSPIF
        banksel     SSPBUF
        movfw       SSPBUF
        endm

send_read_ack_i2c MACRO
    banksel     SSPCON2
    bcf         SSPCON2,ACKDT
    bsf         SSPCON2,ACKEN
    btfsc       SSPCON2,ACKEN
    goto        $-1
    bsf         SSPCON2,RCEN
        endm

send_read_nack_i2c MACRO
    banksel     SSPCON2
    bsf         SSPCON2,ACKDT
    bsf         SSPCON2,ACKEN
    btfsc       SSPCON2,ACKEN
    goto        $-1
    ;bsf         SSPCON2,RCEN
        endm

swap_bibbles MACRO
    banksel     byte2

    swapf       byte3,1
    movfw       byte2
    movwf       byteW
    swapf       byteW,1
    movfw       byteW
    andlw       0xF0
    iorwf       byte3,1
    swapf       byte2,1
    movlw       0x0F
    andwf       byte2,1
        endm

send_address_and_register
    start_i2c
    banksel     SSPBUF
    movlw       b'10010000'
    movwf       SSPBUF
    wait_for_ack_i2c
    banksel     SSPBUF
    movlw       b'00000001'   ; last two bits indicate register to read 0 0 -> t reg 0 1 -> conf reg
    movwf       SSPBUF
    wait_for_ack_i2c
    stop_i2c

    start_i2c
    banksel     SSPBUF
    movlw       b'10010001'
    movwf       SSPBUF
    wait_for_ack_i2c
    repeated_start_i2c

    read_data_i2cA
    send_read_ack_i2c

    call        TXPOLL
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    banksel     byte1
    movwf       byte1

    read_data_i2cA
    send_read_ack_i2c

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    call        TXPOLL
    banksel     byte2
    movwf       byte2

    banksel     SSPBUF
    movfw       SSPBUF

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    call        TXPOLL
    banksel     byte3
    movwf       byte3

    stop_i2c

    swap_bibbles

    banksel     byte1
    movfw       byte2
    call        TXPOLL
    movfw       byte3
    call        TXPOLL
        return



MAIN_PROG CODE                      ; let linker place main program
START

     banksel OPTION_REG
     movlw   B'11010111'
     movwf   OPTION_REG
     banksel PORTB
     clrf    PORTB
     banksel TRISB
     movlw   B'00000000'
     movwf   TRISB
     banksel PORTA
     clrf    PORTA
     banksel TRISA
     movlw   B'00000000'
     movwf   PORTA

     ;i2c setup
    movlw       b'00101000'
    banksel     SSPCON
    movwf       SSPCON

    movlw       D'9'
    banksel     SSPADD
    movwf       SSPADD

    movlw       b'10000000'
    banksel     SSPSTAT
    movwf       SSPSTAT

    movlw       b'11011000'   ;usart and i2c set
    banksel     TRISC
    movwf       TRISC

    ;serial setup
    banksel     SPBRG
    movlw       D'25'
    movwf       SPBRG

    banksel     TXSTA
    movlw       b'00100100'
    movwf       TXSTA

    banksel     RCSTA
    movlw       b'10010000'
    movwf       RCSTA

    ;begin

    movlw   h'AA'
    call    TXPOLL
    movlw   h'BB'
    call    TXPOLL
    movlw   h'CC'
    call    TXPOLL
    movlw   h'DD'
    call    TXPOLL
    movlw   h'EE'
    call    TXPOLL
    movlw   h'FF'
    call    TXPOLL

    movlw   h'AA'
    call    TXPOLL
    movlw   h'BB'
    call    TXPOLL
    movlw   h'CC'
    call    TXPOLL
    movlw   h'DD'
    call    TXPOLL
    movlw   h'EE'
    call    TXPOLL
    movlw   h'FF'
    call    TXPOLL

    movlw   0x06
    movwf   AARGB0
    movlw   0x0A
    movwf   AARGB1
    call    FLO1624

    movfw   AEXP
    call    TXPOLL
    movfw   AARGB0
    call    TXPOLL
    movfw   AARGB1
    call    TXPOLL

    movlw   0x7B
    movwf   BEXP
    movlw   0x00
    movwf   BARGB0
    movwf   BARGB1

    call    FPM24
    call    TXPOLL

    movfw   AEXP
    call    TXPOLL
    movfw   AARGB0
    call    TXPOLL
    movfw   AARGB1
    call    TXPOLL

    banksel     PORTA
    movlw       b'00000001'
    movwf       PORTA
    banksel     PORTB
    movlw       b'00000111'
    movwf       PORTB

    banksel     byte1
    movlw       b'11111111'
    movwf       byte1
    movwf       byte2
    movwf       byte3

    movfw       byte1
    call        TXPOLL
    movfw       byte2
    call        TXPOLL
    movfw       byte3
    call        TXPOLL



    ;call send_address_and_register


led_loop
    clrf        PORTA
    clrf        PORTB
    banksel     PORTA
    movlw       b'00000001'
    movwf       PORTA
    banksel     PORTB
    movlw       b'00000110'
    movwf       PORTB

    clrf        PORTA
    clrf        PORTB
    banksel     PORTA
    movlw       b'00000010'
    movwf       PORTA
    banksel     PORTB
    movlw       b'01011011'
    movwf       PORTB

    clrf        PORTA
    clrf        PORTB
    banksel     PORTA
    movlw       b'00000100'
    movwf       PORTA
    banksel     PORTB
    movlw       b'01001111'
    movwf       PORTB

    clrf        PORTA
    clrf        PORTB
    banksel     PORTA
    movlw       b'00001000'
    movwf       PORTA
    banksel     PORTB
    movlw       b'01100110'
    movwf       PORTB

    call send_address_and_register
    goto        led_loop

    INCLUDE <FP24.A16>

    END

