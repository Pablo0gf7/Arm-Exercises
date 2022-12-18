.include "inter.inc"

pulsador:   .word 0

altavozBit: .word 0

seleccion: .word 1
array:
/*          7654321098765432109876543210*/       
    .word 0b1000000000000000000000000000 @Led 6
    .word 1275 @Nota Sol
    .word 0b0000010000000000000000000000 @Led 5
    .word 1136 @Nota La
    .word 0b0000000000100000000000000000 @Led 4
    .word 1275 @Nota Sol
    .word 0b0000000000000000100000000000 @Led 3
    .word 1012 @Nota Si
    .word 0b0000000000000000010000000000 @Led 2
    .word 956 @Nota do'
    .word 0b0000000000000000001000000000 @led 1
    .word 956 @Nota do'
    .word 0b1000000000000000000000000000 @Led 6
    .word 1515 @Nota Mi
    .word 0b0000010000000000000000000000 @Led 5
    .word 1351 @Nota Fa#
    .word 0b0000000000100000000000000000 @Led 4
    .word 1275 @Nota Sol
    .word 0b0000000000000000100000000000 @Led 3
    .word 1012 @Nota Si
    .word 0b0000000000000000010000000000 @Led 2
    .word 851 @Nota Re'
    .word 0b0000000000000000001000000000 @led 1
    .word 1706 @Nota Re
    .word 0b1000000000000000000000000000 @Led 6
    .word 1706 @Nota Re
    .word 0b0000010000000000000000000000 @Led 5
    .word 1275 @Nota Sol
    .word 0b0000000000100000000000000000 @Led 4
    .word 1136 @Nota La
    .word 0b0000000000000000100000000000 @Led 3
    .word 1706 @Nota Re
    .word 0b0000000000000000010000000000 @Led 2
    .word 1515 @Nota Mi
    .word 0b0000000000000000001000000000 @led 1
    .word 1706 @Nota Re
    .word 0b1000000000000000000000000000 @Led 6
    .word 1706 @Nota Re
    .word 0b0000010000000000000000000000 @Led 5
    .word 1351 @Nota Fa#
    .word 0b0000000000100000000000000000 @Led 4
    .word 1275 @Nota Sol
    .word 0b0000000000000000100000000000 @Led 3
    .word 1706 @Nota Re
    .word 0b0000000000000000010000000000 @Led 2
    .word 1515 @Nota Mi
    .word 0b0000000000000000001000000000 @led 1
    .word 1706 @Nota Re
    .word 0b1000000000000000000000000000 @Led 6
    .word 1706 @Nota Re

.text
/*Cambiamos del modo HYP a SVC */
    mrs r0, cpsr
    mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
    msr spsr_cxsf, r0
    add r0, pc, #4
    msr ELR_hyp, r0
    eret
/*Vector interrumpcion de IRQ y FIQ*/
    ldr r0, =0
    ADDEXC 0x18, irq_handler
    ADDEXC 0x1c, fiq_handler
/*Inicializamos la pila en modo FIQ*/
    ldr r0, =0b11010001
    msr cpsr_c, r0
    ldr sp, =0x4000
/*Inicializamos la pila en modo IRQ*/
    ldr r0, =0b11010010
    msr cpsr_c, r0
    ldr sp, =0x8000
/*Inicializamos la pila en modo SVC*/
    mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x800000
 /* Configuramos los GPIO 4, 9, 10, 11, 17, 22 y 27  */
	ldr r0, =GPBASE
/* guia bits   xx999888777666555444333222111000 */
	ldr r1, =0b00001000000000000001000000000000
    str r1,[r0, #GPFSEL0]
	ldr r2, =0b00001000001000000000000000001001
    str r2,[r0, #GPFSEL1]
	ldr r3, =0b00001000001000000000000001000000
	str r3,[r0, #GPFSEL2]
/*Se preparan las interrupciones */
    ldr r0, =STBASE
    ldr r1, [r0, #STCLO]
    add r1, #2
    str r1, [r0, #STC1]
    str r1, [r0, #STC3]
/*Habilito interrupciones, local y globalmente*/
    ldr r0, =INTBASE
    ldr r1, =0b0010
    str r1, [r0, #INTENIRQ1]
    ldr r1, =0b10000011
    str r1, [r0, #INTFIQCON]
    ldr r0, =0b00010011
    msr cpsr_c, r0
/*Boton */
    ldr r0, =GPBASE
boton:
    ldr r1, [r0, #GPLEV0]
	/*              xx987654321098765432109876543210*/
    ands r2, r1, #0b00000000000000000000000000001000
    beq boton1
	/*              xx987654321098765432109876543210*/
    ands r2, r1, #0b00000000000000000000000000000100
    beq boton2
    b boton
boton1:
    ldr r3, =pulsador
    ldr r4, =1
    str r4, [r3]
    b boton

boton2:
    ldr r3, =pulsador
    ldr r4, =2
    str r4, [r3]
    b boton


irq_handler:
    push {r0,r1,r2,r3} @Se salvan los registros          
    ldr r0, =GPBASE
	ldr r1, =seleccion

/*Compruebo el boton */
    ldr r2, =pulsador
    ldr r3, [r2]
    cmp r4, #2
    beq IRQOFF
    cmp r4, #1
    beq IRQON

IRQ:
/*Resetea c1 */
    ldr r0, =STBASE
    ldr r2, =0b0010
    str r2, [r0, #STCS]
    ldr r2, [r0, #STCLO]
    ldr r3, =500000
    add r2, r3
    str r2, [r0, #STC1]
    pop {r0,r1,r2,r3}
    subs pc, lr, #4

IRQON:


    ldr r2, =0b00001000010000100000111000000000
    str r2, [r0, #GPCLR0]

    ldr r2, [r1]
    subs r2, #1
    moveq r2, #25
    str r2, [r1], #-4

    ldr r2, [r1, +r2, LSL #3]
    str r2, [r0, #GPSET0]

    b IRQ
IRQOFF:
    ldr r2, =0b00001000010000100000111000000000
    str r2, [r0, #GPCLR0]
    b IRQ


fiq_handler:
    push {r0, r1, r2, r3}
    ldr r0, =GPBASE
    ldr r1, =pulsador
    ldr r2, =altavozBit


    ldr r3, [r1]
    cmp r3, #1
    bne FIQOFF


    ldr r3, [r2]
    eors r3, #1
    str r3, [r2], #4


    ldr r3, [r2]
    ldr r2, [r2, +r3, LSL #3]


    ldr r1, =GPBASE
    ldr r3, =0b00000000000000000000000000010000
    streq r3, [r1, #GPSET0]
    strne r3, [r1, #GPCLR0]

FIQOFF:


    ldr r0, =STBASE
    ldr r3, =0B1000
    str r3, [r0, #STCS]

    ldr r3, [r0, #STCLO]
    add r3, r2
    str r3, [r0, #STC3]

    pop {r0, r1, r2, r3}
    subs pc, lr, #4