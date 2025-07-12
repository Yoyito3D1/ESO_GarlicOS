@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	código de las funciones de control de procesos (2.0)
@;						(ver "garlic_system.h" para descripción de funciones)
@;
@;==============================================================================

.bss
	.align 2
	quocient: 	.space 4
	residu: 	.space 4
	string: 	.space 4


.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupción
	@; de retroceso vertical (VBL); es un sustituto de la "swi #5" que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC;
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupción)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic;
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (máscara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (máscara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones específicos
	ldr r0, [r2, #4]		@; R0 = máscara de int. del manejador indexado
	cmp	r0, #0				@; si máscara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de búsqueda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = dirección de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si dirección = 0
	mov r2, lr				@; guardar dirección de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar dirección de retorno
	b .Lintr_ret			@; salir del bucle de búsqueda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente índice del vector de
	b	.Lintr_find			@; manejadores de interrupciones específicas
.Lintr_ret:
	mov r1, r0				@; indica qué interrupción se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupción servida)
	ldr	r0, =__irq_flags	@; R0 = dirección flags IRQ para gestión IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupción
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepción IRQ de la BIOS


	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.;
_gp_rsiVBL:
	push {r4-r7, lr}
	
	bl _gp_actualizarDelay

	@; 1. Num_ticks++
	ldr r4, =_gd_tickCount	
	ldr r5, [r4]		
	add r5, #1			
	str r5, [r4]			@; Guardem els ticks a _gd_tickCount	

	@; 2. Comprovem els processos en rdy
	ldr r4, =_gd_nReady		
	ldr r5, [r4]
	cmp r5, #0						
	beq .LrsiVBL_final		@; Sortim si hi ha processos en rdy				

	@; 3. Comprovem si el procés actual és del sistema operatiu
	ldr r4, =_gd_pidz	
	ldr r5, [r4]
	cmp r5, #0				@; Si pid = 0 i socul = 0  -> _gd_pidz = 0 és el SO	
	beq .LrsiVBL_salvarProc

	@; 4. Comprovem si el procés actual és un procés de programa que hagi acabat
	bic r5, r5, #0xf 		@; Bit clear dels 4 bits de menys pes
	cmp r5, #0				@; Si pid = 0 i socul != 0 -> _gd_pidz = 0 és un procés
	beq .LrsiVBL_restaurarProces	

	@; 5. Salvem procès en cas de necessari, preparem paràmetres de rutina
.LrsiVBL_salvarProc:
	ldr r4, =_gd_nReady 	@; R4: @ _gd_nReady
	ldr r5, [r4]			@; R5: num processos en RDY
	ldr r6, =_gd_pidz		@; R6: @ _gd_pidz
	bl _gp_salvarProc

	@; 6. Restaurem procès en cas de necessari, preparem paràmetres de rutina
.LrsiVBL_restaurarProces:
	ldr r4, =_gd_nReady 	@; R4: @ _gd_nReady
	ldr r5, [r4]			@; R5: num processos en RDY
	ldr r6, =_gd_pidz		@; R6: @ _gd_pidz
	bl _gp_restaurarProc
	
	@; Workticks
	ldr r4, =_gd_pidz	
	ldr r5, [r4]		
	and r5, r5, #0xf	
	ldr r4, =_gd_pcbs	
	mov r6, #28
	mla r4, r5, r6, r4	
	ldr r5, [r4, #20]	
	add r5, #1			
	str r5, [r4, #20]	

.LrsiVBL_final:

	pop {r4-r7, pc}


	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs[];
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
	@;Resultado
	@; R5: nuevo número de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}

	@; 1. Mirem si el 1r bit està a 1
	ldr r8,[r6]		@; r8 = últim valor del PID + num socul		
	and r10, r8, #0xf	@; r8 = socul del procés desbancat
	mov r8, r8, lsr #31	@; Guardem bit 31 a r8
	cmp r8, #1		@; si el bit 31 és 1 no va a RDY
	beq .LactivaDelay	@; si és 0 va a RDY
	
	@; 2. Posem el socul a ultima posicio de gd rdy
	ldr r9, =_gd_qReady	@; R9 = @ _gd_ready
	add r9, r5		@; R9 = direcci?n _gd_ready[nReady]
	strb r10, [r9]		@; guardar el z?calo en _gd_ready[nReady]

	@; 3. _gd_nready++
	add r5, #1		
	str r5, [r4]		

.LactivaDelay:
	@;copiar SPSR a garlicPCB
	mov r8, r10 		@; R8: socul procès
	ldr r9, =_gd_pcbs	@; R9: @ _gd_pcbs
	mov r10, #28		@; R10: tamany PCB
	mla r9, r8, r10, r9	@; R9: @ _gd_pcbs[socul]
	mrs r10, SPSR		@; R10: SPSR actual
	str r10, [r9, #12] 	@; guardar SPSR en _gd_pcbs[socul].status

	@; Passem a mode system
	mov r10, r13		
	mrs r11, CPSR		
	bic r11, r11, #0x1F	
	orr r11, r11, #0x1F	
	msr CPSR, r11	

	@; 4. Fem un push per guardar en ordre registres de la pila
	push {lr}				@;R14 

	ldr r8, [r10, #56]
	push {r8}				@;R12

	ldr r8, [r10, #12]
	push {r8}				@;R11

	ldr r8, [r10, #8]
	push {r8}				@;R10

	ldr r8, [r10, #4]
	push {r8}				@;R9

	ldr r8, [r10]
	push {r8}				@;R8

	ldr r8, [r10, #32]
	push {r8}				@;R7

	ldr r8, [r10, #28]
	push {r8}				@;R6

	ldr r8, [r10, #24]
	push {r8}				@;R5

	ldr r8, [r10, #20]
	push {r8}				@;R4

	ldr r8, [r10, #52]
	push {r8}				@;R3

	ldr r8, [r10, #48]
	push {r8}				@;R2

	ldr r8, [r10, #44]
	push {r8}				@;R1

	ldr r8, [r10, #40]
	push {r8}				@;R0	

	@; 5. Guardem r13 i r15 a part tenint en compte l'esquema
	str r13, [r9, #8]		@; r13 es guarda a _gd_pcbs[socul].sp
	ldr r8, [r10, #60] 
	str r8, [r9, #4]		@; guardem a _gd_pcbs[socul].pc	

	@; 6. Tornem al mode IRQ
	mrs r8, CPSR		
	bic r8, r8, #0x1F	
	orr r8, r8, #0x12	
	msr CPSR, r8		

	pop {r8-r11, pc}


	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY;
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}

	@; 1. Decrementem el nombre de processos en estat RDY
	sub r5, #1			
	str r5, [r4]		
	
	@; 2. Guardem a gd_pidz el PID+socul del procés a restaurar
	ldr r8, =_gd_qReady	
	ldrb r9, [r8]			@; socul del 1r procés en estat RDY
	ldr r10, =_gd_pcbs	
	mov r11, #28			@; r11 = tamany PCB	
	mla r10, r9, r11, r10	@; r10 = @_gd_pcbs[socul]
	ldr r11, [r10]			@; r11 = PID procés
	mov r11, r11, lsl #4	@; ens quedem amb els 4 bits baixos	
	orr r11, r11, r9		@; r11 = PID + socul del procés	
	str r11, [r6]			@; guardem r11 a _gd_pidz

	@; 3. Restaurem r15 del procés a restaurar i recuperem CPSR
	ldr r8, [r10, #4]		@; r8 = pc del procés
	str r8, [r13, #60]		@; guardem r8 a irq_stack
	ldr r8, [r10, #12]		@; r8 = estat del procés
	msr SPSR, r8			@; Restaurem SPSR

	@; 4. Passem al mode System
	mov r9, r13			
	mrs r11, CPSR		
	bic r11, r11, #0x1F	
	orr r11, r11, #0x1F	
	msr CPSR, r11		

	ldr r13, [r10, #8]		@; r13: SP del proceso

	@; 5. Pop per guardar en ordre registres de la pila
	pop {r11}
	str r11, [r9, #40] 		@; r0

	pop {r11}
	str r11, [r9, #44] 		@; r1

	pop {r11}
	str r11, [r9, #48] 		@; r2

	pop {r11}
	str r11, [r9, #52] 		@; r3

	pop {r11}
	str r11, [r9, #20] 		@; r4

	pop {r11}
	str r11, [r9, #24] 		@; r5

	pop {r11}
	str r11, [r9, #28] 		@; r6

	pop {r11}
	str r11, [r9, #32] 		@; r7

	pop {r11}
	str r11, [r9] 			@; r8

	pop {r11}
	str r11, [r9, #4] 		@; r9

	pop {r11}
	str r11, [r9, #8] 		@; r10

	pop {r11}
	str r11, [r9, #12] 		@; r11

	pop {r11}
	str r11, [r9, #56] 		@; r12

	pop {r14}				@;R14	
	
	@; 6. Tornem al mode IRQ
	mrs r11, CPSR		
	bic r11, r11, #0x1F	
	orr r11, r11, #0x12	
	msr CPSR, r11		

	@; 7. Control sobre la cua RDY
	ldr r8, =_gd_qReady
	mov r9, #0				@; r9 = contador numProcessos en RDY	
.Lbucle:
	cmp r9, r5				@; Sortirem del bucle quan haguem recorregut tots els processos en RDY
	beq .Lbucle_final	
	add r11, r9, #1	
	ldrb r10, [r8, r11] 	@; r10 = socul del següent index		
	strb r10, [r8, r9]		@; guardem a memòria socul de la posició actual	
	add r9, #1				
	b .Lbucle
.Lbucle_final:

	pop {r8-r11, pc}


	@; Rutina para actualizar la cola de procesos retardados, poniendo en
	@; cola de READY aquellos cuyo número de tics de retardo sea 0
_gp_actualizarDelay:
	push {r0-r9, lr}

	@; 1. Mirar si hi ha algo a la cua de delay
	ldr r0, =_gd_nDelay	
	ldr r1, [r0]		
	cmp r1, #0			
	beq .LactDelay_fi
	
	@; 2. En cas que n'hi hagi, mirarem si algun té tics de retard == 0
	ldr r2, =_gd_qDelay	
	mov r3, #0			
.LactDelay_bucle:
	cmp r3, r1			
	beq .LactDelay_fi	
	ldr r4, [r2, r3, lsl #2]	@; _gd_qDelay[contador*4]	
	sub r4, #1					@; Tics--		
	mov r5, r4 					@; R5 = copia tics de R4	
	ldr r6, =0xffff
	and r4, r4, r6	
	cmp r4, #0					@; Si contador de tics == 0 passa a RDY				
	bne .LactDelay_seguent

	@; 3. Com no té més tics passa a RDY, actualitzem nReady i qReady
	ldr r6, =_gd_nReady	
	ldr r7, [r6]		
	ldr r8, =_gd_qReady	
	mov r5, r5, lsr #24			@; socul procés	
	strb r5, [r8, r7]			@; guardem a _gd_ready[nready]	
	add r7, #1			
	str r7, [r6]		

	@; 4. Actualitzem també la nova cua de delay
	sub r1, #1			
	str r1, [r0]				@; guarde le nou valor de _gd_nDelay	

	mov r6, r3
.Ldelay_actualitzar:
	cmp r6, r1					@; Salta quan hem recorregut tota la cua de delay		
	beq .LactDelay_fi	
	add r7, r6, #1				@; R7: contador + 1 = posició del següent
	ldr r9, [r2, r7, lsl #2]	@; R9: valor de _gd_qDelay[(contador+1) *4]	
	str r9, [r2, r6, lsl #2]	@; guardar el nou valor de _gd_qDelay[contador*4]	
	add r6, #1			
	b .Ldelay_actualitzar
	b .LactDelay_bucle

.LactDelay_seguent:
	str r5, [r2, r3, lsl #2]	@; guardar el nou valor de _gd_qDelay[contador*4]
	add r3, #1			
	b .LactDelay_bucle
.LactDelay_fi:

	pop {r0-r9, pc}

	.global _gp_numProc
	@;Resultado
	@; R0: número de procesos total
_gp_numProc:
	push {r1-r2, lr}
	mov r0, #1				@; contar siempre 1 proceso en RUN
	ldr r1, =_gd_nReady
	ldr r2, [r1]			@; R2 = número de procesos en cola de READY
	add r0, r2				@; añadir procesos en READY
	ldr r1, =_gd_nDelay
	ldr r2, [r1]			@; R2 = número de procesos en cola de DELAY
	add r0, r2				@; añadir procesos retardados
	pop {r1-r2, pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecución y
	@; colocándolo en la cola de READY;
	@;Parámetros
	@; R0: intFunc funcion
	@; R1: int zocalo
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
push {r4-r9, lr}
	
	@; 1. Comprovem si és el sistema operatiu
	cmp r1, #0				@; Si és 0 és error
	beq .LretornarError

	@; 2. Comprovem si el socol està lliure
	ldr r4, =_gd_pcbs	
	mov r5, #28 			@; Tamany PCB
	mla r4, r1, r5, r4		@; R4 = _gd_pcbs[socul]
	ldr r5, [r4]			@; R5 = _gd_pcbs[socul].pid
	cmp r5, #0				@; Si és 0 NO està lliure el socol
	bne .LretornarError
	ldr r5, =_gd_pidCount	
	ldr r6, [r5]	
	add r6, #1				@; processos++
	str r6, [r4]			@; Guardem el nou valor de _gd_pcbs[socul].pid			
	str r6, [r5]			@; Guardem el nou valor de _gd_pidCount
	add r4, #4				@; Ens posem a r4 = _gd_pcbs[socul].pc				
	add r0, #4				@; Sumem 4 al pc per compensar decrement
	str r0, [r4]			@; Guardem a memòria el pc
	add r4, #12				@; nos posem a r4 = _gd_pcbs[socul].keyname
	ldr r7, [r2]
	str r7, [r4]			@; Guardem el nom

	@; 3. Guardem el sp del procés
	ldr r6, =_gd_stacks	
	mov r7, #512 
	mla r6, r1, r7, r6		@; r6 = _gd_stacks[indice]	
	mov r7, r13				@; r7 = sp actual
	mov r13, r6				@; r13 = sp del procés
	ldr r8, =_gp_terminarProc	
 
	push {r8}

	mov r8, #0
	mov r9, #0
.Lbucle_for:
	cmp r8, #12
	beq .Lfinal_for
	add r8, #1
	push {r9}
	b .Lbucle_for
.Lfinal_for:
	push {r3} 
	
	sub r4, #8				@; Ens posem a r4 = _gd_pcbs[socul].sp	
	str r13, [r4]			@; Guardem el nou sp
	mov r13, r7				@; Recuperem el sp anterior al procés	
	add r4, #4				@; r4 = _gd_pcbs[socul].status
	mov r5, #0x1F			@; r5 = 0x1F  => 0011 1111 (bits 0-5 a 1 modo system)	
	str r5, [r4]			@; Guardem el status
	add r4, #8				@; r4 = _gd_pcbs[socul].workTicks	
	mov r5, #0				@; r5 = workticks == 0
	str r5, [r4]	
	ldr r5, =_gd_nReady	
	ldr r6, =_gd_qReady	
	ldr r7, [r5]	
	strb r1, [r6, r7]		@; Guardem el socul en _gd_ready[nReady]	
	add r7, #1				@; _gd_ready++ (processos en rdy)
	str r7, [r5]			@; Guardem el nou valor de _gd_ready
	mov r0, #0				@; No tenim errors si arribem aquí
	b .Lfinal
	
.LretornarError:
	mov r0, #1 
.Lfinal:

	pop {r4-r9, pc}



	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del zócalo actual, para indicar que esa
	@; entrada del vector _gd_pcbs está libre; también pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el número de zócalo), para que el código
	@; de multiplexación de procesos no salve el estado del proceso terminado.
_gp_terminarProc:
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + zócalo
	and r1, r1, #0xf		@; R1 = zócalo del proceso desbancado
	bl _gp_inhibirIRQs
	str r1, [r0]			@; guardar zócalo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = dirección base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
	str r3, [r2, #20]		@; borrar porcentaje de USO de la CPU
	ldr r0, =_gd_sincMain
	ldr r2, [r0]			@; R2 = valor actual de la variable de sincronismo
	mov r3, #1
	mov r3, r3, lsl r1		@; R3 = máscara con bit correspondiente al zócalo
	orr r2, r3
	str r2, [r0]			@; actualizar variable de sincronismo
	bl _gp_desinhibirIRQs
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto



	.global _gp_matarProc
	@; Rutina para destruir un proceso de usuario:
	@; borra el PID del PCB del zócalo referenciado por parámetro, para indicar
	@; que esa entrada del vector _gd_pcbs está libre; elimina el índice de
	@; zócalo de la cola de READY o de la cola de DELAY, esté donde esté;
	@; Parámetros:
	@;	R0:	zócalo del proceso a matar (entre 1 y 15).
_gp_matarProc:
	push {r1-r8,lr} 

	bl _gp_inhibirIRQs

	@; 1. Mirar si és el SO
	cmp r0, #0
	beq .LmatarProc_error

	@; 2. Borrem el PID del PCB del socul passat per paràmetre
	ldr r1, =_gd_pcbs
	mov r2, #28
	mla r1, r0, r2, r1		@; R1: @ de _gd_pcbs[socul]
	mov r2, #0
	str r2, [r1]		
	
	@; 3. Important borrar també el % antic de us de CPU
	str r2, [r1, #20]		

	@; 4. Busquem el index del socul de la cua RDY
	ldr r2, =_gd_nReady	
	ldr r3, [r2]		
	ldr r4, =_gd_qReady	
	mov r5, #0			

.LmatarProc_ready_bucle:
	cmp r5, r3				@; Si hem mirat tots els RDY passem a cua DELAY	
	beq .LmatarProc_delay	
	ldrb r6, [r4, r5]	
	cmp r6, r0				@; Si es compleix tenim el procés que buscàvem		
	beq .LmatarProc_ready_actualitzacio	
	add r5, #1			
	b .LmatarProc_ready_bucle

.LmatarProc_delay:
	@; Aqui buscarem el socul a la cua de DELAY
	ldr r2, =_gd_nDelay	
	ldr r3, [r2]	
	ldr r4, =_gd_qDelay	
	mov r5, #0			
.LmatarProc_delay_loop:
	cmp r5, r3				@; Si hem recorregut tota la cua no està, sortim
	beq .LmatarProc_error	
	ldr r6, [r4, r5, lsl #2]	
	mov r7, r6, lsr #24		@; R7: socul del procés a _gd_delay[contador*4]
	cmp r7, r0				@; Si es compleix tenim el procés que buscàvem
	beq .LmatarProc_delay_update	
	add r5, #1			
	b .LmatarProc_delay_loop

	@; Si entrem aquí, el procés estava a DELAY reordenem i actualizem nDelay
.LmatarProc_delay_update:
	sub r3, #1			
	str r3, [r2]		
	mov r6, r5			
.LmatarProc_delay_update_bucle:
	cmp r6, r3			
	beq .LmatarProc_error	
	add r7, r6, #1				@; R7: contador + 1 = posició del següent
	ldr r8, [r4, r7, lsl #2]	@; R8: següent valor de _gd_delay[(contador+1)*4]	
	str r8, [r4, r6, lsl #2]	@; guardem el nou valor de _gd_delay[contador*4]
	add r6, #1			
	b .LmatarProc_delay_update_bucle
	
	@; Si entrem aquí, el procés estava a RDY reordenem i actualizem nDelay
.LmatarProc_ready_actualitzacio:
	sub r3, #1			
	str r3, [r2]		
	mov r6, r5			
.LmatarProc_ready_actualitzacio_bucle:
	cmp r6, r3			
	beq .LmatarProc_error	
	add r7, r6, #1				@; R7: contador + 1 = posició del següent
	ldrb r8, [r4, r7]			@; R8:següent valor de _gd_ready[contador+1]
	strb r8, [r4, r6]			@; guardem el nou valor de _gd_ready[contador]
	add r6, #1			
	b .LmatarProc_ready_actualitzacio_bucle

.LmatarProc_error:
	bl _gp_desinhibirIRQs
	pop {r1-r8,pc}

	
	.global _gp_retardarProc
	@; retarda la ejecución de un proceso durante cierto número de segundos,
	@; colocándolo en la cola de DELAY
	@;Parámetros
	@; R0: int nsec
_gp_retardarProc:
	push {r0-r5, lr}

	@; 1. Calculem el nombre de tics
	mov r1, #60
	mul r0, r1, r0 			@; nanosec * 60

	ldr r5, =_gd_pidz	
	ldr r1, [r5]		
	
	@; 2. Comprovem si és el SO
	cmp r1, #0
	beq .LretardProc_final	@; si == 0 llavors saltem al final, és el SO

	and r1, r1, #0xf		@; R1 = socul del procés desbancat
	mov r1, r1, lsl #24		@; ens quedem amb els 8 bits alts del socul
	orr r0, r0, r1			@; R0 = word socul + numTics

	@; 3. Guardem el nombre de tics a la cua de delay
	ldr r1, =_gd_qDelay	
	ldr r2, =_gd_nDelay	
	ldr r3, [r2]		
	mov r4, #4
	mla r1, r3, r4, r1		@; R1 = @_gd_delay[nDelay]

	bl _gp_inhibirIRQs
	
	str r0, [r1]			@; Guardem numTics a _gd_delay[nDelay]

	add r3, #1				@; numProcessos en delay++		
	str r3, [r2]			@; actualitzem _gd_nDelay

	@; 4. Fixem el bit més alt de pidz a 1
	ldr r1, [r5]	
	orr r1, r1, #0x80000000	@; R1 = _gd_pidz amb bit més alt fixat a 1
	str r1, [r5]	

	bl _gp_desinhibirIRQs
	@; Forçem canvi de context
	bl _gp_WaitForVBlank		

.LretardProc_final:

	pop {r0-r5, pc}			@; no retornará hasta que se haya agotado el retardo


	.global _gp_inihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 0, para inhibir todas
	@; las IRQs y evitar así posibles problemas debidos al cambio de contexto
_gp_inhibirIRQs:
	push {r0-r1, lr}
	ldr r0, =0x4000208		@; R0 = direcció de REG_IME	
	ldr r1, [r0]			@; R1 = valor de REG_IME
	bic r1, r1, #1			@; Posem a 0 el bit IME (Interrupt Master Enable)
	str r1, [r0]			@; Guardem el resultat a @REG_IME
	pop {r0-r1, pc}


	.global _gp_desinihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 1, para desinhibir todas
	@; las IRQs
_gp_desinhibirIRQs:
	push {r0-r1,lr}
	ldr r0, =0x4000208		@; R0 = direcció de REG_IME
	ldr r1, [r0]			@; R1 = valor de REG_IME
	orr r1, r1, #1 			@; Posem a 1 el bit IME (Interrupt Master Enable)
	str r1, [r0]			@; Guardem el resultat a @REG_IME
	pop {r0-r1,pc}


	.global _gp_rsiTIMER0
	@; Rutina de Servicio de Interrupción (RSI) para contabilizar los tics
	@; de trabajo de cada proceso: suma los tics de todos los procesos y calcula
	@; el porcentaje de uso de la CPU, que se guarda en los 8 bits altos de la
	@; entrada _gd_pcbs[z].workTicks de cada proceso (z) y, si el procesador
	@; gráfico secundario está correctamente configurado, se imprime en la
	@; columna correspondiente de la tabla de procesos.
_gp_rsiTIMER0:
	push {r0-r9, lr}
	
	@; 1. Sumem els workticks de cada procés
	ldr r4, =_gd_pcbs	
	mov r5, #28			
	mov r6, #0			
	mov r7, #0			
	
.LrsiTIMER0_bucle:
	cmp r6, #16				@; si hem recorregut tots els processos sortim
	beq .LrsiTIMER0_final
	mla r8, r6, r5, r4		
	ldr r9, [r8, #20]	 	
	and r9, r9, #0x00FFFFFF	
	add r7, r7, r9			
	add r6, #1			
	b .LrsiTIMER0_bucle
.LrsiTIMER0_final:

	@; 2. Calculem el % de us de CPU de cada procès
	mov r6, #0		
.LrsiTIMER0_bucle2:
	cmp r6, #16		
	beq .LrsiTIMER0_final2
	mla r8, r6, r5, r4		@; R8 = @_gd_PCBS[socul]
	ldr r9, [r8]			@; R9 = PID
	cmp r6, #0				@; si es el proc 0 no cal mirar PID
	beq .LrsiTIMER0_SO
	cmp r9, #0				@; procés no existeix
	beq	.LrsiTIMER0_seguent
	
.LrsiTIMER0_SO:
	ldr r9, [r8, #20]		@; Workticks
	and r9, r9, #0x00FFFFFF	@; Workticks del procés (24 bits baixos)	
	mov r0, #100    
	mul r9, r0, r9			@; Workticks amb %

	@; 3. Dividim el nombre total de workticks 
	mov r0, r9	
	mov r1, r7 
	ldr r2, =quocient 
	ldr r3, =residu 		
	bl _ga_divmod	

	@; 4. Guardem % ús de CPU a _gd_pcbs[socul].workticks i posem a 0 la resta 		
	ldr r9, [r2]	
	mov r9, r9, lsl #24		
	str r9, [r8, #20]		

	@; 5. Convertim aquell % a string 
	ldr r2, [r2]	
	ldr r0, =string 		
	mov r1, #4 				
	bl _gs_num2str_dec		@; _gs_num2str_dec(string, 4, quocient (% ús de la CPU));		

	@; 6. Escrivim string a la columna corresponent
	ldr r0, =string 		
	add r1, r6, #4 			@; R1 = fila 4		
	mov r2, #28				@; R2 = columna 28
	mov r3, #0 				@; R3 = color blanc 
	bl _gs_escribirStringSub	@; _gs_escribirStringSub(String, 4, 28, 0)

.LrsiTIMER0_seguent:
	add r6, #1			
	b .LrsiTIMER0_bucle2

.LrsiTIMER0_final2:
	@; Posem a 1 el bit 0 de la variable _gd_sincMain
	ldr r0, =_gd_sincMain
	ldr r1, [r0]		
	orr r1, #1
	str r1, [r0]

	pop {r0-r9, pc}
	
	
	.global _gp_wait
	@;Paràmetres:
	@; R0: índex del semàfor a fer wait
	@;Resultat:
	@; R0: 1 si s'ha fet BLK, 0 si ja estava en ús
_gp_wait:
	push {r1-r3, lr}         @; Guardem registres necessaris a la pila
	
	ldr r1, =_gd_numSemafors
	add r1, r0
	ldrb r2, [r1]			@; Carreguem semafor (0 o 1)
	beq .LwaitOcupat		@; error si ja estava BLK
	bl _gp_inhibirIRQs
	mov r2, #1				@; Ocupem semafor
	strb r2, [r1]			
	
	ldr r1, =_gd_pidz		
	ldr r2, [r1]
	and r3, r2, #0xF		@; socul
	orr r2, r2, #0x80000000 @; pidz amb bit mes alt activat per BLK
	str r2, [r1]			@; actualitzem PIDZ	
	ldr r1, =_gd_cuaSemafors
	strb r3, [r1, r0]		@; Guardem socul a cua sem
	bl _gp_desinhibirIRQs
	b .LwaitCessio
.LwaitOcupat:
	mov r0, #0				@; Error
	b .LwaitFinal
.LwaitCessio:
	mov r0, #1
	bl _gp_WaitForVBlank	@; Cessio per CPU
.LwaitFinal:
	
    pop {r1-r3, pc}          @; Recuperem registres i retornem


	.global _gp_signal
	@;Paràmetres:
	@; R0: semafor a fer signal
	@;Resultat:
	@; R0: 0 si lliberat, 1 si ja estava lliure
_gp_signal:
	push {r1-r3, lr}         @; Guardem registres necessaris a la pila
	
	ldr r1, =_gd_numSemafors
    add r1, r0
    ldrb r2, [r1]
    cmp r2, #1				@; Si el semafor està ocupat retorna 0
    bne .LsignalLliure        

    mov r2, #0
    strb r2, [r1] 			@; Lliberem i actualitzem semafor         

    ldr r1, =_gd_cuaSemafors
    ldrb r2, [r1, r0]       @; Cua de processos BLK, carreguem socul
    cmp r2, #15
    bhi .LsignalInvalid     @; Si socul invalid == error

    bl _gp_inhibirIRQs
    ldr r0, =_gd_qReady
    ldr r1, =_gd_nReady
    ldr r3, [r1]            
    strb r2, [r0, r3] 		@; Actualitzem cua RDY       
    add r3, #1
    str r3, [r1]            @; Actualitzem contador
    bl _gp_desinhibirIRQs    

.LsignalInvalid:
    mov r0, #1
    b .LsignalFinal           
.LsignalLliure:
    mov r0, #0
.LsignalFinal:

    pop {r1-r3, pc}          @; Recuperem registres i retornem



.end

