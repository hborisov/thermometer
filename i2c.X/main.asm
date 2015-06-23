    LIST    P = 16f877a
    INCLUDE <p16f877a.inc>
    INCLUDE <DEV_FAM.INC>	; PIC16 device specific definitions
	INCLUDE <MATH16.INC>    ; PIC16 math library definitions
    INCLUDE <i2c.inc>

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

    CBLOCK  0x70
        byte1
        T_high_byte
        T_low_byte
        byteW
        i2c_buffer
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
    operation
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

    pagesel     refresh_display
    btfss       PIR1,TMR1IF
    goto        exit_interrupt
    goto        refresh_display

    btfss       PIR1,RCIF
    goto        exit_interrupt

rcif_interrupt
    pagesel setupUSART
    ;btfsc   RCSTA,OERR
    ;call    setupUSART
    btfsc   RCSTA,FERR
    call    setupUSART
    ;bcf     RCSTA,OERR
    bcf     RCSTA,FERR

    movfw   RCREG                   ;   read operation
    banksel operation
    movwf   operation

    btfsc   RCSTA,OERR
    call    setupUSART
    bcf     RCSTA,OERR
    bcf     RCSTA,CREN
    bsf     RCSTA,CREN
    

    sublw   0x01
    pagesel operation_send_data
    btfsc   STATUS,Z
    call    operation_send_data
    movfw   operation
    sublw   0x02
    pagesel operation_read_id
    btfsc   STATUS,Z
    call    operation_read_id

refresh_display
    pagesel     rcif_interrupt
    btfsc       PIR1,RCIF
    goto        rcif_interrupt


    ;--------------------------------------
    pagesel     send_receive_display
    call        send_receive_display
    ;--------------------------------------

    
    
exit_interrupt
    movf        pclath_temp,w
    movwf       PCLATH
    swapf       status_temp,w
    movwf       STATUS
    swapf       w_temp,f
    swapf       w_temp,w

    banksel     PIR1
    bcf         PIR1,TMR1IF
    bcf         PIR1,RCIF
    retfie



operation_send_data

    
    pagesel     send_receive_display
    call        send_receive_display
    pagesel     send_real_data
    call        send_real_data
    
    return

operation_read_id
    ;send operation first - 2 - read sensor id
    movlw   0x30
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x32
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x3B        ; - ; delimiter
    pagesel TXPOLL
    call    TXPOLL
    ;send 10 bytes device id
    movlw   0x30
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x31
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x32
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x33
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x34
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x35
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x36
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x37
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x38
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x39
    pagesel TXPOLL
    call    TXPOLL
    movlw   0x3B        ; - ; delimiter
    pagesel TXPOLL
    call    TXPOLL

    movlw   0x00
    pagesel TXPOLL
    call    TXPOLL
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

display_c
    banksel     PORTA
    clrf        PORTA
    clrf        PORTB
    movwf       PORTA

    movlw       b'11100011'
    movwf       PORTB
    return

delay_malko
    movlw   0xff
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

setupUSART
    banksel     TRISC
    movlw       b'11000000'
    iorwf       TRISC

    banksel     SPBRG
    movlw       D'25'
    movwf       SPBRG

    banksel     TXSTA
    movlw       b'00100100'
    movwf       TXSTA

    banksel     RCSTA
    movlw       b'10010000'
    movwf       RCSTA
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

;right shifts 12bit number by 4 places
;byte 1 most significant byte
;byte 2 least significant byte
right_shift_12bit_number MACRO
    banksel     T_high_byte
    swapf       T_low_byte,1
    swapf       T_high_byte,1

    movfw       T_high_byte
    andlw       0xF0
    iorwf       T_low_byte,1

    movlw       0x0F
    andwf       T_high_byte,1
        endm




