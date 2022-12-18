.include "inter.inc"
.text
  
    mrs r0, cpsr
    mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
    msr spsr_cxsf, r0
    add r0, pc, #4
    msr ELR_hyp, r0
    eret
    	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
   
	ldr r0, =0
	
	ldr r4, =GPBASE
/* guia bits   xx999888777666555444333222111000 */
	ldr r5, =0b00001000000000000001000000000000	
	ldr r6, =0b00000000001000000000000000000000
	str r5, [r4, #GPFSEL0]
	str r6, [r4, #GPFSEL1]
	
/* guia bits   xx987654321098765432109876543210 */
	ldr r5, =0b00000000000000000000000000000100
	ldr r6, =0b00000000000000000000000000001000
	ldr r10, =0b00000000000000000000000000010000
/* guia bits   xx987654321098765432109876543210 */
	ldr r8, =0b00000000000000000000001000000000
	ldr r9, =0b00000000000000100000000000000000
	
	ldr r0, =STBASE
	
bucleboton1:
	ldr r7, [r4, #GPLEV0]
	tst r7, r5
	bne bucleboton2
	str r8, [r4, #GPSET0]
	ldr r1, =1908
	b sonido1
	
bucleboton2:
	ldr r7, [r4, #GPLEV0]
	tst r7, r6
	bne bucleboton1
	str r9, [r4, #GPSET0]
	ldr r1, =1278
	b sonido2
	
sonido1:
	str r10, [r4, #GPSET0]
	bl espera
	str r10, [r4, #GPCLR0]
	bl espera
	ldr r7, [r4, #GPLEV0]
	tst r7, r5
	beq sonido1
	str r8, [r4, #GPCLR0]
	b bucleboton2
	
sonido2:
	str r10, [r4, #GPSET0]
	bl espera
	str r10, [r4, #GPCLR0]
	bl espera
	ldr r7, [r4, #GPLEV0]
	tst r7, r6
	beq sonido2
	str r9, [r4, #GPCLR0]
	b bucleboton1

	
espera: 
	push {r4, r5}
	ldr r4, [r0, #STCLO] 
	add r4, r1 
	
ret1: 
	ldr r5, [r0, #STCLO] 
	cmp r5, r4 
	blo ret1 
	pop {r4, r5} 
	bx lr 
	
	
	