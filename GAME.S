
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
		move.l	#0,p1_score_d
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	movem.l	d0-a6,-(sp)
		addq.l	#1,ticks			
		jsr	grid_update
	
game_loop_skip:	
		jsr	grid_draw
		jsr	game_draw_scr
	
		movem.l	(sp)+,d0-a6
		rts
		
		
		
		
game_inc_scr:	movem.l	d0/a0-a1,-(sp)
		move.l	p1_scr_inc,d0
		add.l	d0,p1_score
		
		
		andi	#$ef,ccr			; clear x-bit
		lea	p1_scr_inc_d+4,a0		; end of score inc string
		lea	p1_score_d+4,a1			; end of score string
		
		abcd	-(a0),-(a1)
		abcd	-(a0),-(a1)
		abcd	-(a0),-(a1)
		abcd	-(a0),-(a1)
		
		movem.l	(sp)+,d0/a0-a1
		rts		




game_draw_scr:	movem.l	a0-a1,-(sp)
		movea.l	screen_adr,a0
		adda.l	#scr_w*(scr_h-10)*2+16,a0
		lea	p1_score_d,a1
		jsr	font_bcd
		
		movem.l	(sp)+,a0-a1
		rts




		section data
		
txt_welcome	dc.b	'WELCOME TO MARS. ENJOY YOUR STAY :)',0
p1_scr_inc:	dc.l	10
p1_scr_inc_d:	dc.l	$10

		section bss

; game variables
ticks		ds.l	1
paused:		ds.l	1
p1_score:	ds.l	1
p1_score_d:	ds.l	1
p1_gameover:	ds.l	0