.include "inter.inc"
.text
        ldr     r0, =GPBASE
/* guia bits              xx999888777666555444333222111000*/
        mov     r1, #0b00000000001000000000000000000000
        str     r1, [r0, #GPFSEL1]  @ Configura el GPIO 17
bucle:  
/* guia bits              10987654321098765432109876543210*/
        mov     r1, #0b00000000000000100000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 17
        mov     r1, #0b00000000000000100000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 17
        b       bucle
@Esta todo el rato encendido, bueno mejor dicho el ojo humano lo ve todo el rato encendido pero esta parpadeando a mucha frecuencia que no lo detectamos