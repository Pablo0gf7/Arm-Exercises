.include  "inter.inc"

onoff: .word 0

.text
/* Agrego vector interrupcion */        
        mrs r0, cpsr
        mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
        msr spsr_cxsf, r0
        add r0, pc, #4
        msr ELR_hyp, r0
        eret


        ldr r0, =0
        ADDEXC 0x18, irq_handler

        ldr r0, =0b11010010
        msr cpsr_c, r0
        ldr sp, =0x8000


        mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x800000
/* Configuro GPIOs 11, 17 como salida */
        ldr  r0, =GPBASE
/* guia bits        xx999888777666555444333222111000*/
        ldr  r1, =0b00000000001000000000000000001000
        str  r1, [r0, #GPFSEL1]
	

/* Habilito pines GPIO 2 y 3 (botones) para interrupciones*/
        mov  r1, #0b00000000000000000000000000001100
        str  r1, [r0, #GPFEN0]
 
/* Habilito interrupciones, local y globalmente */		
        ldr  r0, =INTBASE
/* guia bits        10987654321098765432109876543210*/
        mov  r1, #0b00000000000100000000000000000000
        str  r1, [r0, #INTENIRQ2]


        mov  r1, #0b01010011   @ Modo SVC, IRQ activo
        msr  cpsr_c, r1

        ldr r0, =GPBASE
        ldr r1, =onoff
        ldr r2, =0b00000000000000100000100000000000


/* guia bits        10987654321098765432109876543210*/
                
/* Repetir para siempre */
bucle:	
        bl      espera        	@ Salta a rutina de espera
	ldr    r3,[r1]
	cmp r3, #0
        streq   r2, [r0, #GPSET0]	@ enciende led
        bl      espera        	@ Salta a rutina de espera
        streq   r2, [r0, #GPCLR0]	@apaga led
        b       bucle

/* rutina de espera */
espera:	
        push	{r0,r1,r2,r3}
        ldr  r0, =STBASE 
        ldr  r1, =200000
        ldr  r2, [r0, #STCLO]	@ Lee contador en r4
        add  r2, r1            	@ r4= r4+medio millon
ret:   
        ldr    	r3, [r0, #STCLO]
        cmp  	r3, r2            	@ Leemos CLO hasta alcanzar
        blo    	ret              	@ el valor de r4
	pop	{r0,r1,r2,r3}
        bx     	lr

irq_handler:
        push {r0,r1} @Se salvan los registros          
        ldr r0, =GPBASE
        ldr r1, =onoff
        ldr r2, =0b00000000000000100000100000000000
        str r2, [r0, #GPCLR0]

        ldr r2, [r0, #GPEDS0]
        ands r2, #0b000000000000000000000000001000

        ldreq r2, =0
        ldrne r2, =1
        str r2, [r1]

        ldr r1, =0b00000000000000000000000000001100
        str r1, [r0, #GPEDS0]

        pop {r0,r1}
        subs pc, lr, #4

/* Rutina de tratamiento de interrupcion */

   
/* Variable global */