send_address_and_register

    movlw       b'10000000'
    banksel     SSPSTAT
    movwf       SSPSTAT

    movlw       b'00101000'
    banksel     SSPCON
    movwf       SSPCON

    movlw       0x09
    banksel     SSPADD
    movwf       SSPADD

    movlw       b'11011000'   ;usart and i2c set
    banksel     TRISC
    movwf       TRISC
    banksel     PORTC
    bsf         PORTC,3
    bsf         PORTC,4


    pagesel i2c_wait_for_idle
    call    i2c_wait_for_idle

    pagesel i2c_start
    call    i2c_start

    movlw   b'10010000'
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    movlw   0x01
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    movlw   b'01100000'
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    pagesel i2c_stop
    call    i2c_stop


    pagesel i2c_start
    call    i2c_start

    movlw   b'10010000'
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    movlw   0x00
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    pagesel i2c_wait_for_idle
    call    i2c_wait_for_idle

    pagesel i2c_restart
    call    i2c_restart

    movlw   b'10010001'
    pagesel i2c_send_byte_wait_for_ack
    call    i2c_send_byte_wait_for_ack

    pagesel i2c_wait_for_idle
    call    i2c_wait_for_idle

    pagesel i2c_receive_byte
    call    i2c_receive_byte

    movfw   i2c_buffer
    movwf   T_high_byte

    pagesel i2c_send_acknowledge
    call    i2c_send_acknowledge

    pagesel i2c_wait_for_idle
    call    i2c_wait_for_idle

    pagesel i2c_receive_byte
    call    i2c_receive_byte

    movfw   i2c_buffer
    movwf   T_low_byte

    pagesel i2c_send_not_acknowledge
    call    i2c_send_not_acknowledge

    pagesel i2c_stop
    call    i2c_stop

    right_shift_12bit_number

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

    movlw   b'00001000'
    pagesel display_c
    call    display_c

    pagesel delay_malko
    call    delay_malko


    movlw   b'00000100'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_one
    movwf   current_digit
    pagesel display
    call    display

    pagesel delay_malko
    call    delay_malko

    movlw   b'00000010'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_two
    movwf   current_digit
    pagesel display
    call    display

    pagesel delay_malko
    call    delay_malko

    movlw   b'00000001'
    banksel decimal_place
    movwf   decimal_place
    movfw   digit_three
    movwf   current_digit
    pagesel display
    call    display

    pagesel delay_malko
    call    delay_malko

    banksel indication_counter
    decfsz  indication_counter,1

    return

send_receive_display
    pagesel send_address_and_register
    call send_address_and_register

    clrf    AEXP
    clrf    AARGB2

    movfw   T_high_byte
    movwf   AARGB0
    movfw   T_low_byte
    movwf   AARGB1
    pagesel FLO1624
    call    FLO1624

    ;movfw   AEXP
    ;movfw   AARGB0
    ;movfw   AARGB1

    movlw   0x7B    ;0.0625
    movwf   BEXP
    movlw   0x00
    movwf   BARGB0
    movwf   BARGB1

    pagesel FPM24
    call    FPM24

    ;movfw   AEXP
    ;movfw   AARGB0
    ;movfw   AARGB1

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

    ;movfw   AARGB0
    ;movfw   AARGB1
    ;movfw   AARGB2

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
    ;send operation first == 1 (send data)
    movlw   0x01
    pagesel TXPOLL
    call    TXPOLL
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


    ;setup usart
    pagesel     setupUSART
    call        setupUSART
    ;banksel     SPBRG
    ;movlw       D'25'
    ;movwf       SPBRG

    ;banksel     TXSTA
    ;movlw       b'00100100'
    ;movwf       TXSTA

    ;banksel     RCSTA
    ;movlw       b'10010000'
    ;movwf       RCSTA

    ;timer1 setup
    
    movlw       b'00110001'   ;bit 5-4 -> 00 prescaler = 1:1 bit 1-0 ->
    banksel     T1CON         ; -> internal clock enable timer 1
    movwf       T1CON
    banksel     PIR1
    clrf        PIR1
    clrf        PIR2
    movlw       b'00100001'  ;RCIF enable bit <5> and timer overflow ir
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

