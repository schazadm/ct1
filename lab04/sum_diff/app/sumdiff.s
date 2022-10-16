; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- sumdiff.s
; --
; -- CT1 P05 Summe und Differenz
; --
; -- $Id: sumdiff.s 705 2014-09-16 11:44:22Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_23_16          EQU     0x60000102
ADDR_LED_31_24          EQU     0x60000103

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
		
		; Operand A
        LDR R0, =ADDR_DIP_SWITCH_15_8
        ; Get value from switches
        LDRB R0, [R0]
		; expand left shift 24bits
		LSLS R0, R0, #24
		; ---------------------------------
		; Operand B
        LDR R1, =ADDR_DIP_SWITCH_7_0
        ; Get value from switches
        LDRB R1, [R1]
		; expand left shift 24bits
		LSLS R1, R1, #24
		; ---------------------------------
		; ---------------------------------
		; Addition A + B
		ADDS R2, R0, R1
		; ---------------------------------
		; Get and display flags
		MRS R4, APSR
		LSRS R4, R4, #24 ; shift right to get 1 byte values
		LDR R5, =ADDR_LED_15_8
        STR R4, [R5]
		; ---------------------------------
		; ---------------------------------
		; Subtraction A - B
		SUBS R3, R0, R1
		; ---------------------------------
		; Get and display flags
		MRS R4, APSR
		LSRS R4, R4, #24 ; shift right to get 1 byte values
		LDR R5, =ADDR_LED_31_24
		STR R4, [R5]
		; ---------------------------------
		; ---------------------------------
		; Display sum
		LDR R6, =ADDR_LED_7_0
		LSRS R2, R2, #24 ; shift right to get 1 byte values
        STR R2, [R6]
		; ---------------------------------
		; Display difference
		LDR R6, =ADDR_LED_23_16
		LSRS R3, R3, #24 ; shift right to get 1 byte values
        STR R3, [R6]
		; ---------------------------------
		; ---------------------------------

        B       user_prog
        ALIGN
; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
