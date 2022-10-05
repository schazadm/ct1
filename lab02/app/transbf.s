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
; -- CT1 P03 Transferbefehle
; --
; -- $Id: transbf.s 552 2014-09-01 15:06:12Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
MY_CONST                EQU     0x12
ADDR_DIP_SWITCH_31_0    EQU     0x60000200
ADDR_LED_31_0           EQU     0x60000100

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE

store_table             SPACE   16  ; reserve 16 byte (4 words) 
        ALIGN

; ------------------------------------------------------------------
; -- Constants
; ------------------------------------------------------------------
        AREA MyAsmConst, DATA, READONLY
            
addr_dip_switch     DCD     0x60000200
const_table         DCD     0x01234567, 0x12345678, 0x99996666, 0x34567890
        ALIGN

; ------------------------------------------------------------------
; -- MyCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main
            
        ; MOV/MOVS instruction, loading constants
        MOVS    R1, #0xfe                       ; ***A1***
        MOV     R10, R1
        MOVS    R2, #MY_CONST
        MOV     R11, R2                         ; ***A2***
        
        ; load value of dip switches to R4  
		LDR     R3, =ADDR_DIP_SWITCH_31_0       ; ***A3***
        LDR     R4, [R3]

        ; LDR literal, load value of addr_dip_switch to R7 
        LDR     R7, addr_dip_switch             ; ***A4***
        LDR     R0, [R7]
        
        ; write value of dip switches to LEDs
        LDR     R6, =ADDR_LED_31_0
        STR     R0, [R6]
        
        ; LDR pseudo instruction, load address of addr_dip_switch to R7
        LDR     R7, =addr_dip_switch            ; ***A5*** 
        LDR     R0, [R7]
        
        ; write address of dip switches to LEDs
        LDR     R6, =ADDR_LED_31_0
        STR     R0, [R6]

        ; read values from const_table
        LDR     R7, =const_table
        LDR     R0, [R7]
        LDR     R1, [R7, #4]                    ; ***A6***
        MOVS    R6, #8
        LDR     R2, [R7, R6]
        MOVS    R6, #12
        LDR     R3, [R7, R6]                    ; ***A7***

        ; write values to store_table
        LDR     R7, =store_table
        STR     R0, [R7]
        STR     R1, [R7,#4]
        MOVS    R6, #8
        STR     R2, [R7,R6]
        MOVS    R6, #12
        STR     R3, [R7,R6]

        ; write third value from store_table to leds
        MOVS    R1, #8
        LDR     R7, =store_table
        LDR     R0, [R7, R1]
        LDR     R6, =ADDR_LED_31_0
        STR     R0, [R6]

        ; load multiple registers from memory
        LDR     R0, =const_table
        LDM     R0!, {R4, R5, R6, R7}

        B       main
        
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
