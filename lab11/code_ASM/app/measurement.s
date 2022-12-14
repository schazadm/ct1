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
;* -- Description : Meassuring motor speed and direction
;* -- 
;* -- 1) Setup external interrupt EXTI for counting motor pulses
;* -- 2) Setup TIM2 for generating 1 Hz reference clock
;* -- 3) Functions to clear IRQ Flip-flops
;* -- 
;* -- $Id: measurement.s 3858 2017-01-09 13:26:26Z kesr $
;* ----------------------------------------------------------------------------

                IMPORT set_sfr
                IMPORT clear_sfr


; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------

                AREA myCode, CODE, READONLY

                THUMB

REG_RCC_AHB1ENR     EQU  0x40023830
REG_RCC_APB1ENR     EQU  0x40023840
REG_RCC_APB2ENR     EQU  0x40023844

REG_GPIOA_PUPDR     EQU  0x4002000c

REG_EXTI_IMR        EQU  0x40013c00
REG_EXTI_RTSR       EQU  0x40013c08
REG_EXTI_PR         EQU  0x40013c14

REG_TIM2_CR1        EQU  0x40000000
REG_TIM2_DIER       EQU  0x4000000c
REG_TIM2_SR         EQU  0x40000010
REG_TIM2_EGR        EQU  0x40000014
REG_TIM2_PSC        EQU  0x40000028
REG_TIM2_ARR        EQU  0x4000002c

    

; -----------------------------------------------------------------------------
; Initialize EXTI
; -----------------------------------------------------------------------------
init_measurement    PROC
                EXPORT init_measurement
                    
                PUSH {LR}  
                
init_exti       ; Clock configuration
                LDR  R0, =REG_RCC_AHB1ENR
                LDR  R1, =0x1               ; Enable GPIOA clock
                BL   set_sfr
                
                LDR  R0, =REG_RCC_APB2ENR
                LDR  R1, =0x4000            ; Enable SYSCFG clock
                BL   set_sfr
                
                ; Input pin configuration (PA.0)
                LDR  R0, =REG_GPIOA_PUPDR
                LDR  R1, =0x2               ; Set pin to pull-down mode
                BL   set_sfr
                
                ; Configure EXTI
                LDR  R0, =REG_EXTI_IMR
                LDR  R1, =0x1               ; Unmask EXTI0 interrupt
                BL   set_sfr
                
                LDR  R0, =REG_EXTI_RTSR
                LDR  R1, =0x1               ; Trigger on rising edge
                BL   set_sfr
                
                    
init_timer      ; Clock configuration
                LDR  R0, =REG_RCC_APB1ENR
                LDR  R1, =0x1               ; Enable TIM2 clock
                BL   set_sfr
                
                ; Configure TIM2 frequency
                LDR  R0, =REG_TIM2_PSC
                LDR  R1, =839               ; Timer prescaler => 84Mhz / 840 = 100kHz => 10us
                BL   set_sfr
                
                LDR  R0, =REG_TIM2_ARR
                LDR  R1, =0xffffffff        ; Clear Register first, it gets
                BL   clear_sfr              ;   initialized with 0xffffffff
                LDR  R1, =199998             ; Autoreload value => 99999+1 => 1s
                BL   set_sfr
                
                LDR  R0, =REG_TIM2_EGR
                LDR  R1, =0x1               ; Update TIM2 configuration
                BL   set_sfr
                
                LDR  R0, =REG_TIM2_DIER
                LDR  R1, =0x1               ; Enable interrupt source
                BL   set_sfr
                
                LDR  R0, =REG_TIM2_CR1
                LDR  R1, =0x1               ; Enable TIM2
                BL   set_sfr
                
                ; Return
                POP  {PC}
                ENDP

clear_IRQ_EXTI0 PROC
                EXPORT clear_IRQ_EXTI0
                PUSH {LR}
                LDR  R0, =REG_EXTI_PR
                LDR  R1, =0x1               ; Clear irq pending bit
                BL   set_sfr
                POP  {PC}
                ENDP
                    
clear_IRQ_TIM2  PROC
                EXPORT clear_IRQ_TIM2
                PUSH {LR}
                LDR  R0, =REG_TIM2_SR
                LDR  R1, =0x1               ; Clear irq pending bit
                BL   clear_sfr
                POP  {PC}
                ENDP

; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                ALIGN
                END

