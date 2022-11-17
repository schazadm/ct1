; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210
MASK_KEY_T0				  EQU		 0x00000001

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114
ADDR_LCD_COLOUR           EQU        0x60000340
ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314


; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4
LCD_BACKLIGHT_FULL        EQU        0xffff
LCD_BACKLIGHT_OFF         EQU        0x0000

; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
DISPLAY_ZERO_COUNTER      DCB        " Zero(s)"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init 
        BL         clear_lcd

main_loop
        BL adc_get_value ; read adc_value (32bit) into r0

        PUSH {R0, R1, R2}
        LDR R1, =ADDR_BUTTONS ; load base address of keys
        LDR R2, =MASK_KEY_T0 ; load key mask T0
        LDRB R0, [R1] ; load key values
        
		TST R0, R2 ; check, if key T0 is pressed.
        POP {R0, R1, R2}
        
		BNE else_0 ; check if Z flag is not set (Z==0)
		
then_0
        LDR R7, =DISPLAY_COLOUR_GREEN
        BL set_lcd_color

        LDR R7, =ADDR_7_SEG_BIN_DS3_0
        STRH R0, [R7, #0]
		
		; show LED0 first
		LDR R4, =ADDR_LED_31_0
		LDR R7, =0x00000001
		STR R7, [R4]
		
		; if value is FF, add one otherwise the loop stops to early for some reason
		MOVS R7, #0xff
		CMP R0, R7
		BL value_is_ff

		; FIXME: maybe board at home is not functioning correctly,
		; have to -1 because ADC=0 is 1 in register R0
		SUBS R0, #1

		; calc value to build LED bar
		LSRS R0, #3 ; division by 8 to scale the ADC-value from 8-bit down to 5-bit
		MOVS R2, #1 ; prepare for the LED bar -> set to 1 because LED0 is already active

magnitude_bar_loop
		CMP R0, #0 ;check if R0 is empty
		BEQ end_0
		
		LSLS R2, #1
		ADDS R2, #1
		B display_led_bar
		
display_led_bar
		LDR R4, =ADDR_LED_31_0
		STR R2, [R4]
		SUBS R0, #1
		B magnitude_bar_loop
		
value_is_ff
		ADDS R0, #1
		BX LR

end_0
        B main_loop

else_0
        ; read dip switch S7 S0 to r1
        LDR R7, =ADDR_DIP_SWITCH_7_0
        LDRB R1, [R7]
		; diff = dip_switches - ADC_value
        SUBS R1, R1, R0
		
        BLT else_1 ; diff < 0
		
then_1
        LDR R7, =DISPLAY_COLOUR_BLUE
        BL set_lcd_color
		
        CMP R1, #4 ; r1 - 4
        BLT block_2_0 ; diff < 4

        CMP R1, #16 ; r1 - 16
		BLT block_2_1 ; diff < 16

        B default_2

; display 2 Bit on LCD
block_2_0
        LDR R7, =ADDR_LCD_ASCII
        LDR R6, =DISPLAY_2_BIT
        LDRB R6, [R6]
        STRB R6, [R7]
		
        B write_bit

; display 4 Bit on LCD
block_2_1
        LDR R7, =ADDR_LCD_ASCII
        LDR R6, =DISPLAY_4_BIT
        LDRB R6, [R6]
        STRB R6, [R7]

        B write_bit

; display 8 Bit on LCD
default_2
        LDR R7, =ADDR_LCD_ASCII
        LDR R6, =DISPLAY_8_BIT
        LDRB R6, [R6]
        STRB R6, [R7]
		
write_bit
		BL write_bit_ascii
		B end_1

else_1
        LDR R7, =DISPLAY_COLOUR_RED
        BL set_lcd_color

block_3_0
		PUSH {R1}
		MOVS R7, #0 ; zero counter
		MOVS R6, #0 ; iteration counter -> i
		MOVS R5, #32 ; max iteration n
		LDR R4, =0xFFFFFFFE ; bitmask to only extract the LSB

block_3_1
		CMP R6, R5 ; i - 32
		BEQ block_3_2 ; i == 0 or i < 32
		
		ADDS R6, #1 ; i++
		LSRS R1, #1
		MOVS R2, R1
		BICS R2, R4
		CMP R2, #0 ; r2 - 0
		BNE block_3_1 ; bit != 0
		
		ADDS R7, #1 ; zero counter++
		B block_3_1
		
block_3_2
		LDR R3, =ADDR_LCD_ASCII
		LDR R6, =ASCII_DIGIT_OFFSET
		ADDS R3, R3, R6
		STRB R7, [R3]
		POP {R1}

end_1
        LDR     R7, =ADDR_7_SEG_BIN_DS3_0
        STRH    R1, [R7, #0]
		
		B main_loop

set_lcd_color ; to r7
        PUSH    {R0, R1, R2}
        LDR     R0, =ADDR_LCD_COLOUR

        LDR     R1, =LCD_BACKLIGHT_OFF

        LDR     R2, =DISPLAY_COLOUR_RED
        STRH    R1, [R0, R2]

        LDR     R2, =DISPLAY_COLOUR_GREEN
        STRH    R1, [R0, R2]

        LDR     R2, =DISPLAY_COLOUR_BLUE
        STRH    R1, [R0, R2]

        LDR     R1, =LCD_BACKLIGHT_FULL
        STRH    R1, [R0, R7]
		
        POP     {R0, R1, R2}
        BX      LR
        ALIGN		

clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS 
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
        ALIGN


; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
