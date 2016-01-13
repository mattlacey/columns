 ; temporary file just for testing sprites

		even

		section text

num_bouncers:	equ	23


init_bouncers:	movem.l	d0-d2/a0-a1,-(sp)
		move.l	#num_bouncers-1,d0

		move.l	#4,d2
		move.l	#16,d1
		
		lea	bouncers,a0		
		lea	b_vel,a1

ib1:		move.l	d2,c_sprite(a0)		; set sprite & pos		
		move.l	d1,c_x(a0)
		move.l	d1,c_y(a0)

		addq.l	#4,d2			; next sprite index
		add.l	#8,d1			; inc. coordinates
		adda.l	#c_size,a0

		move.l	#1,(a1)+		; down - left
		move.l	#1,(a1)+
		
		dbf	d0,ib1
		
		movem.l	(sp)+,d0-d2/a0-a1
		rts




upd_bouncers:	movem.l	d0-d3/a0-a1,-(sp)

		move.l	#num_bouncers-1,d3
		lea	bouncers,a0
		lea	b_vel,a1

ub1:		move.l	0(a1),d1
		move.l	4(a1),d2

		add.l	d1,c_x(a0)		; add velocity	
		add.l	d2,c_y(a0)		; using byte to get -1

		cmp.l	#scr_w-16,c_x(a0)	; check right
		blt	ub_left
		move.l	#scr_w-16,c_x(a0)	; move back
		move.l	#-1,(a1)		; reverse x-velocity

ub_left:	cmp.l	#16,c_x(a0)
		bgt	ub_up
		move.l	#16,c_x(a0)
		move.l	#1,(a1)
		
ub_up:		cmp.l	#16,c_y(a0)
		bgt	ub_down
		move.l	#16,c_y(a0)
		move.l	#1,4(a1)

ub_down:	cmp.l	#scr_h-16,c_y(a0)
		blt	ub_done
		move.l	#scr_h-16,c_y(a0)
		move.l	#-1,4(a1)

ub_done:	adda.l	#8,a1

		move.l	c_sprite(a0),d0
		move.l	c_x(a0),d1
		move.l	c_y(a0),d2

		jsr	move_sprite		
 		jsr	clear_sprite
;		jsr	draw_sprite		

		adda.l	#c_size,a0
		dbf	d3,ub1

		move.l	#num_bouncers-1,d3
		lea	bouncers,a0
ub2:		move.l	c_sprite(a0),d0
		move.l	c_x(a0),d1
		move.l	c_y(a0),d2
		jsr	draw_sprite
		adda.l	#c_size,a0

		dbf	d3,ub2

		movem.l	(sp)+,d0-d3/a0-a1
		rts




		section bss

		even
bouncers:	ds.b	12*num_bouncers
b_vel:		ds.l	2*num_bouncers