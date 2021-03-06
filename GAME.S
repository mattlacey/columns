
 		section text


		; once off initialisation (on load)
game_pre_init:	move.l	#0,p1_score_high
		move.l	#0,p1_score_high_d
		
		; see if high scores file exists
		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	#file_scores,-(sp)			
		move.w	#$4e,-(sp)				
		trap	#1					
		addq.l	#8,sp					

		tst.l	d0					
		beq.s	game_p_load
		
		; nope, so create it
		move.w	#0,-(sp)
		move.l	filename,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,filenumber				; in Loader.s
		
		; and close it
		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;
		bra	game_p_done
 		
		
		; load high scores if they exist
game_p_load:	move.l	#file_scores,filename.l
		move.l	#p1_score_high,filebuffer.l
		jsr	loader
game_p_done:		
		rts




game_init:	movem.l	d0-a6,-(sp)
	
		jsr	bg_load_game
		jsr	bg_draw_bb
		
		jsr	grid_init
				
		move.l	#0,p1_score
		move.l	#0,p1_score_d
		move.l	#0,p1_gameover
		move.l	#1,p1_score_upd
		move.l	#1,gameover_draw
		
		movea.l	screen_adr1,a0		; high score into both
		adda.l	#high_sc_pos,a0		; screen buffers
		lea	p1_score_high_d,a1
		jsr	font_bcd
		
		movea.l	screen_adr2,a0
		adda.l	#high_sc_pos,a0
		jsr	font_bcd
		
		
		; start the game!
		move.l	#seq_gameloop,current_fx
		
		movem.l (sp)+,d0-a6
		rts




game_loop:	jsr	grid_draw
		
		cmp.l	#0,p1_score_upd
		beq	game_loop_upd
		jsr	game_draw_scr

game_loop_upd:	jsr	grid_update
			
game_loop_done:	rts
		
		
		
		
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
		
		move.l	#1,p1_score_upd
		
		movem.l	(sp)+,d0/a0-a1
		rts		




game_draw_scr:	movem.l	a0-a1,-(sp)
		
		movea.l	screen_adr1,a0
		adda.l	#curr_sc_pos,a0
		lea	p1_score_d,a1
		jsr	font_bcd
		
		movea.l	screen_adr2,a0
		adda.l	#curr_sc_pos,a0
		jsr	font_bcd
		
		move.l	#0,p1_score_upd
		
		movem.l	(sp)+,a0-a1
		rts




game_over_loop:	; game over so print text and do sweet fa

		cmp.l	#1,gameover_draw
		bne	game_ol_joy
		
		move.l	#0,gameover_draw
		
		movea.l	screen_adr,a0
		adda.l	#bg_gameover_p,a0
		jsr	BG_gamovrbx


		movea.l	screen_adr,a0
		adda.l	#txt_gameover_p,a0
		lea	txt_gameover,a1
		jsr	font_print
				
game_ol_joy:	jsr	joy_update					
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
		
		; save score file
		move.l	#file_scores,filename.l
		move.l	#p1_score_high,filebuffer.l
		move.l	#8,filelength.l
		jsr	writer
		
		
game_ol_fe:	move.l	#seq_menuinit,current_fx

game_ol_done:	rts
		
		
		
		
game_over:	move.l	#1,p1_gameover
		move.l	#seq_gameover,current_fx
		rts
		
		
		
				
		section data


file_scores	dc.b	'data\score.dat',0
		
txt_gameover	dc.b	'* GAME OVER *',0
txt_gameover_p	equ	(2*scr_w*73+(scr_w-13*8))	; screen offset
bg_gameover_p	equ	(2*scr_w*67)

curr_sc_pos:	equ	(2*scr_w*200+44)
high_sc_pos:	equ	(2*scr_w*200+466)

p1_scr_inc:	dc.l	10
p1_scr_inc_d:	dc.l	$10

		section bss

; game variables
paused:		ds.l	1
p1_score:	ds.l	1
p1_score_d:	ds.l	1
p1_score_high:	ds.l	1
p1_score_high_d:ds.l	1
p1_score_upd:	ds.l	1
p1_gameover:	ds.l	1
music_on:	ds.l	1
gameover_draw:	ds.l	1