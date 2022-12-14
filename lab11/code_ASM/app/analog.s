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
;* -- Description : Read potentiometer and generate analog voltage
;* -- 
;* -- 1) Setup ADC for reading analog voltage of potentiometer
;* -- 2) Setup DAC for generating analog voltage signal
;* -- 
;* -- $Id: analog.s 1016 2014-11-28 07:27:21Z feur $
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

REG_GPIOA_MODER     EQU  0x40020000
REG_GPIOA_OSPEEDR   EQU  0x40020008
REG_GPIOA_PUPDR     EQU  0x4002000c
REG_GPIOF_MODER     EQU  0x40021400
    
REG_ADC3_SR         EQU  0x40012200
REG_ADC3_CR1        EQU  0x40012204
REG_ADC3_CR2        EQU  0x40012208
REG_ADC3_SMPR2      EQU  0x40012210
REG_ADC3_SQR1       EQU  0x4001222c
REG_ADC3_SQR3       EQU  0x40012234
REG_ADC3_DR         EQU  0x4001224c
    
REG_DAC_CR          EQU  0x40007400
REG_DAC_DHR8R1      EQU  0x40007410

REG_EXTI_IMR        EQU  0x40013c00
REG_EXTI_RTSR       EQU  0x40013c08
REG_EXTI_FTSR       EQU  0x40013c0c

REG_NVIC_ISER0      EQU  0xe000e100
REG_NVIC_ICER0      EQU  0xe000e180
    

; -----------------------------------------------------------------------------
; Initialize ADC and DAC
; -----------------------------------------------------------------------------
init_analog     PROC
                EXPORT init_analog
                    
                PUSH {R6-R7, LR}                    
                    
init_adc        ; Clock configuration
                LDR  R6, =REG_RCC_AHB1ENR
                LDR  R7, =0x20              ; Enable GPIOF clock
                BL   set_sfr
                
                LDR  R6, =REG_RCC_APB2ENR
                LDR  R7, =0x400             ; Enable ADC3 clock
                BL   set_sfr
                
                ; Analog pin configuration (PF.6)
                LDR  R6, =REG_GPIOF_MODER
                LDR  R7, =0x3000
                BL   set_sfr
                
                ; ADC configuration
                LDR  R6, =REG_ADC3_CR1
                LDR  R7, =0x2000000         ; 8 bit resolution
                                            ; Disable scan mode
                BL   set_sfr
                
                LDR  R6, =REG_ADC3_CR2
                LDR  R7, =0x3               ; Enable continous conv. mode
                                            ; Enable ADC
                BL   set_sfr
                
                ; Select channel to read from
                LDR  R6, =REG_ADC3_SMPR2
                LDR  R7, =0x6000            ; ch4: 144 cycles sampling time
                BL   set_sfr
                
                LDR  R6, =REG_ADC3_SQR3
                LDR  R7, =0x4               ; ch4: rank 1 (?)
                BL   set_sfr
                
                
init_dac        ; Clock configuration
                LDR  R6, =REG_RCC_AHB1ENR
                LDR  R7, =0x1               ; Enable GPIOA clock
                BL   set_sfr
                
                LDR  R6, =REG_RCC_APB1ENR
                LDR  R7, =0x20000000        ; Enable DAC clock
                BL   set_sfr
                
                ; Analog pin configuration (PA.4)
                LDR  R6, =REG_GPIOA_MODER
                LDR  R7, =0x300
                BL   set_sfr
                
                ; DAC configuration
                LDR  R6, =REG_DAC_CR
                LDR  R7, =0x1               ; Enable ch. 1
                BL   set_sfr
                
                LDR  R6, =REG_DAC_DHR8R1
                LDR  R7, =0x0               ; Set initial value (=0)
                BL   set_sfr
                
                ; Return
                POP  {R6-R7, PC}

                ENDP
                    
 
; -----------------------------------------------------------------------------
; Process reading ADC and outputing via DAC
; -----------------------------------------------------------------------------
do_analog       PROC
                EXPORT do_analog
                    
                PUSH {R0-R2, R6, LR}
                
                BL   get_adc                ; Get ADC value in R7
                BL   set_dac                ; Set DAC value from R7            

                POP  {R0-R2, R6, PC}        ; Restore registers and return
                
                ENDP                        ; Return
                    
 
; -----------------------------------------------------------------------------                   
; Convert with ADC an return value
; - converted analog value in R7
; -----------------------------------------------------------------------------
get_adc         PROC
                EXPORT get_adc
                    
                PUSH {R0-R2, R6, LR}
                
                LDR  R6, =REG_ADC3_CR2
                LDR  R7, =0x40000000        ; Start conversion
                BL   set_sfr
                
                LDR  R0, =REG_ADC3_SR
adc_wait        LDR  R1, =0x2
                LDR  R2, [R0]
                BICS R1, R1, R2             ; Is conversion finished
                BNE  adc_wait
                
                LDR  R0, =REG_ADC3_DR
                LDR  R1, [R0]               ; Get converted value
                LDR  R7, =0xffff
                ANDS R7, R7, R1             ; Mask upper halfword                

                POP  {R0-R2, R6, PC}        ; Restore registers and return
                
                ENDP                        ; Return


; -----------------------------------------------------------------------------
; Set DAC output
; - digital value in R7
; -----------------------------------------------------------------------------
set_dac         PROC
                EXPORT set_dac
                    
                PUSH {R0-R1, R6, LR}      

                LDR  R6, =REG_DAC_DHR8R1
                LDR  R0, [R6]
                LDR  R1, =0xff
                BICS R0, R0, R1             ; Clear bits
                STR  R0, [R6]
                BL   set_sfr                ; Set value in R7

                POP  {R0-R1, R6, PC}        ; Restore registers and return
                
                ENDP                        ; Return


; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                END

