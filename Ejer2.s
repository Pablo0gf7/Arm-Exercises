.include "inter.inc"
 
.text	
        ldr     r0, =GPBASE

/* guia bits                  xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura GPIO 22 y 27(Dos leds verdes)

/* guia bits                  10987654321098765432109876543210*/
        mov   	r1, #0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 22 y GPI27(Dos leds verdes)

bucle:	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100 @Pulador1
	beq	pulsador1
	ands	r2, r1, #0b00000000000000000000000000001000@Pulsador2
	beq	pulsador2
	b 	bucle

pulsador1:	
/* guia bits                  10987654321098765432109876543210*/
        mov   	r1, #0b00000000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 22
/* guia bits                  10987654321098765432109876543210*/
        mov   	r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 27
	b 	bucle
pulsador2:
/* guia bits                  10987654321098765432109876543210*/
        mov   	r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 27
/* guia bits                  10987654321098765432109876543210*/
        mov   	r1, #0b00000000010000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 22
	b 	bucle

