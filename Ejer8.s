.include  "inter.inc"
estado:  
    .word  0  @  Variable  global para ver si apagar o encender el led
.text

/*Cambiamos  del  modo  HYP  a  SVC  */
mrs  r0,cpsr
ldr  r0,  =0b11010011  @  Modo  SVC,  FIQ&IRQ  desact
msr  spsr_cxsf,r0
add  r0,pc,#4
msr  ELR_hyp,r0
eret

/*Agregamos  vector  de  interrupcion  IRQ  */
ldr  r0,  =0
ADDEXC  0x18,  irq_handler

/*Inicializamos  la  pila  en  modo  IRQ*/
ldr  r0,  =0b11010010
msr  cpsr_c,  r0
ldr  sp,  =0x8000

/*Inicializamos  la  pila  en  modo  SVC*/
ldr  r0,  =0b11010011
msr  cpsr_c,  r0
ldr  sp,  =0x8000000

/*Configuramos  GPIO9  como  salida  */
ldr  r0,  =GPBASE
/*  guia  b  xx999888777666555444333222111000  */
ldr  r1,  =0b00001000000000000000000000000000
str  r1,  [r0,  #GPFSEL0]

/*Programamos  comparador  C1 */
ldr  r0,  =STBASE
ldr  r1,  [r0,  #STCLO]
ldr  r2,  =500000       @0.5 segundos de interrupcion
add  r1,  r2
str  r1,  [r0,  #STC1]

/*Activamos  interrupci�n  local  en  comparador  C1  */
ldr  r0,=INTBASE
ldr  r1,  =0b0010	@  Comparador  C1
str  r1,[r0,  #INTENIRQ1]

/*Activamos  interrupciones  globalmente  */
ldr  r1,  =0b01010011	@  Modo  SVC,  IRQ  activo
msr  cpsr_c,  r1

/*Bucle  infinito  */
bucle: b  bucle

/*Rutina  de  Interrupci�n  */

irq_handler:
    push  {r0,  r1,  r2}	@  Salvamos  los  registros

/*Encendemos  el  led  asociado  al  GPIO9  */
    ldr  r0,  =GPBASE
    ldr  r1,  =estado
    ldr  r2,  [r1]
    eors  r2,  #1	@  Invertimos  el  valor  de  la  variable  estado

    str  r2,  [r1]
    /*  guia  	 xx987654321098765432109876543210  */
    ldr  r1,  =0b00000000000000000000001000000000
    streq  r1,  [r0,  #GPCLR0]	@  Si  estado  ==  1  entonces  apagamos  el  led  porque  est�  encendido
    strne  r1,  [r0,  #GPSET0]	@  Si  estado  ==  0  entonces  encendemos  el  led  porque  esta  apagado

    /*Restablecemos  el  temporizador  C1  */
    ldr  r0,  =STBASE
    ldr  r1,  =0b0010
    str  r1,  [r0,  #STCS]

    /*Reprogramamos  la  siguiente  interrupci�n  en  0.5  segundos  */
    ldr  r1,  [r0,  #STCLO]
    ldr  r2,  =500000
    add  r1,  r2
    str  r1,  [r0,  #STC1]

    /*Salimos  de  la  rutina  */
    pop  {r0,  r1,  r2}
    subs  pc,  lr,  #4

