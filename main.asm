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
        current_digit
        indication_counter
        w_temp
        status_temp
        pclath_temp
    ENDC

    CBLOCK  h'20'
    d1
    d2
    d3
    ENDC

    ORG     H'0000'
        pagesel START
        goto    START
    ORG     H'0004'
        pagesel int_service
        goto    int_service

    
int_service
    movwf       w_temp
    swapf       STATUS,W
    movwf       status_temp
    movf        PCLATH,w	;save PCLath
    movwf       pclath_temp
    clrf        PCLATH	;assume that this ISR is in page 0

    btfss       PIR1,TMR1IF
    goto        exit_interrupt

    ;pagesel     delay_malko
    ;call        delay_malko
    
    pagesel     open_i2c
    call        open_i2c
    ;--------------------------------------
    pagesel     send_receive_display
    call        send_receive_display
    pagesel     send_real_data
    call        send_real_data
    ;--------------------------------------

    pagesel     delay_one_sec
    call        delay_one_sec
    
exit_interrupt
    movf        pclath_temp,w
    movwf       PCLATH
    swapf       status_temp,w
    movwf       STATUS
    swapf       w_temp,f
    swapf       w_temp,w

    banksel     PIR1
    bcf         PIR1,TMR1IF
    retfie


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

delay_malko
    movlw   0x0f
    banksel d1
    movwf   d1
    pagesel lp1
lp1
    decfsz  d1
    goto    lp1
    return

delay_one_sec
    movlw	0x07
    banksel d1
	movwf	d1
	movlw	0x2F
	movwf	d2
	movlw	0x03
	movwf	d3
Delay_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	Delay_0

			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1
    return

DUMMY
    banksel     PIR1
    btfss       PIR1,TXIF
    goto        DUMMY
    nop
    nop
    nop
    nop
    nop
    nop
    return

TXPOLL
    banksel     PIR1
    btfss       PIR1,TXIF
    goto        TXPOLL
    banksel     TXREG
    movwf       TXREG
    return

RXPOLL
    banksel     PIR1
    btfss       PIR1,TXIF
    goto        TXPOLL
    banksel     PIR1
    btfss       PIR1,RCIF
    goto        RXPOLL
    banksel     RCREG
    movfw       RCREG
    return

open_i2c
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
    return

start_i2c         MACRO              ;[S]
    LOCAL start_bit_completed
                     banksel     PIR1                                     ;bank0 (bank0? names) be sure
                     bcf         PIR1,SSPIF
                     banksel     SSPCON2                                    ;bank1
                     bsf         SSPCON2,SEN     ;send i2c START [S] bit
                     banksel     PIR1                                 ;bank0
start_bit_completed  btfss       PIR1,SSPIF         ;start bit cycle complete?
                     goto        start_bit_completed
                    endm


repeated_start_i2c     MACRO
     banksel        SSPCON2                                   ;bank1
     bsf            SSPCON2,RCEN     ;enable receiving at master 16f877
       endm

stop_i2c         MACRO                  ;[P]
    LOCAL   stop_bit_completed
                    banksel    PIR1                                           ;bank0
                    bcf        PIR1,SSPIF
                    banksel    SSPCON2                                     ;bank1
                    bsf        SSPCON2,PEN         ;send i2c STOP [P] bit
                    banksel    PIR1                                           ;bank0
stop_bit_completed  btfss      PIR1,SSPIF             ;stop bit cycle completed?
                    goto       stop_bit_completed
   endm

wait_for_ack_i2c         MACRO
    LOCAL   ack_bit_received
                    banksel        PIR1                     ;bank0
                    bcf            PIR1,SSPIF
ack_bit_received    btfss          PIR1,SSPIF                 ;ACK received?
                    goto           ack_bit_received
   endm

read_data_i2c MACRO
    banksel     SSPBUF
    movfw       SSPBUF
        endm

read_data_i2cA MACRO
    LOCAL RWaitA
        ;banksel     SSPCON2
        ;bsf         SSPCON2,RCEN
        banksel     PIR1
RWaitA  nop
        pagesel     RWaitA
        btfss       PIR1,SSPIF
        goto        RWaitA
        bcf         PIR1,SSPIF
        banksel     SSPBUF
        movfw       SSPBUF
        endm

send_read_ack_i2c MACRO
    LOCAL   ack_bit_sent
                banksel     SSPCON2
                bcf         SSPCON2,ACKDT
                bsf         SSPCON2,ACKEN
ack_bit_sent    btfsc       SSPCON2,ACKEN
                goto        ack_bit_sent
                bsf         SSPCON2,RCEN
    endm

send_read_nack_i2c MACRO
    LOCAL   nack_bit_sent
                banksel     SSPCON2
                bsf         SSPCON2,ACKDT
                bsf         SSPCON2,ACKEN
nack_bit_sent   btfsc       SSPCON2,ACKEN
                goto        nack_bit_sent
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
    ;start_i2c
    LOCAL start_bit_completed
                     banksel     PIR1                                     ;bank0 (bank0? names) be sure
                     bcf         PIR1,SSPIF
                     banksel     SSPCON2                                    ;bank1
                     bsf         SSPCON2,SEN     ;send i2c START [S] bit
                     banksel     PIR1                                 ;bank0
start_bit_completed  btfss       PIR1,SSPIF         ;start bit cycle complete?
                     goto        start_bit_completed
                     banksel     PIR1      
                     bcf         PIR1,SSPIF

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

    banksel     byte1
    movwf       byte1

    pagesel read_data_i2cA
    read_data_i2cA
    send_read_ack_i2c

    banksel     byte2
    movwf       byte2

    banksel     SSPBUF
    movfw       SSPBUF

    banksel     byte3
    movwf       byte3

    stop_i2c
    swap_bibbles

        return

