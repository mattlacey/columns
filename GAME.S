
 		section text



game_init:	movem.l	d0-a6,-(sp)
	
		move.l	#0,ticks		; clear ticks

		jsr 	bg_init			; setup grid
		jsr	grid_init
		
		;move.l	#8,d0
		;jsr	grid_random
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	movem.l	d0-a6,-(sp)
		move.l	ticks,d7
		addq.l	#1,d7
		move.l	d7,ticks

		lea	player,a0		; player data


		moveq	#0,d0
		move.b	joy2,d0			; keyboard joystick
		btst	#0,d0
		beq	check_reset
		
		
; reset
check_reset:	btst	#1,d0
		beq	p1_input_done
		jsr	grid_init
		
	
p1_input_done:	
		; run the grid update every other frame to
		; simplify the rendering
		move.l	ticks,d0
		and.l	#3,d0
		cmp.b	#3,d0
		bne	game_loop_skip
		
		jsr	clear_debug
		jsr	grid_update


game_loop_skip:	jsr	grid_draw
	
		movem.l	(sp)+,d0-a6
		rts



		section data

; game variables
ticks		dc.l	1
paused:		dc.l	1

p1_speed:	dc.l	2
p1_didfire: 	dc.b	0



		section bss


; character structure - size: 12 bytes
c_size:		equ	12

		rsreset

c_x:		rs.l	1
c_y:		rs.l	1
c_sprite:	rs.l	1


player:		ds.b	c_size
	