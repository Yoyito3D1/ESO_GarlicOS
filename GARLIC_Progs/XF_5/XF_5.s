	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"XF_5.c"
	.text
	.align	2
	.global	vigenereEncrypt
	.syntax unified
	.arm
	.fpu softvfp
	.type	vigenereEncrypt, %function
vigenereEncrypt:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #32
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #24]
	mov	r3, #0
	str	r3, [sp, #20]
	b	.L2
.L3:
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
.L2:
	ldr	r3, [sp, #20]
	ldr	r2, [sp, #8]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L3
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L4
.L7:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #12]
	add	r2, r1, r2
	ldrb	r1, [r2]	@ zero_extendqisi2
	ldr	r2, [sp, #24]
	ldr	r0, [sp, #8]
	add	r2, r0, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	add	r2, r1, r2
	and	r2, r2, #255
	add	r2, r2, #62
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #25
	bls	.L5
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #4]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	sub	r2, r2, #26
	and	r2, r2, #255
	strb	r2, [r3]
.L5:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #4]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	add	r2, r2, #97
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
	ldr	r2, [sp, #24]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	bne	.L6
	mov	r3, #0
	str	r3, [sp, #24]
.L6:
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L4:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L7
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	nop
	add	sp, sp, #32
	@ sp needed
	bx	lr
	.size	vigenereEncrypt, .-vigenereEncrypt
	.align	2
	.global	vigenereDecrypt
	.syntax unified
	.arm
	.fpu softvfp
	.type	vigenereDecrypt, %function
vigenereDecrypt:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #32
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #24]
	mov	r3, #0
	str	r3, [sp, #20]
	b	.L9
.L10:
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
.L9:
	ldr	r3, [sp, #20]
	ldr	r2, [sp, #8]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L10
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L11
.L14:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #12]
	add	r2, r1, r2
	ldrb	r1, [r2]	@ zero_extendqisi2
	ldr	r2, [sp, #24]
	ldr	r0, [sp, #8]
	add	r2, r0, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	sub	r2, r1, r2
	and	r2, r2, #255
	add	r2, r2, #26
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #25
	bls	.L12
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #4]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	sub	r2, r2, #26
	and	r2, r2, #255
	strb	r2, [r3]
.L12:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	ldr	r2, [sp, #28]
	ldr	r1, [sp, #4]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	add	r2, r2, #97
	and	r2, r2, #255
	strb	r2, [r3]
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
	ldr	r2, [sp, #24]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	bne	.L13
	mov	r3, #0
	str	r3, [sp, #24]
.L13:
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L11:
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L14
	ldr	r3, [sp, #28]
	ldr	r2, [sp, #4]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	nop
	add	sp, sp, #32
	@ sp needed
	bx	lr
	.size	vigenereDecrypt, .-vigenereDecrypt
	.section	.rodata
	.align	2
.LC11:
	.ascii	"-- Programa XIFRAR - PID (%d) --\012\000"
	.align	2
.LC14:
	.ascii	"Missatge a xifrar: %s\012\000"
	.align	2
.LC15:
	.ascii	"Fent servir clau: %s\012\000"
	.align	2
.LC16:
	.ascii	"Missatge xifrat: %s\012\000"
	.align	2
.LC17:
	.ascii	"Missatge desxifrat: %s\012\000"
	.align	2
.LC0:
	.ascii	"holaholahola\000"
	.align	2
.LC1:
	.ascii	"missatgesecret\000"
	.align	2
.LC2:
	.ascii	"vigeneretest\000"
	.align	2
.LC3:
	.ascii	"garlicsystem\000"
	.align	2
.LC4:
	.ascii	"seguretatextra\000"
	.align	2
.LC12:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.align	2
.LC6:
	.ascii	"clave\000"
	.align	2
.LC7:
	.ascii	"segura\000"
	.align	2
.LC8:
	.ascii	"vigenere\000"
	.align	2
.LC9:
	.ascii	"criptografia\000"
	.align	2
.LC13:
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 256
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #260
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L16
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L17
.L16:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L17
	mov	r3, #3
	str	r3, [sp, #4]
.L17:
	bl	GARLIC_clear
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L19
	bl	GARLIC_printf
	ldr	r3, .L19+4
	add	ip, sp, #228
	mov	lr, r3
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldr	r3, [lr]
	str	r3, [ip]
	ldr	r3, .L19+8
	add	ip, sp, #212
	ldm	r3, {r0, r1, r2, r3}
	stm	ip, {r0, r1, r2, r3}
	ldr	r1, [sp, #4]
	ldr	r3, .L19+12
	smull	r2, r3, r1, r3
	asr	r2, r3, #1
	asr	r3, r1, #31
	sub	r2, r2, r3
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	sub	r2, r1, r3
	lsl	r3, r2, #2
	add	r2, sp, #256
	add	r3, r2, r3
	ldr	r3, [r3, #-28]
	str	r3, [sp, #252]
	ldr	r2, [sp, #4]
	asr	r3, r2, #31
	lsr	r3, r3, #30
	add	r2, r2, r3
	and	r2, r2, #3
	sub	r3, r2, r3
	lsl	r3, r3, #2
	add	r2, sp, #256
	add	r3, r2, r3
	ldr	r3, [r3, #-44]
	str	r3, [sp, #248]
	ldr	r1, [sp, #252]
	ldr	r0, .L19+16
	bl	GARLIC_printf
	ldr	r1, [sp, #248]
	ldr	r0, .L19+20
	bl	GARLIC_printf
	add	r3, sp, #112
	mov	r2, r3
	ldr	r1, [sp, #248]
	ldr	r0, [sp, #252]
	bl	vigenereEncrypt
	add	r3, sp, #112
	mov	r1, r3
	ldr	r0, .L19+24
	bl	GARLIC_printf
	add	r2, sp, #12
	add	r3, sp, #112
	ldr	r1, [sp, #248]
	mov	r0, r3
	bl	vigenereDecrypt
	add	r3, sp, #12
	mov	r1, r3
	ldr	r0, .L19+28
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #260
	@ sp needed
	ldr	pc, [sp], #4
.L20:
	.align	2
.L19:
	.word	.LC11
	.word	.LC12
	.word	.LC13
	.word	1717986919
	.word	.LC14
	.word	.LC15
	.word	.LC16
	.word	.LC17
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
