.include "inter.inc"

sonido: .word 0
seleccion: .word 7
leds:
/* guia bits	7654321098765432109876543210 */

		.word 0b1000000000000000000000000000 @LED 6

		.word 0b0000010000000000000000000000 @LED 5

		.word 0b0000000000100000000000000000 @LED 4

		.word 0b0000000000000000100000000000 @LED 3

		.word 0b0000000000000000010000000000 @LED 2

		.word 0b0000000000000000001000000000 @LED 1

/* guia bits	7654321098765432109876543210 */
.text
/*Cambiamos  del  modo  HYP  a  SVC  */
	mrs r0, cpsr
    mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
    msr spsr_cxsf, r0
    add r0, pc, #4
    msr ELR_hyp, r0
    eret
    	
	/*Vector interrumpcion de IRQ*/
	ldr r0, =0
	ADDEXC 0x18, irq_handler 
	
	/*Inicializo la pila en modo IRQ y SVC*/
	/*Modo IRQ*/
	mov r0, #0b11010010 
	msr cpsr_c, r0
	mov sp,#0x8000
	/*Modo SVC*/
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x800000
	
	
	/*Configuracion de GPIO9 como salida*/
	ldr r0, =GPBASE
/* guia bits   xx999888777666555444333222111000 */
	ldr r1, =0b00001000000000000001000000000000
	str r1,[r0, #GPFSEL0]
	ldr r2, =0b00001000001000000000000000001001
	str r2,[r0, #GPFSEL1]
	ldr r3, =0b00001000001000000000000001000000
	str r3,[r0, #GPFSEL2]
	
	/*Programamos el contador para la futura interrupcion*/
	
	ldr r0, =STBASE
	ldr r1,[r0,#STCLO]
	ldr r2, =200000 @6 segundos
	add r1, r2
	str r1, [r0, #STC1]
	str r1, [r0, #STC3]

	/*Habilito interrupciones, local y globalmente*/
	ldr r0, =INTBASE
	ldr r1, =0b1010  @Comparador
	str r1, [r0, #INTENIRQ1] 
	ldr r0, =0b01010011
	msr cpsr_c, r0
	
	/*Bucle infinito*/
	bucle: b bucle
	
	/*Rutina de tratamiento de interrupcion*/
irq_handler: 
    push {r0,r1,r2,r3} @Se salvan los registros          
    ldr r0, =STBASE
	ldr r1, =GPBASE
	ldr r2, [r0, #STCS]
	ands r2, #0b0010
	bne buzzer		@C1 controla el buzzer
	/* guia bits       xx987654321098765432109876543210*/
        ldr r3, =0b00001000010000100000111000000000
		str r3, [r1,#GPCLR0] 
		ldr r2, =seleccion
		/*Se comprueba el siguiente led */
		ldr r3, [r2]
		subs r3, #1
		moveq r3, #6
		str r3, [r2]
		/*Se enciende el led */
		ldr r3, [r2, +r3, LSL #2]
		str r3, [r1, #GPSET0]
		/*reseteo C3 */
		ldr r3, =0b1000
		str r3, [r0, #STCS]
		ldr r3, [r0, #STCLO]
		ldr r2, =200000
		add r3, r2
		str r3, [r0, #STC3]
		
		ldr r2, [r0, #STCS]
		ands r2, #0b0010
		beq final
		
	buzzer:
		ldr r2, =sonido
		ldr r3, [r2]
		eors r3, #1		@Invierto el estado
		str r3, [r2]
	/* guia bits           xx987654321098765432109876543210*/
        ldr r3, =0b00000000000000000000000000010000
		streq r3, [r1, #GPSET0]
		strne r3, [r1, #GPCLR0]
		/*Reseteo C1 */
		ldr r3, =0b0010
		str r3, [r0, #STCS]
		/*Sonido 440Hz */
		ldr r3, [r0, #STCLO]
		add r3, #1136
		str r3, [r0, #STC1]
		
	final:
		pop {r0, r1, r2, r3}
		/*Salimos de rti*/
		subs pc, lr, #4 
	
	
	
	
	
	
	
	
	