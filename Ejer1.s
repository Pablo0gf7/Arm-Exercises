.include "inter.inc"
.text
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr r1,  =0b00000000001000000000000001000000 
        str r1,[r0,#GPFSEL2] @Configura GPIO 22 y 27 (Dos leds verdes)
/* guia bits           10987654321098765432109876543210*/
        ldr r1, =0b00001000010000000000000000000000
        str r1,[r0,#GPSET0] @Enciende GPIO 22 y 27 (Dos leds verdes)
infi:  	b       infi
