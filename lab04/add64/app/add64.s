; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- add64.s
; --
; -- CT1 P05 64 Bit Addition
; --
; -- $Id: add64.s 3712 2016-10-20 08:44:57Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_31_0        EQU     0x60000200
ADDR_BUTTONS                EQU     0x60000210
ADDR_LCD_RED                EQU     0x60000340
ADDR_LCD_GREEN              EQU     0x60000342
ADDR_LCD_BLUE               EQU     0x60000344
ADDR_LCD_BIN                EQU     0x60000330
MASK_KEY_T0                 EQU     0x00000001
BACKLIGHT_FULL              EQU     0xffff

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        LDR     R7, =ADDR_LCD_RED              ; load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; backlight full blue
        STRH    R6, [R7]                        ; write pwm register

        LDR     R0, =0                          ; lower 32 bits of total sum
        LDR     R1, =0                          ; higher 32 bits of total sum
endless
        
		BL      waitForKey                      ; wait for key T0 to be pressed
		; ---------------------------------
		; Load address of the first register in the LCD display
        LDR      R7, =ADDR_LCD_BIN
		; Store the first 32 bits at position 0
        STR      R0, [R7, #0]
		; Store the second 32 bits at position 4,
        ; because every "position" in the LCD can store 8 bits
        ; --> 4 x 8 bits = 32 bits that were se in the previous line
        STR      R1, [R7, #4]
		; ---------------------------------
		; ---------------------------------
		; Because ADDR was defined using EQU
        ; we don't need to use the equal sign
        ; beause the compiler will put EQU values
        ; automatically into a literal pool that he creates
        LDR R2, =ADDR_DIP_SWITCH_31_0
        LDR R3, [R2]
		; ---------------------------------
		; ---------------------------------
		; According to https://www.keil.com/support/man/docs/armasm/armasm_dom1361289861747.htm
        ; This is how you add stuff to a 64 bit integer
        ; These two instructions add a 64-bit integer contained in R2
        ; and R3 to another 64-bit integer contained in R0 and R1,
        ; and place the result in R4 and R5.
        ; ADDS    r4, r0, r2    ; adding the least significant words
        ; ADC     r5, r1, r3    ; adding the most significant words
		MOVS R4, #0
		
        ADDS R0, R0, R3 ; adding the least significant words
        ; Because we are only adding a 32 bit value to our 64 bit integer
        ; we don't need to add anything to the second part of our integer value
        ; this addds the carry
        ADCS R1, R4 ; adding the most significant words
		; ---------------------------------
		; ---------------------------------
		
        B       endless
        ALIGN


;----------------------------------------------------
; Subroutines
;----------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS               ; laod base address of keys
        LDR     R2, =MASK_KEY_T0                ; load key mask T0

waitForPress
        LDRB    R0, [R1]                        ; load key values
        TST     R0, R2                          ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                        ; load key values
        TST     R0, R2                          ; check, if key T0 is released
        BNE     waitForRelease

        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
