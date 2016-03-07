		
		section text
		
		
main_menu_init:	movem.l	a0-a1,-(sp)

		jsr	bg_draw
		
		move.b	#0,mm_curr
		move.b	#0,mm_mov_t

		movea.l	screen_adr,a0
		adda.l	#mm_pos,a0
		lea	txt_mm_play,a1
		jsr	font_print
		
		adda.l	#(scr_w*16*2)-(txt_mm_play_l*8*2),a0
		lea	txt_mm_diff,a1
		jsr	font_print
		
		adda.l	#(scr_w*16*2)-(txt_mm_diff_l*8*2),a0
		lea	txt_mm_quit,a1
		jsr	font_print
		
		move.l	#seq_menuloop,current_fx
		
		movem.l	(sp)+,a0-a1
		rts		
		
		
		
		
main_menu_loop:	movem.l	d0/a0-a1,-(sp)

		jsr	main_menu_cur		; trashes a1 so do first
		lea	background,a1
		move.l	a0,d0			; find the offset to
		sub.l	screen_adr,d0		; add to the bg addr
		adda.l	d0,a1
		jsr	red0clear
		
		cmp.b	#0,mm_mov_t
		bgt	mml_skip

		moveq.l	#0,d0			
		move.b	joy1,d0
		or.b	joy2,d0

		btst	#J_UP,d0		; move cursor up
		beq	mml_down
		move.b	#16,mm_mov_t
		cmp.b	#0,mm_curr
		beq	mml_up_wrap
		sub.b	#1,mm_curr
		move.b	#16,mm_mov_t
		bra	mml_done
		
mml_down:	btst	#J_DOWN,d0		; cursor down
		beq	mml_fire
		move.b	#16,mm_mov_t
		cmp.b	#mm_count-1,mm_curr
		beq	mml_dn_wrap
		add.b	#1,mm_curr
		bra	mml_done	
		
mml_up_wrap:	move.b	mm_count-1,mm_curr	; wrapping
		bra	mml_done

mml_dn_wrap:	move.b	#0,mm_curr
		bra	mml_done
		
mml_fire:	btst	#7,d0
		beq	mml_done
		
		cmp.b	#0,mm_curr
		bne	mml_diff
		move.l	#seq_gameinit,current_fx
		bra	mml_done
		
mml_diff:	cmp.b	#1,mm_curr
		bne	mml_quit
		bra	mml_done
		
mml_quit:	cmp.b	#2,mm_curr
		move.l	#seq_exit,current_fx
		bra	mml_done
		
mml_skip:	sub.b	#1,mm_mov_t

mml_done:	jsr	main_menu_cur
		jsr	red0

		movem.l	(sp)+,d0/a0-a1
		rts
	
		
		

main_menu_cur:
		movea.l	screen_adr,a0
		moveq.l	#0,d0			; get cursor pos
		move.b	mm_curr,d0
		lsl.l	#2,d0			; shift for longs
		movea.l	#mm_cur_off,a1		; LUT
		adda.l	0(a1,d0.l),a0		; add offset
		rts



		
main_menu_draw:	rts




		section data

mm_pos		equ	(2*scr_w*100+2*150)
mm_cur_pos	equ	(2*scr_w*96+2*130)

mm_cur_off	dc.l	mm_cur_pos,mm_cur_pos+(2*scr_w*16),mm_cur_pos+(4*scr_w*16)
		
txt_mm_play	dc.b	'PLAY',0
txt_mm_play_l	equ	4
txt_mm_diff	dc.b	'TODO',0
txt_mm_diff_l	equ	4
txt_mm_quit	dc.b	'QUIT',0
txt_mm_quit_l	equ	4

mm_count	equ	3

txt_diff_easy	dc.b	'EASY',0
txt_diff_medium	dc.b	'HARD',0

mm_curr		ds.b	1
mm_mov_t	ds.b	1

