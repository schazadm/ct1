; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- table.s
; --
; -- CT1 P04 Ein- und Ausgabe von Tabellenwerten
; --
; -- $Id: table.s 800 2014-10-06 13:19:25Z ruan $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB
; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0         EQU     0x60000200
ADDR_DIP_SWITCH_15_8        EQU     0x60000201
ADDR_DIP_SWITCH_31_24       EQU     0x60000203
ADDR_LED_7_0                EQU     0x60000100
ADDR_LED_15_8               EQU     0x60000101
ADDR_LED_23_16              EQU     0x60000102
ADDR_LED_31_24              EQU     0x60000103
ADDR_BUTTONS                EQU     0x60000210
ADDR_DS_1_0                 EQU     0x60000114
ADDR_DS_3_2                 EQU     0x60000115

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed

halfword_array             SPACE    32 ; reserve 32 byte for the tabl


; END: To be programmed
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released
; STUDENTS: To be programmed

		LDR R0, =halfword_array
        LDR R4, =BITMASK_LOWER_NIBBLE

        ; Read input value (will be stored later in table)
        LDR R1, =ADDR_DIP_SWITCH_7_0
        ; Get value from switches and store it in R2
        LDRB R2, [R1]
        ; Debug: Print input value to LED_7_0
        LDR R5, =ADDR_LED_7_0
        STRB R2, [R5]

        ; Read input index, which will be used to store the data in the table
        LDR R1, =ADDR_DIP_SWITCH_15_8
        ; Get value from switches and store it in R6
        LDRB R6, [R1]
        ; Mask index register to only 4 bits --> we use 4 bit index
        ANDS R6, R6, R4
        ; Make byte to halfword by multiplying it with 2
        ; resp. byteshift to the left
        LSLS R6, R6, #1
        ; Debug: Print index value to LED_11_8
        LDR R5, =ADDR_LED_15_8
        STRB R6, [R5]

        ; Store byte_value R2 at index R6 in table halfword_array
        STRB R2, [R0, R6]
        ; Temporary register to store the index
        MOVS R5, R6
        ; Increment R6 to store the index in the second byte of the half word
        ADDS R6, R6, #1
        STRB R5, [R0, R6]

        ; Load output index (Here the user defines an index
        ; which will be used to display the table value with the LEDs)
        LDR R1, =ADDR_DIP_SWITCH_31_24
        ; Get value from switches and store it in R6
        LDRB R6, [R1]
        ; Mask index register to only 4 bits --> we use 4 bit index
        ANDS R6, R6, R4
        ; Make byte to halfword by multiplying it with 2
        ; resp. byteshift to the left
        LSLS R6, R6, #1
        ; Debug: Print index value to LED_11_8
        LDR R5, =ADDR_LED_31_24
        STRB R6, [R5]

        ; Show table value on index R6 on ADDR_LED_23_16
        LDR R5, =ADDR_LED_23_16
        LDRB R7, [R0, R6]
        STRB R7, [R5]

        ;7-seg
        ADDS R6, R6, #1
        LDRB R6, [R0, R6]

        LDR R1, =ADDR_DS_3_2
        LDR R2, =ADDR_DS_1_0
        ; Output index
        STRB R6, [R1]
        ; Output value
        STRB R7, [R2]

; END: To be programmed
        B       readInput
        ALIGN

; ------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS           ; laod base address of keys
        LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is released
        BNE     waitForRelease
                
        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
