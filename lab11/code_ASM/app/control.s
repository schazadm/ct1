;* ----------------------------------------------------------------------------
;* --  _____       ______  _____                                              -
;* -- |_   _|     |  ____|/ ____|                                             -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems              -
;* --   | | | '_ \|  __|  \___ \   Zurich University of                       -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                           -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland               -
;* ----------------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 12
;* -- Description : Control motor speed and direction
;* -- 
;* -- $Id: control.s 1016 2014-11-28 07:27:21Z feur $
;* ----------------------------------------------------------------------------

                IMPORT set_sfr
                IMPORT clear_sfr


; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB
                    
REG_RCC_AHB1ENR     EQU  0x40023830
    
REG_GPIOA_MODER     EQU  0x40020000
REG_GPIOA_OSPEEDR   EQU  0x40020008
REG_GPIOA_BSRR      EQU  0x40020018
    
REG_CT_DIPSW        EQU  0x60000200
    
jump_table      DCD  case_00, case_01, case_10, case_11

; -----------------------------------------------------------------------------
; Initialize EXTI
; -----------------------------------------------------------------------------                           
init_control    PROC
                EXPORT init_control
                    
                PUSH {R6-R7, LR}    
                
init_gpio       ; Clock configuration
                LDR  R6, =REG_RCC_AHB1ENR
                LDR  R7, =0x1               ; Enable GPIOA clock
                BL   set_sfr
                
                ; Output pin configuration (PA.5, PA.6)
                LDR  R6, =REG_GPIOA_MODER
                LDR  R7, =0x1400            ; Set pin to output mode
                BL   set_sfr
                
                LDR  R6, =REG_GPIOA_OSPEEDR
                LDR  R7, =0x1400            ; Set pin to high speed
                BL   set_sfr
                
                ; Return
                POP  {R6-R7, PC}

                NOP
                ENDP
                    
 
; -----------------------------------------------------------------------------
; Check buttons
; -----------------------------------------------------------------------------
do_input        PROC
                EXPORT do_input
                    
                PUSH {R0-R2, LR}
                
                LDR  R0, =REG_CT_DIPSW
                LDRB R1, [R0]
                LDR  R2, =0x3
                ANDS R1, R1, R2
                
case_switch     CMP  R1, #4
                BGE  case_00
                LSLS R1, #2
                LDR  R2, =jump_table
                LDR  R2, [R2, R1]
                BX   R2
                               
case_00         BL   motor_off
                BL   motor_ccw
                B    case_end

case_01         BL   motor_on
                BL   motor_ccw
                B    case_end

case_10         BL   motor_off
                BL   motor_cw
                B    case_end

case_11         BL   motor_on
                BL   motor_cw
           
case_end        POP  {R0-R2, PC}
                ENDP
                    
 
; -----------------------------------------------------------------------------
; Motor control
; -----------------------------------------------------------------------------
motor_on        PROC
                EXPORT motor_on
                    
                PUSH {R0-R7, LR}
                
                LDR  R0, =REG_GPIOA_BSRR
                LDR  R1, =0x20              ; Set bit 5 -> PA.5
                STR  R1, [R0]
                
                POP  {R0-R7, PC}
                ENDP
                    
                    
motor_off       PROC
                EXPORT motor_off
                    
                PUSH {R0-R7, LR}
                
                LDR  R0, =REG_GPIOA_BSRR
                LDR  R1, =0x200000          ; Reset bit 5 -> PA.5
                STR  R1, [R0]
                
                POP  {R0-R7, PC}
                ENDP
                    
                    
motor_cw        PROC
                EXPORT motor_cw
                    
                PUSH {R0-R7, LR}
                
                LDR  R0, =REG_GPIOA_BSRR
                LDR  R1, =0x40              ; Set bit 6 -> PA.6
                STR  R1, [R0]
                
                POP  {R0-R7, PC}
                ENDP
                    
                    
motor_ccw       PROC
                EXPORT motor_ccw
                    
                PUSH {R0-R7, LR}
                
                LDR  R0, =REG_GPIOA_BSRR
                LDR  R1, =0x400000          ; Reset bit 6 -> PA.6
                STR  R1, [R0]
                
                POP  {R0-R7, PC}
                ENDP


; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                END