display
check_one   movfw   current_digit
            sublw   d'1'
            btfsc   STATUS,Z
            goto    one
            goto    check_two
one         movfw   decimal_place
            call    display_one
            goto    end_digits
check_two   movfw   current_digit
            sublw   d'2'
            btfsc   STATUS,Z
            goto    two
            goto    check_three
two         movfw   decimal_place
            call    display_two
            goto    end_digits
check_three movfw   current_digit
            sublw   d'3'
            btfsc   STATUS,Z
            goto    three
            goto    check_four
three       movfw   decimal_place
            call    display_three
check_four  movfw   current_digit
            sublw   d'4'
            btfsc   STATUS,Z
            goto    four
            goto    check_five
four        movfw   decimal_place
            call    display_four
check_five  movfw   current_digit
            sublw   d'5'
            btfsc   STATUS,Z
            goto    five
            goto    check_six
five        movfw   decimal_place
            call    display_five
check_six   movfw   current_digit
            sublw   d'6'
            btfsc   STATUS,Z
            goto    six
            goto    check_seven
six         movfw   decimal_place
            call    display_six
check_seven movfw   current_digit
            sublw   d'7'
            btfsc   STATUS,Z
            goto    seven
            goto    check_eight
seven       movfw   decimal_place
            call    display_seven
check_eight movfw   current_digit
            sublw   d'8'
            btfsc   STATUS,Z
            goto    eight
            goto    check_nine
eight       movfw   decimal_place
            call    display_eight
check_nine  movfw   current_digit
            sublw   d'9'
            btfsc   STATUS,Z
            goto    nine
            goto    check_zero
nine        movfw   decimal_place
            call    display_nine
check_zero  movfw   current_digit
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
            movlw   d'1'
            movwf   counter
            banksel TMR0
            movlw   d'200'
            movwf   TMR0

wait_again
            bcf     INTCON, T0IF
wait_loop
            btfss   INTCON, T0IF
            goto    wait_loop

            banksel counter
            decfsz  counter,1
            goto    wait_again
   return

indication_loop

    banksel indication_counter
    movlw   0xFF
    movwf   indication_counter

    movlw   b'00000100'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_one
    movwf   current_digit
    pagesel display
    call    display

    ;pagesel wait
    ;call    wait

    movlw   b'00000010'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_two
    movwf   current_digit
    pagesel display
    call    display

    ;pagesel wait
    ;call    wait

    movlw   b'00000001'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_three
    movwf   current_digit
    pagesel display
    call    display

    ;pagesel wait
    ;call    wait

    banksel indication_counter
    decfsz  indication_counter,1

    return

send_receive_display
    pagesel send_address_and_register
    call send_address_and_register

    clrf    AEXP
    clrf    AARGB2

    movfw   byte2
    movwf   AARGB0
    movfw   byte3
    movwf   AARGB1
    pagesel FLO1624
    call    FLO1624

    movfw   AEXP
    movfw   AARGB0
    movfw   AARGB1

    movlw   0x7B    ;0.0625
    movwf   BEXP
    movlw   0x00
    movwf   BARGB0
    movwf   BARGB1

    pagesel FPM24
    call    FPM24

    movfw   AEXP
    movfw   AARGB0
    movfw   AARGB1

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

    pagesel FPM24
    call    FPM24

    pagesel INT2424
    call    INT2424

    movfw   AARGB0
    movfw   AARGB1
    movfw   AARGB2

    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    pagesel FXD2416U
    call    FXD2416U

    movfw   REMB1
    movwf   digit_one

    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    pagesel FXD2416U
    call    FXD2416U

    movfw   REMB1
    movwf   digit_two

    clrf    BARGB0
    movlw   d'10'
    movwf   BARGB1
    pagesel FXD2416U
    call    FXD2416U

    movfw   REMB1
    movwf   digit_three

    return

send_real_data
    ;send 4 bytes device id
    movlw   0x33
    pagesel TXPOLL
    call    TXPOLL
    pagesel TXPOLL
    call    TXPOLL
    pagesel TXPOLL
    call    TXPOLL
    pagesel TXPOLL
    call    TXPOLL

    banksel digit_three
    movfw   digit_three
    addlw   0x30;
    pagesel TXPOLL
    call    TXPOLL

    banksel digit_two
    movfw   digit_two
    addlw   0x30;
    pagesel TXPOLL
    call    TXPOLL

    banksel digit_one
    movfw   digit_one
    addlw   0x30;
    pagesel TXPOLL
    call    TXPOLL

    movlw   0x00
    pagesel TXPOLL
    call    TXPOLL
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
    pagesel     open_i2c
    call        open_i2c

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

    ;timer1 setup
    
    movlw       b'00110001'   ;bit 5-4 -> 00 prescaler = 1:1 bit 1-0 ->
    banksel     T1CON         ; -> internal clock enable timer 1
    movwf       T1CON
    banksel     PIR1
    clrf        PIR1
    clrf        PIR2
    movlw       b'00000001'
    banksel     PIE1
    movwf       PIE1
    clrf        PIE2
    clrf        INTCON
    bsf         INTCON,PEIE
    bsf         INTCON,GIE
    banksel     TMR1H
    clrf        TMR1H
    clrf        TMR1L
    

    pagesel send_receive_display
    call    send_receive_display
main_loop

    pagesel indication_loop
    call    indication_loop

    pagesel     main_loop
    goto        main_loop


    INCLUDE <FP24.A16>
    INCLUDE <FXD46.A16>

    END

