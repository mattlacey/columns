
 		section text



game_init:	movem.l	d0-a6,-(sp)
	
		move.l	#0,ticks		; clear ticks

		jsr 	bg_init			; setup grid
		jsr	bg_draw

		jsr	font_load
		
		movea.l	screen_adr1,a0
		adda.l	#scr_w*2+4,a0
		lea	txt_welcome,a1
		jsr	font_print
		
		movea.l	screen_adr2,a0
		adda.l	#scr_w*2+4,a0
		lea	txt_welcome,a1
		jsr	font_print


		jsr	grid_init
		
		;move.l	#8,d0
		;jsr	grid_random
		
		move.l	#0,p1_score
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	movem.l	d0-a6,-(sp)
		addq.l	#1,ticks			
		jsr	grid_update
	
game_loop_skip:	
		jsr	grid_draw
	
		movem.l	(sp)+,d0-a6
		rts


		section data
		
txt_welcome	dc.b	'WELCOME TO MARS. ENJOY YOUR STAY :)',0

		section bss

; game variables
ticks		ds.l	1
paused:		ds.l	1
p1_score:	ds.l	1
