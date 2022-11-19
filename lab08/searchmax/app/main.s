;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 11
;* -- Description : Unterprogramme und Parameter�bergabe Unittest
;* -- 
;* -- $Id: main.s 878 2014-10-24 08:53:38Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
    
ADDR_BUTTONS    EQU     0x60000210
    
ADDR_LCD_RED    EQU     0x60000340
ADDR_LCD_GREEN  EQU     0x60000342
ADDR_LCD_BLUE   EQU     0x60000344
ADDR_LCD        EQU     0x60000300
        
TABLE_LENGTH_0  EQU     0x80000000
NR_OF_TABLES    EQU     0x04
BITMASK_KEY_T0  EQU     0x01
    
; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   

main            PROC
                EXPORT main
                IMPORT search_max
                    
                ; init display
clear_disp      LDR     R1, =ADDR_LCD
                LDR     R2, =0x20202020
                STR     R2, [R1, #20]
                STRB    R2, [R1, #24] 
init_disp       LDR     R2, =0x74736554           ; Test
                STR     R2, [R1, #0]
                LDR     R2, =0x75736572           ; resu
                STR     R2, [R1, #4]
                LDR     R2, =0x203a746c           ; lt:
                STR     R2, [R1, #8]
                
                ; Wait for button
wait_for_button BL    waitForKey

                ; init counter"tests passed"
start_test      MOVS R7, #0
                
                ; test return value for table length = 0
                LDR     R0, =sample_table1
                MOVS    R1, #0
                BL      search_max
                LDR     R1, =TABLE_LENGTH_0
                CMP     R0, R1
                BNE     test_tables
                ADDS    R7, R7, #1
                
                ; search max in sample_table1
test_tables     LDR     R0, =sample_table1
                MOVS    R1, #8
                BL      search_max
                LDR     R6, =result_table
                STR     R0, [R6]
                
                ; search max in sample_table2
                LDR     R0, =sample_table2
                MOVS    R1, #8
                BL      search_max
                ADDS    R6, R6, #4
                STR     R0, [R6]
                
                ; search max in sample_table3
                LDR     R0, =sample_table3
                MOVS    R1, #8
                BL      search_max
                ADDS    R6, R6, #4
                STR     R0, [R6]
                
                ; search max in sample_table4
                LDR     R0, =sample_table4
                MOVS    R1, #8
                BL      search_max
                ADDS    R6, R6, #4
                STR     R0, [R6]

                ; compare results with golden table
check_results   MOVS    R4, #0
                LDR     R5, =golden_table
                LDR     R6, =result_table

check_next      LDR     R0, [R5]
                LDR     R1, [R6]
                CMP     R0, R1
                BNE     set_up_next
                ADDS    R7, R7, #1
                
set_up_next     ADDS    R4, R4, #1
                ADDS    R6, R6, #4
                ADDS    R5, R5, #4
                CMP     R4, #NR_OF_TABLES
                BLT     check_next

                ; print result
disp_result     LDR     R1, =ADDR_LCD
                CMP     R7, #5
                BNE     test_fail
                
                LDR     R2, =0x73736150           ; Pass
                STR     R2, [R1, #12]                
                BL      set_bg_green
                B       wait_for_button
                
test_fail       LDR     R2, =0x6c696146           ; Fail
                STR     R2, [R1, #12]                
                BL      set_bg_red
                B       wait_for_button
                
                ENDP

; ------------------------------------------------------------------
; Subroutine
; ------------------------------------------------------------------
; wait for key to be pressed and released
waitForKey      PROC
                PUSH    {R0, R1, R2, LR}
                LDR     R1, =ADDR_BUTTONS           ; laod base address of keys
                LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress    LDRB    R0, [R1]                    ; load key values
                TST     R0, R2                      ; check, if key T0 is pressed
                BEQ     waitForPress

waitForRelease  LDRB    R0, [R1]                    ; load key values
                TST     R0, R2                      ; check, if key T0 is released
                BNE     waitForRelease
                
                POP     {R0, R1, R2, PC}                
                ENDP
    

set_bg_green    PROC
                PUSH    {R0, R1, LR}
                
                LDR     R0, =0;
                LDR     R1, =ADDR_LCD_RED
                STRH    R0, [R1]
                LDR     R1, =ADDR_LCD_BLUE
                STRH    R0, [R1]
                LDR     R1, =ADDR_LCD_GREEN
                LDR     R0, =0xffff
                STRH    R0, [R1]
                
                POP     {R0, R1, PC}
                ENDP
    

set_bg_red      PROC
                PUSH    {R0, R1, LR}
                
                LDR     R0, =0;
                LDR     R1, =ADDR_LCD_GREEN
                STRH    R0, [R1]
                LDR     R1, =ADDR_LCD_BLUE
                STRH    R0, [R1]
                LDR     R1, =ADDR_LCD_RED
                LDR     R0, =0xffff
                STRH    R0, [R1]
                
                POP     {R0, R1, PC}
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- Variables
; -------------------------------------------------------------------
                AREA myConstants, DATA, READONLY

sample_table1   DCD     0x00010000, 0x00011700, 0x00012088, 0x00028fa0, 0x0003f800, 0x0010cb8a, 0x00600d00, 0x009b1b12
sample_table2   DCD     0x7fffffff, 0x0000004a, 0xff0011ff, 0x4c43af28, 0xc19ac3bf, 0x00000234, 0x1d36bcde, 0x80782bc2
sample_table3   DCD     0x80000001, 0x8ff804b3, 0x9b4a7786, 0xe77c082b, 0x0ad523bf, 0x4954de1c, 0x7cdee132, 0x7fff6587
sample_table4   DCD     0x8ff804b3, 0x80000001, 0x9b4a7786, 0xe77c082b, 0xc19ac3bf, 0x80782bc2, 0xb980bcde, 0xa10f7fff
    
golden_table    DCD     0x009b1b12, 0x7fffffff, 0x7fff6587, 0xe77c082b 


                AREA myVars, DATA, READWRITE
                    
result_table    SPACE   4*4                 ; Reserve 4 words of memory

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------        
                    
                END

