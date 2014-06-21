    LIST    P = 16F877A
    INCLUDE <p16f877a.inc>
    INCLUDE <DEV_FAM.INC>	; PIC16 device specific definitions
	INCLUDE <MATH16.INC>    ; PIC16 math library definitions

    __CONFIG _CP_OFF & _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _LVP_OFF

ZERO    EQU D'0'
ONE     EQU D'1'
TWO     EQU D'2'
THREE   EQU D'3'
FOUR    EQU D'4'
FIVE    EQU D'5'
SIX     EQU D'6'
SEVEN   EQU D'7'
EIGHT   EQU D'8'
NINE    EQU D'9'


    ORG     H'0000'
        goto    START
    ORG     H'0004'
        goto    int_service

    CBLOCK  H'70'
        byte1
        byte2
        byte3
        byteW
        counter
        decimal_place
        digit_one
        digit_two
        digit_three
        digit_four
    ENDC

int_service
    banksel     PORTA
    movlw       b'00000010'
    movwf       PORTA
    banksel     PORTB
    movlw       b'00111111'
    movwf       PORTB

    goto    $
    return


display_one     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'00000110'
    movwf       PORTB
    return

display_two     ;w is 1,2,3 or 4 - the decimal place
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01011011'
    movwf       PORTB
    return

display_three     ;w is 1,2,3 or 4 - the decimal place
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01001111'
    movwf       PORTB
    return

display_four     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01100110'
    movwf       PORTB
    return

display_five     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01101101'
    movwf       PORTB
    return

display_six     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01111101'
    movwf       PORTB
    return

display_seven     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'00000111'
    movwf       PORTB
    return

display_eight     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'01111111'
    movwf       PORTB
    return

display_nine     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'11101111'
    movwf       PORTB
    return

display_zero     ;w is the decimal place in binary
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'00111111'
    movwf       PORTB
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
    movlw       b'00000000'   ; last two bits indicate register to read 0 0 -> t reg 0 1 -> conf reg
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
    banksel     byte1
    movwf       byte1

    read_data_i2cA
    send_read_ack_i2c

    
    nop
    call        TXPOLL
    banksel     byte2
    movwf       byte2

    banksel     SSPBUF
    movfw       SSPBUF

    
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

display
check_one   movfw   REMB1
            sublw   d'1'
            btfsc   STATUS,Z
            goto    one
            goto    check_two
one         movfw   decimal_place
            call    display_one
            goto    end_digits
check_two   movfw   REMB1
            sublw   d'2'
            btfsc   STATUS,Z
            goto    two
            goto    check_three
two         movfw   decimal_place
            call    display_two
            goto    end_digits
check_three movfw   REMB1
            sublw   d'3'
            btfsc   STATUS,Z
            goto    three
            goto    check_four
three       movfw   decimal_place
            call    display_three
check_four  movfw   REMB1
            sublw   d'4'
            btfsc   STATUS,Z
            goto    four
            goto    check_five
four        movfw   decimal_place
            call    display_four
check_five  movfw   REMB1
            sublw   d'5'
            btfsc   STATUS,Z
            goto    five
            goto    check_six
five        movfw   decimal_place
            call    display_five
check_six   movfw   REMB1
            sublw   d'6'
            btfsc   STATUS,Z
            goto    six
            goto    check_seven
six         movfw   decimal_place
            call    display_six
check_seven movfw   REMB1
            sublw   d'7'
            btfsc   STATUS,Z
            goto    seven
            goto    check_eight
seven       movfw   decimal_place
            call    display_seven
check_eight movfw   REMB1
            sublw   d'8'
            btfsc   STATUS,Z
            goto    eight
            goto    check_nine
eight       movfw   decimal_place
            call    display_eight
check_nine  movfw   REMB1
            sublw   d'9'
            btfsc   STATUS,Z
            goto    nine
            goto    check_zero
nine        movfw   decimal_place
            call    display_nine
check_zero  movfw   REMB1
            sublw   d'0'
            btfsc   STATUS,Z
            goto    zero
            goto    end_digits
zero        movfw   decimal_place
            call    display_zero

end_digits
            return

wait
            banksel counter
            movlw   d'20'
            movwf   counter
            banksel TMR0
            clrf    TMR0

wait_again
            bcf     INTCON, 2

wait_loop
            btfss   INTCON, T0IF
            goto    wait_loop

            banksel counter
            decfsz  counter,1
            goto    wait_again
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

main_loop
    call send_address_and_register

    clrf    AEXP
    clrf    AARGB2

    movfw   byte2
    movwf   AARGB0
    movfw   byte3
    movwf   AARGB1
    call    FLO1624

    movfw   AEXP
    call    TXPOLL
    movfw   AARGB0
    call    TXPOLL
    movfw   AARGB1
    call    TXPOLL

    movlw   0x7B    ;0.0625
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

    clrf    BEXP
    clrf    BARGB0
    clrf    BARGB1
    clrf    BARGB2

    ;1000 in microchip format
    ;movlw   0x88
    ;movwf   BEXP
    ;movlw   0x7A
    ;movwf   BARGB0
    ;movlw   0x00
    ;movwf   BARGB1

    ;100 in microchip format
    ;movlw   0x85
    ;movwf   BEXP
    ;movlw   0x48
   ; movwf   BARGB0
    ;movlw   0x00
    ;movwf   BARGB1

    ;10 in microchip format
    movlw   0x82
    movwf   BEXP
    movlw   0x20
    movwf   BARGB0
    movlw   0x00
    movwf   BARGB1

    call    FPM24

    call    INT2424

    movfw   AARGB0
    call    TXPOLL
    movfw   AARGB1
    call    TXPOLL
    movfw   AARGB2
    call    TXPOLL

    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    call    FXD2416U

    movfw   REMB1
    movwf   digit_one
    call    TXPOLL

    movlw   b'00001000'
    banksel decimal_place
    movwf   decimal_place
    pagesel display
    call    display

    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    call    FXD2416U

    movfw   REMB1
    movwf   digit_two
    call    TXPOLL

    movlw   b'00000100'
    banksel decimal_place
    movwf   decimal_place
    pagesel display
    call    display


    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    call    FXD2416U

    movfw   REMB1
    movwf   digit_three
    call    TXPOLL

    movlw   b'00000010'
    banksel decimal_place
    movwf   decimal_place
    pagesel display
    call    display

    pagesel wait
    call    wait

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

    
    goto        main_loop


    INCLUDE <FP24.A16>
    INCLUDE <FXD46.A16>

    END

