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
    ldr r1, =0b00000000000000000001000000000000
    str r1, [r0, #GPFSEL0] @configigura GPIO 4
    /*            10987654321098765432109876543210*/
    ldr r1, =0b00000000000000000000000000010000
    ldr r2, =STBASE
       
    bucle:
        bl espera
        str r1, [r0, #GPSET0] @Enciende GPIO 4
        bl espera       
        str r1, [r0, #GPCLR0] @Apaga GPIO 4
        b bucle 
       
    espera:
        ldr r3, [r2, #STCLO]
        ldr r4, =956	@Tenia que hacer la nota Do por ello lo he pasado con la conversion (1/(2*523))*10^6
        add r4, r3
        ret1: ldr r3, [r2, #STCLO]
            cmp r3, r4
            bne ret1
            bx lr