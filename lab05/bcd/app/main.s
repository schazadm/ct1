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
; -- CT1 P06 "ALU und Sprungbefehle" mit MUL
; --
; -- $Id: main.s 4857 2019-09-10 17:30:17Z akdi $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address Defines
; ------------------------------------------------------------------

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_7_SEG_BIN_DS3_0    EQU     0x60000114
ADDR_BUTTONS            EQU     0x60000210
MASK_KEY_T0             EQU     0x00000001

ADDR_LCD_RED            EQU     0x60000340
ADDR_LCD_GREEN          EQU     0x60000342
ADDR_LCD_BLUE           EQU     0x60000344
LCD_BACKLIGHT_FULL      EQU     0xffff
LCD_BACKLIGHT_OFF      	EQU     0x0000
	
MASK_BIT_CLEAR			EQU		0xf0

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        ENTRY

main    PROC
        export main
            
		; STUDENTS: To be programmed
		
		LDR 	R2, =MASK_BIT_CLEAR ; 0xF0
		
		; BCD Ones
		LDR 	R0, =ADDR_DIP_SWITCH_7_0
        LDRB 	R0, [R0]
		BICS 	R0, R0, R2 ; clear 4 bits
		
		; BCD Tens
		LDR 	R1, =ADDR_DIP_SWITCH_15_8
        LDRB 	R1, [R1]
		BICS 	R1, R1, R2 ; cler 4 bits
		
		BL 		T0_pressed
		
		; prepare for display
		MOV 	R3, R2 ; copy BCD result
		LSLS 	R3, #4 ; shift 4 bits to the left
		ADDS 	R3, R1 ; add tens
		LSLS 	R3, #4 ; shift 4 bits to the left
		ADDS 	R3, R0 ; add ones

		; display R3 on LED
		LDR 	R4, =ADDR_LED_15_0
        STR 	R3, [R4]
		
		; display R3 on 7-seg
		LDR 	R4, =ADDR_7_SEG_BIN_DS3_0
        STR 	R3, [R4]
		
		MOVS R7, R2
        MOVS R5, #0
		
calcOneBits
        LSRS R7, R7, #1
        BCS increase

; check if we are done (if r2 == 0)
checkIfZero
        CMP R7, #0
        BNE calcOneBits

        ; output one bits to LEDs
        LDR      R7, =ADDR_LED_31_16
        STRH     R5, [R7]

		; END: To be programmed
        B       main
        ENDP
            
;----------------------------------------------------
; Subroutines
;----------------------------------------------------
T0_pressed
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS               ; laod base address of keys
        LDR     R2, =MASK_KEY_T0                ; load key mask T0
        LDRB    R0, [R1]                        ; load key values
        TST     R0, R2                          ; check, if key T0 is pressed
		POP     {R0, R1, R2}

        ; Reset lights
        PUSH    {R0, R1}
        LDR     R0, =ADDR_LCD_BLUE
        LDR     R1, =LCD_BACKLIGHT_OFF
        STR     R1, [R0]
        LDR     R0, =ADDR_LCD_RED
        STR     R1, [R0]
        POP     {R0, R1}

        BEQ     multiplication
        B       shiftAndAdd ; else use shift and add for multiplication
        ALIGN

multiplication
        ; set LCD color
        PUSH    {R0, R1}
        LDR     R0, =ADDR_LCD_BLUE              ; load base address of pwm blue
        LDR     R1, =LCD_BACKLIGHT_FULL         ; backlight full blue
        STRH    R1, [R0]                        ; write pwm register
        POP     {R0, R1}

        ; BCD result
		MOVS	R2, #10 	; prepare 10d for multiplication
		MULS 	R2, R1, R2 	; exec multiplication on bcd tens
		ADDS 	R2, R0 		; now add the ones to result of multiplication

        BX      LR
        ALIGN
		
shiftAndAdd
        ; set LCD color
        PUSH    {R0, R1}
        LDR     R0, =ADDR_LCD_RED               ; load base address of pwm blue
        LDR     R1, =LCD_BACKLIGHT_FULL         ; backlight full blue
        STRH    R1, [R0]                        ; write pwm register
        POP     {R0, R1}
		
        PUSH    {R3} ; tmp
        LSLS    R3, R1, #3 	; left shift tens by 3 -> 2^3 = 8 save in R3
        LSLS    R2, R1, #1 	; left shift tens by 1 -> 2^1 = 2 save to R2
        ADDS	R2, R3		; add R2 and R3 together (n*8 + n*2)
		ADDS	R2, R0		; add the ones to R2
        POP     {R3}

        BX      LR
        ALIGN

increase
        MOVS R6, #0
        ADCS R5, R6
        LSLS R5, #1

        B checkIfZero
        ALIGN
;----------------------------------------------------
; pause for disco_lights
pause           PROC
        PUSH    {R0, R1}
        LDR     R1, =1
        LDR     R0, =0x000FFFFF
        
loop        
        SUBS    R0, R0, R1
        BCS     loop
    
        POP     {R0, R1}
        BX      LR
        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
