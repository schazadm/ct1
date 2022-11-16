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
; STUDENTS: To be programmed

		; read adc_value (32bit) into r0
        BL adc_get_value

        PUSH    {r0, r1, r2}
        LDR     r1, =ADDR_BUTTONS ; load base address of keys
        LDR     r2, =MASK_KEY_T0 ; load key mask T0
        LDRB    r0, [r1] ; load key values
        ; Z flag is set to 1 when the result of the operation is zero, cleared to 0 otherwise.
		TST     r0, r2 ; check, if key T0 is pressed.
        POP     {r0, r1, r2}
        BNE     else_0 ; check if Z flag is not set (Z==0)
		
then_0
        ; set LCD color
        LDR     r7, =DISPLAY_COLOUR_GREEN
        BL      set_lcd_color

        ; output adv_value to 7SEG
        LDR     r7, =ADDR_7_SEG_BIN_DS3_0
        STRH    r0, [r7, #0]

        B end_0

else_0
        ; read dip switch S7 S0 to r1
        LDR     r7, =ADDR_DIP_SWITCH_7_0
        LDRB    r1, [r7]
        SUBS    r1, r1, r0

        BLT     else_1

then_1
        ; set LCD color
        LDR     r7, =DISPLAY_COLOUR_BLUE
        BL      set_lcd_color

        CMP r1, #4 ; r1 - 4
        BLT block_2_0 ; < 4

        CMP r1, #16 ; r1 - 16
        BLT block_2_1 ; < 16

        B default_2

; display 2 Bit on LCD
block_2_0
        LDR        r7, =ADDR_LCD_ASCII
        LDR        r6, =DISPLAY_2_BIT
        LDRB       r6, [r6]
        STRB       r6, [r7]
        B end_1

; display 4 Bit on LCD
block_2_1
        LDR        r7, =ADDR_LCD_ASCII
        LDR        r6, =DISPLAY_4_BIT
        LDRB       r6, [r6]
        STRB       r6, [r7]

        B end_1

; display 8 Bit on LCD
default_2
        LDR        r7, =ADDR_LCD_ASCII
        LDR        r6, =DISPLAY_8_BIT
        LDRB       r6, [r6]
        STRB       r6, [r7]

        B end_1

else_1
        ; set LCD color
        LDR     r7, =DISPLAY_COLOUR_RED
        BL      set_lcd_color

        ; MOVS r1, #0xff ; todo remove me

        ; count ones in binary (r1), save in r5
        MOVS r7, r1
        MOVS r6, #0
        MOVS r5, #0
rep     LSRS r7, r7, #1
        ADCS r5, r5, r6 ; add r5 + carry bit.
back    CMP r7, #0 ; check if we are done (if r7 == 0)
        BNE rep

        MOVS r7, #32
        SUBS r5, r7, r5

        ; todo write number to lcd
        LDR       r7, =ADDR_LCD_ASCII_2ND_LINE
        LDR       r5, [r5]
        STR       r5, [r7]

end_1
        BL write_bit_ascii

        ; output diff to 7SEG
        LDR     r7, =ADDR_7_SEG_BIN_DS3_0
        STRH    r1, [r7, #0]

end_0

; END: To be programmed
        B          main_loop

set_lcd_color ; to r7
        PUSH    {r0, r1, r2}
        LDR     r0, =ADDR_LCD_COLOUR

        LDR     r1, =LCD_BACKLIGHT_OFF

        LDR     r2, =DISPLAY_COLOUR_RED
        STRH    r1, [r0, r2]

        LDR     r2, =DISPLAY_COLOUR_GREEN
        STRH    r1, [r0, r2]

        LDR     r2, =DISPLAY_COLOUR_BLUE
        STRH    r1, [r0, r2]

        LDR     r1, =LCD_BACKLIGHT_FULL
        STRH    r1, [r0, r7]
		
        POP     {r0, r1, r2}
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
