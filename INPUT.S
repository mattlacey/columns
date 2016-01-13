
; joystick byte: Fire x x x Right Left Down Up

ikbd_joy_on:		equ	$14		; ikbd joystick reporting
ikbd_joy_off:		equ	$1a
ikbd_mouse_on:		equ	$08
ikbd_mouse_off:		equ	$12

ikbd_joy_offset:	equ	24		; joy vector

		section text
		even


init_joystick:	move.l	d0,-(sp)

		move.w	#ikbd_joy_on,-(sp)
		move.w	#0,-(sp)		; command length - 1
		move.w	#25,-(sp)		; XBIOS 25 = send to ikbd		
		trap	#13			; call XBIOS
		addq.l	#6,sp			; restore pointer

		; XBIOS 34 results in a list of all ikbd vectors	
		move.w	#34,-(sp)
		trap	#14
		addq	#2,sp

		move.l	d0,ikbd_vectors		; store vector addr
		movea.l	d0,a0
	
		move.l	24(a0),joy_routine	; backup old routine addr
		move.l	#read_joystick,24(a0)	; set new routine

		move.l	(sp)+,d0
		rts




restore_joystick:
		move.l	a0,-(sp)		; TEST THIS
		move.l	ikbd_vectors,a0		; restore old joy routine
		move.l	joy_routine,24(a0)
		move.l	(sp)+,a0
		rts



read_joystick:	;
		; bclr	#4,$fffffa03.w
		move.b	1(a0),joy_data		; joystick 0
		move.b	2(a0),joy_data+1	; joystick 1
		rts

		section data

ikbd_vectors:	dc.l	0
joy_routine:	dc.l	0

		section bss

joy_data:	ds.b	2	