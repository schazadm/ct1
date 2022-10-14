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

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed

byte_array             SPACE    16 ; reserve 16 byte for the table


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

        ; Load byte_array address to R0 -> space until R0-R3 -> 16 Bytes à 4 Bytes
        LDR R0, =byte_array
        ; Load BITMASK_LOWER_NIBBLE address to R4
        LDR R4, =BITMASK_LOWER_NIBBLE
        ; Load ADDR_DIP_SWITCH_7_0 address to R4
        LDR R1, =ADDR_DIP_SWITCH_7_0
        ; Read input value (will be stored later in table)
        ; Value is stored in R2
        ; LDRB is used here, because the value at [R1] is only one byte long --> 1 byte = 8 bit
        ; LDRH would load halfword --> 2 bytes = 16 bit
        ; LDR would load word --> 4 bytes = 32 bit
        LDRB R2, [R1]

        ; Debug: Print input value to LED_7_0
        ; Load ADDR_LED_7_0 address to R4
        LDR R5, =ADDR_LED_7_0
        ; Store value of R2 into address in R5
        STRB R2, [R5]

        ; Read input index, which will be used to store the data in the table
        ; Index is stored in R1
        ; Load ADDR_DIP_SWITCH_15_8 address to R1
        LDR R1, =ADDR_DIP_SWITCH_15_8
        ; Read input value from R1 address and store it in R1
        LDRB R1, [R1]
        ; Mask index register to only 4 bits --> we use 4 bit index
        ANDS R1, R1, R4

        ; Debug: Print index value to LED_11_8
        LDR R5, =ADDR_LED_15_8
        STRB R1, [R5]

        ; Store byte_value R2 at index R1 in table byte_array
        STRB R2, [R0, R1]

        ; Load output index (Here the user defines an index
        ; which will be used to display the table value with the LEDs)
        LDR R1, =ADDR_DIP_SWITCH_31_24
        LDRB R1, [R1]
        ANDS R1, R1, R4

        ; Debug: Print index value to LED_11_8
        LDR R5, =ADDR_LED_31_24
        STRB R1, [R5]

        ; Show table value on index R1 on ADDR_LED_23_16
        LDR R5, =ADDR_LED_23_16
        LDRB R7, [R0, R1]
        STRB R7, [R5]

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
