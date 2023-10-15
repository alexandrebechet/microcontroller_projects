#include <p18F4550.inc>
    
    CONFIG PBADEN = OFF
    CONFIG WDT = OFF
    CONFIG FOSC = HS
    CONFIG MCLRE = ON
    CONFIG CPUDIV  = OSC1_PLL2


    dis0_raw equ 0x000
    dis1_raw equ 0x001
    dis2_raw equ 0x002
    dis3_raw equ 0x003
    dis_raw equ 0x004
    count1 equ 0x005 ; timer counter to have a delay while displaying data
    dis0_data equ 0x006
    dis1_data equ 0x007
    dis2_data equ 0x008
    dis3_data equ 0x009
    
    sec0 equ 0x013
    sec1 equ 0x014
    min0 equ 0x015
    min1 equ 0x016
    
RES_VECT CODE 0x0000
 GOTO INIT
MAIN_PROG CODE
 




org 0x0008
 GOTO irq_handle

 INIT    
    clrf PORTA ; clear PORTA
    clrf TRISA
    clrf LATA
    
    clrf PORTD
    clrf TRISD
    clrf LATD
    
    movlw 0x00
    movwf dis0_raw
    movwf dis1_raw
    movwf dis2_raw
    movwf dis3_raw
    movwf sec0
    movwf sec1
    movwf min0
    movwf min1
    movlw b'00001110'
    movwf ADCON1
    movlw b'10000100'
    movwf T0CON
    bsf INTCON, GIE
    bsf INTCON, TMR0IE
    GOTO MAIN_LOOP
 
irq_handle
    btfsc INTCON, TMR0IF
    call TMR_INTERRUPT
    retfie
    
TMR_INTERRUPT
    bcf INTCON, TMR0IF ; clear the flag
    
    incf sec0, f
    movlw .9 ; is equal to 10 ?
    cpfsgt sec0 ; compare f with WREG, skip if superior
    retfie
    movlw H'00'
    movwf sec0 ; we set back to 0 the counter
    
    incf sec1, f ; we increment sec1_raw
    movlw .5 ; is equal to 10 ?
    cpfsgt sec1 ; compare f with WREG, skip if superior
    retfie
    movlw H'00'
    movwf sec1
    
    incf min0, f ; we increment sec1_raw
    movlw .9 ; is equal to 10 ?
    cpfsgt min0 ; compare f with WREG, skip if superior
    retfie
    movlw H'00'
    movwf min0
    
    incf min1, f ; we increment sec1_raw
    movlw .5 ; is equal to 10 ?
    cpfsgt min1 ; compare f with WREG, skip if superior
    retfie
    movlw H'00'
    movwf min1
    retfie
    
dis_is_0 retlw 0x3F ; mask for 0
dis_is_1 retlw 0x06 ; mask for 1
dis_is_2 retlw 0x5B ; mask for 2
dis_is_3 retlw 0x4F ; mask for 3
dis_is_4 retlw 0x66 ; mask for 4
dis_is_5 retlw 0x6D ; mask for 5
dis_is_6 retlw 0x7D ; mask for 6
dis_is_7 retlw 0x07 ; mask for 7
dis_is_8 retlw 0x7F ; mask for 8
dis_is_9 retlw 0x6F ; mask for 9
dis_is_error retlw 0x79 ; mask for E

dis_error ; should never arrive here
    goto dis_is_error
dis_mark8
    decfsz dis_raw
    goto dis_error
    goto dis_is_9 ; it is 9
dis_mark7
    decfsz dis_raw
    goto dis_mark8
    goto dis_is_8 ; it is 8
dis_mark6
    decfsz dis_raw
    goto dis_mark7
    goto dis_is_7 ; it is 7
dis_mark5
    decfsz dis_raw
    goto dis_mark6
    goto dis_is_6 ; it is 6
dis_mark4
    decfsz dis_raw
    goto dis_mark5
    goto dis_is_5 ; it is 5
dis_mark3
    decfsz dis_raw
    goto dis_mark4
    goto dis_is_4 ; it is 4
dis_mark2
    decfsz dis_raw
    goto dis_mark3
    goto dis_is_3 ; it is 3
dis_mark1
    decfsz dis_raw
    goto dis_mark2
    goto dis_is_2 ; it is 2
decode_digit
    movf dis_raw, f
    btfsc STATUS, Z
    goto dis_is_0 ; Z flag affected, it is 0
    decfsz dis_raw
    goto dis_mark1 ; marks to jump
    goto dis_is_1 ; it is 1

apply_mask
; - decode dis0
    movf dis0_raw, 0
    movwf dis_raw
    call decode_digit ; returns with mask in w
    movwf dis0_data
    ; - decode dis1
    movf dis1_raw, 0
    movwf dis_raw
    call decode_digit ; returns with mask in w
    movwf dis1_data
    ; - decode dis2
    movf dis2_raw, 0
    movwf dis_raw
    call decode_digit ; returns with mask in w
    movwf dis2_data
    ; - decode dis3
    movf dis3_raw, 0
    movwf dis_raw
    call decode_digit ; returns with mask in w
    movwf dis3_data
return
    
display_delay
    decfsz count1
	goto display_delay
    return
    
display
    movf dis0_data, 0
    movwf PORTD
    bsf PORTA, RA0 ; activate dis0
    call display_delay ; wait a little
    bcf PORTA, RA0 ; deactivate dis0
    movf dis1_data, 0
    movwf PORTD
    bsf PORTA, RA1 ; activate dis1
    call display_delay ; wait a little
    bcf PORTA, RA1 ; deactivate dis1
    movf dis2_data, 0
    movwf PORTD
    bsf PORTA, RA2
    call display_delay
    bcf PORTA, RA2
    movf dis3_data, 0
    movwf PORTD
    bsf PORTA, RA3
    call display_delay
    bcf PORTA, RA3
return
    

MAIN_LOOP
    
    movf sec0, 0
    movwf dis0_raw
    
    movf sec1, 0
    movwf dis1_raw
    
    movf min0, 0
    movwf dis2_raw
    
    movf min1, 0
    movwf dis3_raw
   
    call apply_mask
    call display
    
    
    goto MAIN_LOOP
    end
    
    

 
