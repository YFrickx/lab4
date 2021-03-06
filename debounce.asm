;***********************************************************
;						File Header
;***********************************************************

    title "FSM"
    list p=18F2550, r=hex, n=0
    #include <p18F2550.inc>

SAMPLE equ  0x21
COUNT equ  0x22
COUNT2 equ 0x23

;***********************************************************
; Reset Vector
;***********************************************************

    ORG     0x1000    ; Reset Vector
    		     ; When debugging:0x000; when loading: 0x800
    GOTO    START


;***********************************************************
; Interrupt Vector
;***********************************************************



    ORG     0x1008	; Interrupt Vector  HIGH priority
    GOTO    inter_high	; When debugging:0x008; when loading: 0x808
    ORG     0x1018	; Interrupt Vector  HIGH priority
    GOTO    inter_low	; When debugging:0x008; when loading: 0x808



;***********************************************************
; Program Code Starts Here
;***********************************************************

    ORG     0x1020		; When debugging:0x020; when loading: 0x820

START

    clrf    PORTA 		; Initialize PORTA by clearing output data latches
    movlw   0x3F 		; Value used to initialize data direction
    movwf   TRISA 		; Set RA<5:0> as inputs  0011 1111
    movlw   0x0F 		; Configure A/D for digital inputs 0000 1111
    movwf   ADCON1 		;
    movlw   0x07 		; Configure comparators for digital input
    movwf   CMCON
    clrf    PORTB 		; Initialize PORTB by clearing output data latches
    movlw   0x00 		; Value used to initialize data direction
    movwf   TRISB 		; Set PORTB as output
    clrf    PORTC 		; Initialize PORTC by clearing output data latches
    movlw   0x01	        ; Value used to initialize data direction
    movwf   TRISC
   
    
    ; init timer
    movlw   0x83
    movwf   T0CON		;prescaler: 1/256
    
    movlw   0xA0		;0b11100000
    movwf   INTCON

    bcf     UCON,3		; to be sure to disable USB module
    bsf     UCFG,3		; disable internal USB transceiver
     

    
idle
    bcf	    PORTB,7
    btfss   PORTB,0
    goto    idle
    btfsc   PORTC,0
    goto    idle
    goto    rising
    
    
rising
    btfss   PORTB,0
    goto    rising
    btfss   PORTC,0
    goto    rising
    bcf	    PORTB,7
    goto    falling
    
    
falling    
    bsf	    PORTB,7
    movlw   0xFF
    movwf   COUNT2
    movlw   0xFF
    movwf   COUNT
    CALL    Delay
    goto    idle
    
delay
    	    
    decf    COUNT,1	     ; decrement DCOUNT
    tstfsz  COUNT	     ; check whether DCOUNT = 0x00, if so, return, else go to delay2
    goto    delay
    RETURN
    
Delay
    DECFSZ	COUNT	; Decrement count1
    GOTO	 Delay
    DECFSZ COUNT2 ; Decrement count2
    GOTO	 Delay    
    return
    
led
    BCF	    INTCON,TMR0IF	; clear the TMR0 interrupt flag
    btfsc   PORTB,0
    goto    ledoff
    goto    ledon
    return
    
ledon
    BSF	    PORTB,0
    retfie
    
ledoff
    BCF	    PORTB,0
    retfie
  

inter_high
    btfss   INTCON,TMR0IF
    RETFIE
    BCF	    INTCON,TMR0IF	; clear the TMR0 interrupt flag
    btfsc   PORTB,0
    goto    ledoff
    goto    ledon
    RETFIE
    
inter_low
    nop
    
    RETFIE

END

