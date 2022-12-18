.include "inter.inc"

.text
    mrs r0, cpsr
    mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
    msr spsr_cxsf, r0
    add r0, pc, #4
    msr ELR_hyp, r0
    eret
    
    
    ldr r0, =GPBASE
            /*    xx999888777666555444333222111000*/
    ldr r1, =0b00000000001000000000000000000000
    str r1, [r0, #GPFSEL1] @configigura GPIO 17
    /*            10987654321098765432109876543210*/
    ldr r1, =0b00000000000000100000000000000000
    ldr r2, =STBASE
       
    bucle:
        bl espera
        str r1, [r0, #GPSET0] @Enciende GPIO 17
        bl espera       
        str r1, [r0, #GPCLR0] @Apaga GPIO 17
        b bucle 
       
    espera:
        ldr r3, [r2, #STCLO]
        ldr r4, =1000000		@Contador de tiempo que va a estar encendido
        add r4, r3
        ret1: ldr r3, [r2, #STCLO]
            cmp r3, r4
            bne ret1
            bx lr