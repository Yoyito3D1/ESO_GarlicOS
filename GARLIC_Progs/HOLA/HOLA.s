	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"HOLA.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"PID %d: Iniciant execuci\363 amb sem\340for %d!\012"
	.ascii	"\000"
	.align	2
.LC1:
	.ascii	"(%d)\011%d: Hello world!\012\000"
	.align	2
.LC2:
	.ascii	"PID %d: Sem\340for %d alliberat temporalment. Esper"
	.ascii	"ant...\012\000"
	.align	2
.LC3:
	.ascii	"PID %d: Sem\340for %d garantit, continuant execuci\363"
	.ascii	"!\012\000"
	.align	2
.LC4:
	.ascii	"PID %d: Finalitzant execuci\363 i alliberant sem\340"
	.ascii	"for %d!\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	str	r0, [sp, #4]
	bl	GARLIC_pid
	str	r0, [sp, #16]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L3
.L2:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [sp, #4]
.L3:
	mov	r3, #1
	str	r3, [sp, #20]
	mov	r3, #0
	str	r3, [sp, #12]
	b	.L4
.L5:
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [sp, #20]
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
.L4:
	ldr	r2, [sp, #12]
	ldr	r3, [sp, #4]
	cmp	r2, r3
	bcc	.L5
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	add	r3, sp, #8
	add	r2, sp, #12
	ldr	r1, [sp, #20]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	add	r3, r3, #1
	str	r3, [sp, #8]
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L11
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #12]
	b	.L6
.L7:
	bl	GARLIC_pid
	mov	r1, r0
	ldr	r3, [sp, #12]
	mov	r2, r3
	ldr	r0, .L11+4
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
.L6:
	ldr	r3, [sp, #12]
	cmp	r3, #4
	bls	.L7
	ldr	r0, [sp, #16]
	bl	GARLIC_signal
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L11+8
	bl	GARLIC_printf
	ldr	r0, [sp, #16]
	bl	GARLIC_wait
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L11+12
	bl	GARLIC_printf
	b	.L8
.L9:
	bl	GARLIC_pid
	mov	r1, r0
	ldr	r3, [sp, #12]
	mov	r2, r3
	ldr	r0, .L11+4
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	add	r3, r3, #1
	str	r3, [sp, #12]
.L8:
	ldr	r2, [sp, #12]
	ldr	r3, [sp, #8]
	cmp	r2, r3
	bcc	.L9
	ldr	r0, [sp, #16]
	bl	GARLIC_signal
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L11+16
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L12:
	.align	2
.L11:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
