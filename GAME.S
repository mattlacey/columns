
 		section text


		; once off initialisation (on load)
game_pre_init:	move.l	#0,p1_score_high
		move.l	#0,p1_score_high_d
		rts




game_init:	movem.l	d0-a6,-(sp)
	
		jsr	bg_draw
		jsr	grid_init
		
		;move.l	#8,d0
		;jsr	grid_random
		
		move.l	#0,p1_score
		move.l	#0,p1_score_d
		move.l	#0,p1_gameover
		

		; start the game!
		move.l	#seq_gameloop,current_fx
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	movem.l	a0-a1,-(sp)
		addq.l	#1,ticks
		
		jsr	grid_draw
		
		movea.l	screen_adr,a0
		adda.l	#scr_w*2+4,a0
		lea	txt_welcome,a1
		jsr	font_print

		jsr	game_draw_scr
		
		jsr	grid_update
		
		
			
game_loop_done:	movem.l	(sp)+,a0-a1
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
		adda.l	#curr_sc_pos,a0
		lea	p1_score_d,a1
		jsr	font_bcd
		
		movea.l	screen_adr,a0
		adda.l	#high_sc_pos,a0
		lea	p1_score_high_d,a1
		jsr	font_bcd
		
		movem.l	(sp)+,a0-a1
		rts




game_over_loop:	; game over so print text and do sweet fa
		movea.l	screen_adr,a0
		adda.l	#txt_gameover_p,a0
		lea	txt_gameover,a1
		jsr	font_print
		
		movea.l	screen_adr,a0
		adda.l	#txt_score_p,a0
		lea	txt_score,a1
		jsr	font_print

		movea.l	screen_adr,a0
		adda.l	#txt_score_p2,a0
		lea	p1_score_d,a1
		jsr	font_bcd
		
		jsr	joy_update					
		moveq.l	#0,d0				; move on on fire
		move.b	joy1fire,d0
		or.b	joy2fire,d0
		
game_ol_fire:	btst	#J_FIRE,d0
		beq	game_ol_done
		
		move.l	p1_score,d0
		cmp.l	p1_score_high,d0
		ble	game_ol_fe
		
		; new high score so update
		move.l	p1_score,p1_score_high
		move.l	p1_score_d,p1_score_high_d
		
game_ol_fe:	move.l	#seq_menuinit,current_fx

game_ol_done:	rts
		
		
		
		
game_over:	move.l	#1,p1_gameover
		move.l	#seq_gameover,current_fx
		rts
		
		
		
				
		section data
		
txt_welcome	dc.b	'WELCOME TO MARS. ENJOY YOUR STAY :)',0
txt_gameover	dc.b	'* GAME OVER *',0
txt_gameover_p	equ	(2*scr_w*116+(scr_w-13*8))	; screen offset

txt_score	dc.b	'YOUR SCORE:',0
txt_score_p	equ	(2*scr_w*124+(scr_w-11*8))	; screen offset
txt_score_p2	equ	(2*scr_w*132+(scr_w-9*8))	; screen offset

curr_sc_pos:	equ	(2*scr_w*200+44)
high_sc_pos:	equ	(2*scr_w*200+466)

p1_scr_inc:	dc.l	10
p1_scr_inc_d:	dc.l	$10

		section bss

; game variables
ticks		ds.l	1
paused:		ds.l	1
p1_score:	ds.l	1
p1_score_d:	ds.l	1
p1_score_high:	ds.l	1
p1_score_high_d:ds.l	1
p1_gameover:	ds.l	1
music_on:	ds.l	1