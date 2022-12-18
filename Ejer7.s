.include "inter.inc"

.text
	
/*Cambiamos  del  modo  HYP  a  SVC  */
mrs  r0,cpsr
ldr  r0,  =0b11010011  @  Modo  SVC,  FIQ&IRQ  desact
msr  spsr_cxsf,r0
add  r0,pc,#4
msr  ELR_hyp,r0
eret
	
/*Agregamos  vector  de  interrupci�n  IRQ  */
ldr  r0,  =0
ADDEXC  0x18,  irq_handler
	
/*Inicializamos  la  pila  en  modo  IRQ*/
ldr  r0,  =0b11010010
msr  cpsr_c,  r0
ldr  sp,  =0x8000

/*Inicializamos  la  pila  en  modo  SVC*/
mov r0, #0b11010011
msr cpsr_c, r0
mov sp, #0x800000

/*Configuramos GPIO9 como salida*/
ldr r0, =GPBASE
/*         xx999888777666555444333222111000  */
ldr r1, =0b00001000000000000000000000000000
str r1, [r0, #GPFSEL0]
	
/*Programamos el comparador C3 para interrupcion*/
	
ldr r0, =STBASE
ldr r1, [r0, #STCLO] 
ldr r2, =6000000        @6 segundos de interrupcion
add r1,r2
str r1, [r0,#STC3] 
ldr r0, =INTBASE
ldr r1, =0b1000         @Comparador C3
str r1, [r0,#INTENIRQ1] 
	
/*Activamos interrupciones globalmente */
	
ldr r1, =0b01010011 @Modo SVC  IRQ activo
msr cpsr_c, r1
	
/* Bucle infinito */
bucle: b bucle
	
/*Rutina de interrupcion*/
irq_handler:
    push {r0, r1}
/*Encendemos el led asociado al GPIO9 */
    ldr r0, =GPBASE
/*            10987654321098765432109876543210 */
    ldr r1,=0b00000000000000000000001000000000
    str r1, [r0, #GPSET0]
	
/*Salimos de la rutina*/
	
    pop {r0,r1}
    subs pc, lr, #4
	
	
	
	
	
	
	
	
	
	
	
	
	