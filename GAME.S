
 		section text



game_init:	movem.l	d0-a6,-(sp)
	
		move.l	#0,ticks		; clear ticks

		jsr 	bg_init			; setup grid
		jsr	bg_draw

		jsr	grid_init
		
		;move.l	#8,d0
		;jsr	grid_random
		
		move.l	#0,p1_score
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	movem.l	d0-a6,-(sp)
		addq.l	#1,ticks
				
		jsr	clear_debug
		jsr	grid_update
		
		move.l	p1_score,d0
		jsr	debug_bars




game_loop_skip:	
		jsr	grid_draw
	
		movem.l	(sp)+,d0-a6
		rts


		section data

		section bss

; game variables
ticks		ds.l	1
paused:		ds.l	1
p1_score:	ds.l	1
