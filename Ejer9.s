.include "inter.inc"

seleccion: .word 7 @Varia entre 1-6, dependiendo del led a encender

leds:	@Definimos este vector con los valores de los GPIO de cada LED en orden ascendente

/* guia bits	7654321098765432109876543210 */

		.word 0b1000000000000000000000000000 @LED 6

		.word 0b0000010000000000000000000000 @LED 5

		.word 0b0000000000100000000000000000 @LED 4

		.word 0b0000000000000000100000000000 @LED 3

		.word 0b0000000000000000010000000000 @LED 2

		.word 0b0000000000000000001000000000 @LED 1

/* guia bits	7654321098765432109876543210 */

.text

/*Cambiamos del modo HYP a SVC */

	mrs r0,cpsr
	ldr r0, =0b11010011 @ Modo SVC, FIQ&IRQ desact
	msr spsr_cxsf,r0
	add r0,pc,#4
	msr ELR_hyp,r0
eret

/*Agregamos vector de interrupcion IRQ */
	
	ldr r0, =0
	ADDEXC 0x18, irq_handler

/*Inicializamos la pila en modo IRQ*/

	ldr r0, =0b11010010
	msr cpsr_c, r0
	ldr sp, =0x8000

/*Inicializamos la pila en modo SVC*/
	
	ldr r0, =0b11010011
	msr cpsr_c, r0
	ldr sp, =0x8000000

/*Configuramos los GPIO 9, 10, 11, 17, 22 y 27 como salida */
        
	ldr r0, =GPBASE

/*             xx999888777666555444333222111000 */
	ldr r1, =0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0] 
/*             xx999888777666555444333222111000 */
	ldr r2, =0b00000000001000000000000000001001
	str r2, [r0, #GPFSEL1]
/*             xx999888777666555444333222111000 */
	ldr r3, =0b00000000001000000000000001000000
	str r3, [r0, #GPFSEL2]

/*Programamos comparador C1 para futura interrupcion */
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #2
	str r1, [r0, #STC1]
/*Activamos interrupcion local en comparador C1 */
	ldr r0,=INTBASE
	ldr r1, =0b0010	@ Comparador C1
	str r1,[r0, #INTENIRQ1]
/*Activamos interrupciones globalmente */
    ldr r1, =0b01010011	@ Modo SVC, IRQ activo
	msr cpsr_c, r1

/*Bucle infinito */
bucle:
    b bucle

/*Rutina de Interrupcion */
irq_handler:
	push {r0, r1, r2, r3}	@ Salvamos los registros
	ldr r0, =STBASE
	ldr r1, =GPBASE
/*Apagamos todos los LEDs */
/* guia bits	xx987654321098765432109876543210 */
	ldr r3, =0b00001000010000100000111000000000
	str r3, [r1, #GPCLR0]
	ldr r2, =seleccion
/*Comprobamos que LED toca encender */
	ldr r3, [r2]
	subs r3, #1
	moveq r3, #6
	str r3, [r2]
/*Encendemos el LED que toque segun seleccion */
	ldr r3, [r2, +r3, LSL #2]
	str r3, [r1, #GPSET0]
/*Restablecemos el temporizador C1 */
	ldr r3, =0b0010
	str r3, [r0, #STCS]
/*Reprogramamos la siguiente interrupcion en 400 ms */
	ldr r3, [r0, #STCLO]
	ldr r2, =400000
	add r3, r2
	str r3, [r0, #STC1]
/*Salimos de la rutina */
	pop {r0, r1, r2, r3}
	subs pc, lr, #4

	

	
	
	
	