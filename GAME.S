 		section text



game_init:	movem.l	d0-a6,-(sp)
	
		jsr	init_sprites

		lea	player,a0		; init player
		move.l	#72,c_x(a0)
		move.l	#72,c_y(a0)
		move.l	#0,c_sprite(a0)

		move.l	c_sprite(a0),d0		; player sprite
		move.l	c_x(a0),d1
		move.l	c_y(a0),d2
		jsr	move_sprite

		move.l	#0,ticks		; clear ticks

		jsr 	bg_init
		;jsr	grid_test
		moveq	#grid_h/2,d0
		jsr	grid_random

		movem.l (sp)+,d0-a6
		rts




;temporary routine... sprites need to not clear on first pass
; instead just drawing once before clearing here
game_prep:	movem.l	d0-a6,-(sp)

		lea	player,a1		; player data
		move.l	c_sprite(a1),d0
		
		; jsr	draw_tile_bg
		jsr	grid_draw
		jsr	bg_draw
;		jsr	red_screen
	
		movem.l	(sp)+,d0-a6
		rts




game_loop:	movem.l	d0-a6,-(sp)
		move.l	ticks,d7
		addq.l	#1,d7
		move.l	d7,ticks

		lea	player,a0		; player data


;		move.b	joy_data+1,d0		; grab joystick input
		moveq	#0,d0
		
		move.l	#1,paused
		move.b	joy2,d0			; keyboard joystick
		btst	#0,d0
		beq	check_reset
		
		move.l	#0,paused
		
; reset
check_reset:	btst	#1,d0
		beq	p1_input
		jsr	grid_init
		moveq	#grid_h/2,d0
		jsr	grid_random	
		
	
p1_input:	move.b	joy1,d0

		btst	#7,d0			; fire?
		beq	no_fire

		jsr	red_screen

		move.b	p1_didfire,d1
		cmp.b	#0,d1
		bne	up
		
		; FIRE
		move.b	#1,p1_didfire		; set fire flag & cont
		bra	up

no_fire:	move.b	p1_didfire,d1
		move.b	#0,p1_didfire		; clear fire flag
;		jsr	green_screen

		

up:		move.l	p1_speed,d1

		btst	#0,d0
		beq	down
		sub.l	d1,c_y(a0)

		cmp.l	#16,c_y(a0)
		bgt	left
		move.l	#16,c_y(a0)

down:		btst	#1,d0
		beq	left
		add.l	d1,c_y(a0)

		cmp.l	#scr_h-16,c_y(a0)
		blt	left
		move.l	#scr_h-16,c_y(a0)

left:		btst	#2,d0
		beq	right
		sub.l	d1,c_x(a0)

		cmp.l	#16,c_x(a0)
		bge	p1_done
		move.l	#16,c_x(a0)

right:		btst	#3,d0
		beq	p1_done
		add.l	d1,c_x(a0)

		; clamp right edge	
		cmp.l	#scr_w-32,c_x(a0)
		ble	p1_done
		move.l	#scr_w-32,c_x(a0)

			
p1_done:	; move the player sprite to the new position

		jsr	clear_debug


		move.l	c_sprite(a0),d0
		move.l	c_x(a0),d1
		move.l	c_y(a0),d2
		jsr	move_sprite

		; run the grid update every other frame to
		; simplify the rendering
		move.l	ticks,d0
		and.l	#1,d0
		beq	game_loop_skip
		
		; if up cursor is not pressed, skip update
		move.l	paused,d0
		cmp	#1,d0
		beq	game_loop_skip

		; don't check for matches right after upate
		; or the player never sees the gems when they've
		; fallen all the way
		jsr	grid_matches

		
		jsr 	grid_update


		; now restore the bg for the player
		; TODO: call one generic func to clear ALL

game_loop_skip:	move.l	c_sprite(a0),d0
		move.l	c_x(a0),d1
		move.l	c_y(a0),d2

		jsr	clear_sprite		; reset bg for ship
		
		jsr	grid_draw
		jsr	draw_sprite	

	
game_loop_end:	movem.l	(sp)+,d0-a6
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
	