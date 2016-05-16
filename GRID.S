		section text 

grid_w		equ	6
grid_h		equ	13
grid_c		equ	(grid_w*grid_h)
grid_s		equ	16

grid_x		equ	(320-(grid_s*grid_w))/2
grid_y		equ	16

grid_next_pos	equ	(((132*scr_w)+48)*2)

; offsets for vertical checks
grid_dir_n	equ	(grid_w)
grid_dir_ne	equ	(grid_w-1)
grid_dir_nw	equ	(grid_w+1)
grid_dir_w	equ	(1)

; masks, type is bits 0-2, flags are 3-8
grid_type_mask	equ	$7			; gem type mask
grid_typep_mask	equ	$f			; type & player flag mask
grid_xp_mask	equ	$f7			; exclude fplayer mask
grid_flag_mask	equ	$f8			; gem flags mask

; flags
grid_plr_f	equ	$8			; player gem flag
grid_clr_f	equ	$10			; clear flag
grid_fclr_f	equ	$20			; force clear - still draws a gem
grid_clr_both	equ	$30
grid_match_f	equ	$40			; mask for match flag
grid_static_f	equ	$80			; for gems that haven't moved

grid_fast_on	equ	$f
grid_fast_off	equ	0						


; flag bit numbers
grid_plr_bit	equ	3
grid_clr_bit	equ	4
grid_fclr_bit	equ	5
grid_match_bit	equ	6
grid_static_bit equ	7




grid_init:	movem.l	d0/a0-a2,-(sp)
		
		; initialise grid variables
		move.l	#0,grid_match_c
		move.l	grid_i_speed,grid_speed
		move.l	grid_i_delay,grid_delay
		move.l	grid_i_delay,grid_timer
		move.l	#0,grid_ticks
		move.l	#grid_fast_off,grid_fast
		
		move.b	#0,grid_inpt_rot
		move.b	#1,grid_inpt_drop
		
		; clear grid to zero
		move.l	#grid_c-1,d0	
		lea	grid,a0			; gems and flags
		lea	grid_st_draw,a1		; render state of cells
		lea	grid_st_clear,a2
ig1:		move.b	#0,(a0)+
		move.b	#0,(a1)+
		move.b	#0,(a2)+
		dbf	d0,ig1
		
		jsr	grid_next_3
		
		move.b	#0,grid_matched
		move.b	#1,grid_stable
		move.b	#1,grid_spawn
		
		move.l	#0,grid_plr_prev
		move.l	#0,grid_plr_prev+4
	
		movem.l	(sp)+,d0/a0-a2
		rts




grid_test:	movem.l a0,-(sp)
		jsr	grid_init
		lea	grid,a0
		move.b	#$42,(a0)
		adda.l	#grid_w,a0
		move.b	#$42,(a0)
		adda.l	#grid_w,a0
		move.b	#$42,(a0)
		move.b	#$41,grid+15
		move.b	#$41,grid+16
		move.b	#$41,grid+17
		
		lea	grid,a0
		adda.l	#grid_c-1,a0
		move.b	#$41,(a0)
		
		movem.l	(sp)+,a0
		rts
		



grid_plr_left:	movem.l	d0/a0-a1,-(sp)
		lea	grid_plr,a0
		cmp.b	#0,grid_plr_x(a0)	; check x-pos
		beq	gpl_done
		
		move.l	grid_plr_a(a0),a1	; see if square to the
		move.b	(a1-1),d0		; left is empty
		and.b	#grid_type_mask,d0
		cmp.b	#0,d0
		bne	gpl_done		; not empty
		
		subq.b	#1,grid_plr_x(a0)	; update player x
		move.b	grid_x_speed,grid_inpt_x
		
		move.b	(a1),(a1-1)		; move the gem
		move.b	#grid_clr_f,(a1)
		subq.l	#1,grid_plr_a(a0)	; update player address		

		cmp.b	#0,grid_plr_y(a0)	; don't update other gems
						; if first row of grid
		beq	gpl_done
		
		subq.l	#grid_w,a1		; move 2nd gem
		move.b	(a1),(a1-1)
		move.b	#grid_clr_f,(a1)
		
		cmp.b	#1,grid_plr_y(a0)
		beq	gpl_done
		
		subq.l	#grid_w,a1		; move 3rd gem
		move.b	(a1),(a1-1)
		move.b	#grid_clr_f,(a1)
		

gpl_done:	movem.l	(sp)+,d0/a0-a1
		rts




grid_plr_right:	movem.l	d0/a0-a1,-(sp)
		lea	grid_plr,a0
		cmp.b	#grid_w-1,grid_plr_x(a0)	; check x-pos
		beq	gpr_done
		
		move.l	grid_plr_a(a0),a1	; see if square to the
		move.b	(a1+1),d0		; right is empty
		and.b	#grid_type_mask,d0
		cmp.b	#0,d0
		bne	gpr_done		; not empty
		
		addq.b	#1,grid_plr_x(a0)	; update player x
		move.b	grid_x_speed,grid_inpt_x
		
		move.b	(a1),(a1+1)		; move the gem
		move.b	#grid_clr_f,(a1)
		addq.l	#1,grid_plr_a(a0)	; update player address		

		cmp.b	#0,grid_plr_y(a0)	; don't update other gems
						; if first row of grid
		beq	gpr_done
		
		subq.l	#grid_w,a1		; move 2nd gem
		move.b	(a1),(a1+1)
		move.b	#grid_clr_f,(a1)
		
		cmp.b	#1,grid_plr_y(a0)
		beq	gpr_done
		
		subq.l	#grid_w,a1		; move 3rd gem
		move.b	(a1),(a1+1)
		move.b	#grid_clr_f,(a1)

gpr_done:	movem.l	(sp)+,d0/a0-a1
	
		rts
		
		
		

grid_plr_rot:	movem.l	d1/a0-a1,-(sp)		; rotates the player gems
						; d0 determines direction
						; 0 is 'up', 1 is 'down'
		cmp.b	#1,grid_inpt_rot
		beq	grid_rot_done
		move.b	#1,grid_inpt_rot
		
		lea	grid_plr,a0
		move.l	grid_plr_a(a0),a1
		move.b	(a1),d1

		cmp.b	#2,grid_plr_y(a0)
		bge	grid_rot_std
		
		cmp.b	#1,grid_plr_y(a0)	; first or second line?
		beq	grid_rot_l2
		
		; on line one(0), one gem on screen
		cmp.b	#1,d0
		beq	grid_rot_l1d
		move.b	grid_plr_g3(a0),(a1)
		move.b	grid_plr_g2(a0),grid_plr_g3(a0)
		move.b	d1,grid_plr_g2(a0)
		bra	grid_rot_done		

grid_rot_l1d:	move.b	grid_plr_g2(a0),(a1)
		move.b	grid_plr_g3(a0),grid_plr_g2(a0)
		move.b	d1,grid_plr_g3(a0)
		bra	grid_rot_done
		
		
grid_rot_l2:	; on line two, two gems on screen
		cmp.b	#1,d0
		beq	grid_rot_l2d
		move.b	grid_plr_g3(a0),(a1)
		move.b	(a1-grid_w),grid_plr_g3(a0)
		move.b	d1,(a1-grid_w)
		bra	grid_rot_done

grid_rot_l2d:	move.b	(a1-grid_w),(a1)
		move.b	grid_plr_g3(a0),(a1-grid_w)
		move.b	d1,grid_plr_g3(a0)	
		bra	grid_rot_done
		
		
grid_rot_std:	; standard case, rotate in the grid
		cmp.b	#1,d0
		beq	grid_rot_stdd
		move.b	(a1-grid_w*2),(a1)
		move.b	(a1-grid_w),(a1-grid_w*2)
		move.b	d1,(a1-grid_w)	
		bra	grid_rot_done

grid_rot_stdd:	move.b	(a1-grid_w),(a1)
		move.b	(a1-grid_w*2),(a1-grid_w)
		move.b	d1,(a1-grid_w*2)
		
grid_rot_done:	movem.l	(sp)+,d1/a0-a1
		rts
		
		
		
				
grid_plr_inc_y:	movem.l	d0/a0-a1,-(sp)		
		lea	grid_plr,a0		
		
		cmp.l	#16,grid_plr_y_off(a0)	; if offset >= 16 then inc
		blt	g_piy_done		; otherwise skip
		
		sub.l	#16,grid_plr_y_off(a0)
				
		cmp.b	#1,grid_stable		; do nothing if stable
		beq	g_piy_done		; waiting for offset to be >= 16

		
g_piy_inc:	addq.b	#1,grid_plr_y(a0)
		add.l	#grid_w,grid_plr_a(a0)
				
		cmp.b	#2,grid_plr_y(a0)	; if we're on the 2nd or
		bgt	g_piy_done		; or 3rd row fill in other gems
		beq	g_piy_row3		; on row 3?
		
		
		move.l	grid_plr_a(a0),a1	; on row 2, so fill in next gem
		subq.l	#grid_w,a1
		move.b	grid_plr_g2(a0),(a1)
		bra	g_piy_done

g_piy_row3:	move.l	grid_plr_a(a0),a1	; on row 3, fill in last gem
		sub.l	#grid_w*2,a1
		move.b	grid_plr_g3(a0),(a1)	
		
g_piy_done:	movem.l	(sp)+,d0/a0-a1
		rts
		
		
		

grid_rand_gem:	jsr	rand		
		and.l	#15,d0
		lea	grid_randoms,a2
		adda.l	d0,a2
		cmp.b	#99,(a2)
		beq	grid_rand_gem
		move.b	(a2),d0
		addq.b	#1,d0
		rts




		; fills up the next 3 gems ready for spawning
		; grid_ran_gem trashes a2!!
grid_next_3:	movem.l	d0/a0-a2,-(sp)
		lea	grid_plr,a1
		
		jsr	grid_rand_gem
		move.b	d0,grid_plr_next(a1)	; store in the player struct
		
		jsr	grid_rand_gem
		move.b	d0,grid_plr_next+1(a1)
		
		jsr	grid_rand_gem
		move.b	d0,grid_plr_next+2(a1)
		
		movem.l	(sp)+,d0/a0-a2
		rts
		
		
		
		
grid_plr_spawn:	movem.l	d0/a0-a2,-(sp)

		lea	grid,a0			; find spawn pos
		adda.l	#3,a0
		
		move.b	(a0),d0
		and.b	#grid_type_mask,d0	; check spawn slot
		cmp.b	#0,d0
		beq	grid_ps1
		
		jsr	game_over		; occupied, therefore DEAD
		bra	grid_ps_done		

grid_ps1:	lea	grid_plr,a1
		move.b	#3,grid_plr_x(a1)	; player base x, y
		move.b	#0,grid_plr_y(a1)
		move.l	a0,grid_plr_a(a1)	; address of base gem
		move.l	#15,grid_plr_y_off(a1)	; offset to 0
		
		moveq.l	#0,d0
		
		move.b	grid_plr_next(a1),d0		
gps1test:	or.b	#grid_plr_f,d0
		move.b	d0,(a0)			; update the grid
		
		move.b	grid_plr_next+1(a1),d0
		or.b	#grid_plr_f,d0
		move.b	d0,grid_plr_g2(a1)	; appear next so the player
		
		move.b	grid_plr_next+2(a1),d0	; can still rotate through
		or.b	#grid_plr_f,d0
		move.b	d0,grid_plr_g3(a1)	; if they're not on screen
		
		jsr	grid_next_3		; setup the next 3 gems
		
		move.l	screen_adr1,a0
		jsr	grid_draw_next		; draw them... bad place?
		
		move.l	screen_adr2,a0
		jsr	grid_draw_next
	
		move.l	#grid_fast_off,grid_fast	
		move.b	#0,grid_stable
		move.b	#0,grid_spawn
				
grid_ps_done:	movem.l	(sp)+,d0/a0-a2
		rts
		



grid_update:	movem.l	d0-d5/a0-a5,-(sp)

		; update speed if required
		move.l	grid_ticks,d0
		addq.l	#1,d0
		move.l	d0,grid_ticks
		
		cmp.l	#3600,d0		; check time
		blt	grid_spawn_chk
		
		move.l	#0,grid_ticks		; reset
		
		; first decrease the delay, then adjust speed
		cmp.l	#1,grid_delay
		beq	grid_dec_spd
		subq.l	#1,grid_delay
		bra	grid_spawn_chk
		
grid_dec_spd:	cmp.l	#16,grid_speed
		bge	grid_spawn_chk
		addq.l	#1,grid_speed

grid_spawn_chk:	; if stable and no matches then spawn
		cmp.b	#1,grid_spawn
		bne	gu_input
		jsr	grid_plr_spawn
				
		
gu_input:	cmp.b	#1,grid_matched
		beq	gu_input_done
		
		moveq.l	#0,d0
		move.b	joy1,d0
		or.b	joy2,d0
				
gu_input_test:	cmp.b	#0,grid_inpt_x
		bgt	gu_input_cx
		
		btst	#2,d0
		beq	gu_input_right		
		jsr	grid_plr_left

gu_input_right:	btst	#3,d0
		beq	gu_input_up
		jsr	grid_plr_right
				
gu_input_cx:	subq.b	#1,grid_inpt_x
		
gu_input_up:	btst	#0,d0
		beq	gu_input_down
		move.l	d0,-(sp)
		move.l	#0,d0
		jsr	grid_plr_rot
		move.l	(sp)+,d0
		bra	gu_input_fire
		
gu_input_down:	btst	#1,d0
		beq	gu_input_crot
		move.l	d0,-(sp)
		move.l	#1,d0
		jsr	grid_plr_rot
		move.l	(sp)+,d0
		bra	gu_input_fire		
		
gu_input_crot:	move.b	#0,grid_inpt_rot
		
gu_input_fire:	btst	#7,d0				; drop gems
		beq	gu_input_cdrop			; clear drop flag
		
		cmp.b	#1,grid_inpt_drop
		beq	gu_input_done
		
		move.b	#1,grid_inpt_drop
		move.l	#grid_fast_on,grid_fast		; enable fast drop
		lea	grid_plr,a0
		bra	gu_input_done

gu_input_cdrop:	cmp.b	#1,grid_inpt_drop		; if drop flag is set
		bne	gu_input_cfast			; then clear & set delay
		move.b	#0,grid_inpt_drop
		move.l	grid_delay,grid_timer
			
gu_input_cfast:	move.l	#grid_fast_off,grid_fast	; clear fast flag
		
gu_input_done:	; don't do any updates while the timer
		; is counting down
		
		move.l	grid_timer,d0
		cmp.l	#0,d0
		beq	gu_init
				
		subq.l	#1,d0
		move.l	d0,grid_timer
		
		; if the counter has just hit 0
		; we're ready to go again
		
		cmp.l	#0,d0
		bne	gu_done
		
		; if we're not doing a fast drop then 
		; reset the timer according to the delay
		cmp.l	#grid_fast_on,grid_fast
		beq	gu_init
		move.l	grid_delay,grid_timer
		

gu_init:	; pre-processing before the main update
		; for now this just clears existing flags
		; later on it should allow for double
		; buffering so logic can be run every frame

		lea	grid,a0
		lea	grid_st_clear,a5
		
		move.l	#grid_c-1,d0
		
gu_init_loop:	btst	#grid_match_bit,(a0)	; check for match
		beq	gu_init_clear		
		move.b	#grid_clr_f,(a0)+	; found, set clear
		;move.b	#2,(a5)+
		dbf	d0,gu_init_loop
		bra	gu_init_done
		
gu_init_clear:	and.b	#grid_typep_mask,(a0)+	; clear flags except for
		;adda.l	#1,a5
		dbf	d0,gu_init_loop		; player flag
		bra	gu_init_done

gu_init_skip:	dbf	d0,gu_init_loop		


		; start at end of grid (bottom of screen)
		; and move values down, flagging squares
		; that need to be cleared when drawing
gu_init_done:	
		move.b	#1,grid_stable		; reset stable flag

		lea	grid,a0			; grid data
		lea	grid_st_draw,a4		; grid render state
		lea	grid_st_clear,a5	; grid clear state
		
		adda.l	#grid_c-1,a0
		adda.l	#grid_c-1,a4
		adda.l	#grid_c-1,a5
		
		move.l	#grid_w*(grid_h-1)-1,d0
		
		lea	grid_plr,a2		; update player offset
		move.l	grid_plr_y_off(a2),d5	
		add.l	grid_speed,d5
		or.l	grid_fast,d5
		move.l	d5,grid_plr_y_off(a2)


gu_loop:	moveq.l	#0,d3
		move.b	(a0),d3
		and.b	#grid_type_mask,d3	; type of gem in d3

		cmp.b	#0,d3
		beq	gu_empty		; skip filled squares		
		bra	gu_skip
		
gu_empty:	move.l	a0,a1			; get square above
		suba.l	#grid_w,a1		; address into a1 

		moveq.l	#0,d4
		move.b	(a1),d4
		
		btst	#grid_plr_bit,d4	; is gem above a player
		beq	gu_l1			; gem?
		
		cmp.l	#16,d5			; yes, so check yoff
		blt	gu_l2			; < 16 so skip
						; (but still unstable)
						
gu_l1:		and.b	#grid_type_mask,d4	; type of above in d4

		cmp.b	#0,d4
		beq	gu_skip			; empty above, no-op

		move.b	(a1),d4
		and.b	#grid_typep_mask,d4	; else move the gem down
		move.b	d4,(a0)			; with the player flag bit
		or.b	#grid_fclr_f,(a0)	; force clear before draw
		move.b	#grid_clr_f,(a1)	; and set above to 0 with clear
		move.b	#2,(a5-grid_w)		
;s		move.b	#0,(a5)			; remove clear
		move.b	#2,(a4)			; draw over two frames
		
gu_l2:		move.b	#0,grid_stable		; clear stable flag
		
gu_skip:	
		suba.l	#1,a0
		suba.l	#1,a4
		suba.l	#1,a5
		dbf	d0,gu_loop
	

		; after main update loop
		
		lea	grid_plr,a0		; see if player gems have dropped
		cmp.l	#16,grid_plr_y_off(a0)	
		blt	gu_done			; nope, do nothing else
				
		cmp.b	#1,grid_stable		; is the grid stable
		bne	gu_unstable		; nope, still falling
				
		jsr	grid_matches		; check for matches
		move.l	#0,grid_plr_y_off(a0)	; clear the player offset
		
		lea	grid,a0			; stable so clear static 
		move.l	#grid_c-1,d0		; and player flags for
						; player gems
gu_s_loop:	btst	#grid_plr_bit,(a0)
		beq	gu_s_loop_s
		
;**************
;**************
;Clear static state here?

		and.b	#$77,(a0)		

gu_s_loop_s:	addq.l	#1,a0
		dbf	d0,gu_s_loop
		
		
		cmp.b	#0,grid_matched		; stable, if no matches spawn
		beq	gu_spawn
		
		jsr	sfx_match
		bra	gu_done
		
		
gu_spawn:	jsr	sfx_drop
		move.b	#1,grid_spawn
		
gu_unstable:	jsr	grid_plr_inc_y		; otherwise increment player y		

gu_done:	
		movem.l (sp)+,d0-d5/a0-a5
		rts



; Match testing
;
; Looping throught he array backwards so x & y are based
; on an origin in the bottom right, confusing the east
; and west checks
;
; Test Direction |  Condition
;================|=============
;	E	 | x > 1
;	W	 | x < (w - 2)
;	N	 | y < (h - 2)
;
;	NE	 | N && E
;	NW	 | N && W
;
; Only need to check four directions as these cover the rest
; automatically. W, NW, N, and NE are all substractions when
; working backwards through the grid so use those ease.



grid_matches:	movem.l	d0-d6/a0-a3,-(sp)
		
		; start at end (bottom right)
		; don't need to check the last two rows as
		; they'll be covered by the other tests
gm_start:	lea	grid,a0

		move.b	#0,grid_matched	; reset the overall match flag

		adda.l	#grid_c-1,a0
		move.l	#grid_c-1,d0
		sub.l	#grid_w*2,d0
		
		moveq.l #0,d1		; x
		moveq.l	#0,d2		; y 
		moveq.l	#0,d3		; current value
		moveq.l	#0,d4		; track blanks in d4 so we
		moveq.l	#0,d5		; can stop on a row of blank
		

gm_loop:	move.b	(a0),d3

		btst	#grid_clr_bit,d3	; flagged as clear?
		bne	gm_skip
		
		and.b	#grid_type_mask,d3
		cmp.b	#0,d3			; empty?
		beq	gm_skip
		
		moveq.l	#0,d6
		move.l	#grid_dir_n,d5
		jsr 	grid_check_3

		cmp	#1,d1			; north east?
		ble	gm_north_west		; no, check nw
		move.l	#grid_dir_ne,d5
		jsr 	grid_check_3
		
		
gm_north_west:	cmp	#grid_w-2,d1		; no nw, so no west
		bge	gm_skip
		move.l	#grid_dir_nw,d5		; both nw & w
		jsr	grid_check_3
		move.l	#grid_dir_w,d5
		jsr	grid_check_3
		bra	gm_skip


gm_west:	cmp	#grid_w-2,d1			; check west?
		bge	gm_skip
		move	#grid_dir_w,d5
		jsr	grid_check_3
		
		
gm_skip:	addq.l	#1,d1
		cmp.l	#grid_w,d1
		bne	gm_noinc	; end of row?
		
		moveq.l	#0,d1		; reset x
		addq.l	#1,d2		; inc y
gm_noinc:
		addq.l	#1,d4
		suba.l	#1,a0		; next gem
		dbf	d0,gm_loop		

		; set the timer to run whether there was a match
		; or not so there's a gap before the player's
		; next gems drop.
		move.l	#8,grid_timer
		cmp.b	#1,grid_matched
		bne	match_skip
		add.l	#24,grid_timer
		move.l	#grid_fast_on,grid_fast
			
match_skip:	movem.l	(sp)+,d0-d6/a0-a3
		rts

		


grid_check_3:	; d3 holds current value
		; d5 holds offset to use
		; a0 points to current square
		; d6,a1-a2 are for working
		
		movem.l d0/d6/a0-a2,-(sp)

		move.l	a0,a1
		
		suba.l	d5,a1
		move.l	#0,d6
		move.b	(a1),d6
		and.l	#grid_type_mask,d6

		cmp	d6,d3
		bne	gc3_noop		; no match	

		move.l	a1,a2
		suba.l	d5,a2
		move.b	(a2),d6
		and.b	#grid_type_mask,d6

		cmp	d6,d3
		bne	gc3_noop		; no match
		beq	gc3_setflags


gc3_setflags:	or.b	#grid_match_f,(a0)	; match!
		or.b	#grid_match_f,(a1)	; flag ready for
		or.b	#grid_match_f,(a2)	; clearing next time
		
		jsr	game_inc_scr		; increment score, 10 per
						; group of 3, so 4=20, 5=30
		addq.l	#1,grid_match_c		; inc. grid match count
		move.b	#1,grid_matched		; set global flag
								
gc3_noop:	movem.l	(sp)+,d0/d6/a0-a2
		rts




grid_draw:	; draw gems to screen
		movem.l	d0-d7/a0-a5,-(sp)
		
		lea	grid_plr,a2
		moveq.l	#0,d0
		move.l	grid_plr_y_off(a2),d0
		move.l	d0,d5			; keep the offset
		
		lea	grid,a2
		lea	grid_st_draw,a4
		lea	grid_st_clear,a5	
		
		movea.l	screen_adr,a1		; start of grid in buffer
		adda.l	#grid_x*2,a1
		adda.l	#grid_y*scr_w*2,a1

		move.l	screen_adr,a0		; clear player gems from
		move.l	grid_plr_prev+4,d0	; previous location
		cmp.l	#0,d0
		beq	dg_loop_init		
		
		adda.l	d0,a0			; previous location
		jsr	dg_drawbg
		
		suba.l	#scr_w*grid_s*2,a0
		cmp.l	screen_adr,a0
		blt	dg_loop_init
		jsr	dg_drawbg
	
		suba.l	#scr_w*grid_s*2,a0
		cmp.l	screen_adr,a0
		blt	dg_loop_init
		jsr	dg_drawbg
		

dg_loop_init:	; update offset buffer (if double buffering)
		move.l	grid_plr_prev,grid_plr_prev+4
		
		; clear in case there are no more player gems
		move.l	#0,grid_plr_prev

		move.l	#grid_c-1,d2		; loop counter		
		moveq.l	#0,d3			; tracks x-wrapping
		moveq.l	#0,d4


dg1:
		move.b	(a2),d4			; get gem in d4
		movea.l	a1,a0

		;btst	#grid_clr_bit,d4	; need to clear?
		;bne	dg_bg
		
		cmp.b	#0,(a5)
		beq	dg_chk_match
		subq.b	#1,(a5)
		jsr	dg_drawbg

				
dg_chk_match:	btst	#grid_match_bit,d4	; matched?
		bne	dg_match
						
		btst	#grid_plr_bit,d4	; player gem? add offset	
		beq	dg_clear_chk		; gem is offset from above
						; unless the grid is stable
						; and then draw where they are
		cmp.l	#1,grid_stable
		beq	dg_clear_chk			
		
		suba.l	#scr_w*2*16,a0		; > 0 so do offset
		move.l	d5,d6
		mulu.l	#scr_w*2,d6		
		adda.l	d6,a0
		
		move.l	a0,d7			; store gem screen offset
		sub.l	screen_adr,d7		; from start of screen
		move.l	d7,grid_plr_prev
		
		
		bra	dg_type
		
dg_clear_chk:	btst	#grid_fclr_bit,d4	; clear bg if force flag
		beq	dg_draw_chk		; is set
		jsr	dg_drawbg	
		movea.l	a1,a0
		bra	dg_type
		
dg_draw_chk:	cmp.b	#0,(a4)			; two frames of draw for static
		beq	dg_clear
		subq.b	#1,(a4)
		
dg_type:	and.b	#grid_type_mask,d4
		cmp.b	#0,d4
		beq	dg_clear

		movea.l	#grid_spr_firsts,a3
		movea.l	0(a3,d4.l*4),a3
		jsr	(a3)
		bra	dg_clear

		

dg_match:	; gems have been matched to do animations

		move.l	a1,a0			; get anim frame
		move.l	#32,d0		 
		sub.l	grid_timer,d0
		cmp.l	#17,d0			; only have 8 frames
		bgt	dg_clear
		lsr	#1,d0
		
		jsr	dg_drawbg
		move.l	a1,a0
		
		cmp.l	#8,d0			; clears last frame
		beq	dg_clear

		and.b	#grid_type_mask,d4
		;cmp.b	#0,d4
		;beq	dg_clear

		movea.l	#grid_spr_maps,a3	; find the map to use
		movea.l	0(a3,d4.l*4),a3
		jsr	grid_draw_gem
		bra	dg_clear		
		

dg_bg:		move.l	a1,a0
		jsr 	dg_drawbg

	
dg_clear:
		adda.l	#1,a2			; next square
		adda.l	#1,a4			; next in state buffers
		adda.l	#1,a5		
		adda.l	#grid_s*2,a1		; next screen pos

		addq.l	#1,d3			; end of row?
		cmp	#grid_w,d3
		bne	dg_next

		; yep, move to next row of grid
		adda.l	#scr_w*grid_s*2-grid_w*grid_s*2,a1
		moveq.l	#0,d3

dg_next:		
		dbf	d2,dg1
		
		
		lea.l	grid_plr,a2		; if the player is on the first
		cmp.b	#2,grid_plr_y(a2)	; 3 rows the bg needs to be cleared
		bgt	dg_done			; above to clip the player gems

dg_brk:		move.l	screen_adr,a0
		move.l	a0,a1
		moveq.l	#0,d0
		move.b	grid_plr_x(a2),d0	; x-pos
		lsl.l	#5,d0			; * 16
		adda.l	d0,a0
		adda.l	#grid_x*2,a0
		
		jsr	dg_drawbg

dg_done:	movem.l	(sp)+,d0-d7/a0-a5
		rts




dg_drawbg:	movem.l	d0-d1/a0-a1,-(sp)		; draw 16x16 of bg at a0, using
						; offset based on a0-a1
		move.l	a0,d0			; where a1 = screen buffer to use
		;sub.l	a1,d0
		sub.l	screen_adr,d0
		
		lea	background,a1
		adda.l	d0,a1
		
		move.l	#3,d1

dg_bg_loop:
		REPT	grid_s/4

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		adda.l	#scr_w*2-grid_s*2,a0
		adda.l	#scr_w*2-grid_s*2,a1

		ENDR
		
		dbf	d1,dg_bg_loop
		
		movem.l	(sp)+,d0-d1/a0-a1
		rts




grid_clear:	movem.l	d0-d2/a0-a1,-(sp)	; draw the grid part of the bg

		move.l	screen_adr,a0
		lea	background,a1
		
		adda.l	#scr_w*grid_s*2,a0
		adda.l	#scr_w*grid_s*2,a1
		
		move.l	#(scr_w-grid_s*grid_w)*2,d1
		move.l	#grid_s*grid_h,d2
		
		adda.l	#grid_x*2,a0		; start of grid
		adda.l	#grid_x*2,a1

gc_loop:		
		REPT 	grid_s*grid_w/2		; 96 bytes
		;move.l	(a1)+,(a0)+
		move.l	#$fabcfabc,(a0)+
		ENDR
		
		adda.l	d1,a0
		adda.l	d1,a1
				
		dbf	d2,gc_loop

		movem.l	(sp)+,d0-d2/a0-a1
		rts
		



grid_draw_next:	movem.l	d0-d2/a0-a4,-(sp)	; draws the next 3 gems into 
						; the screen buffer at a0
								
		move.l	#scr_w*16*2,d2		; offset for each square
		movea.l	screen_adr,a0
		move.l	a0,a1			; copy screen buffer to a1
		adda.l	#grid_next_pos,a0
		move.l	a0,a3
				
		lea	grid_plr,a4
		moveq.l	#0,d0
		lea	grid_spr_firsts,a2	; map of sprites
		
		move.b	grid_plr_next+2(a4),d0	; find the right entry in the main
		cmp.b	#0,d0
		beq	gdn_done
		
		lsl	#2,d0			; index into sprite map
		adda.l	d0,a2
		move.l	(a2),a2			; draw bg then sprite!
		jsr	dg_drawbg		
		jsr	(a2)
		
		adda.l	d2,a3			; screen offset
		move.l	a3,a0
		
		move.b	grid_plr_next+1(a4),d0	; get the next gem
		lsl	#2,d0			
		lea	grid_spr_firsts,a2
		adda.l	d0,a2
		move.l	(a2),a2
		jsr	dg_drawbg			
		jsr	(a2)
		
		adda.l	d2,a3
		move.l	a3,a0
		
		move.b	grid_plr_next(a4),d0	; and the last
		lsl	#2,d0		
		lea	grid_spr_firsts,a2
		adda.l	d0,a2
		move.l	(a2),a2
		jsr	dg_drawbg		
		jsr	(a2)
		
				
gdn_done:	movem.l	(sp)+,d0-d2/a0-a4
		rts
			
		
		
				
grid_draw_gem:					; draws gem sprite from
		cmp.l	#8,d0			; map in a3, using frame
		blt	gdg1			; in d0
		move.l	#7,d0
			
gdg1:		lsl	#2,d0
		adda.l	d0,a3
		move.l	(a3),a3
		jsr	(a3)
		rts
		



	section	data


grid_spr_maps	dc.l	0,red_map,yellow_map,purple_map,green_map,blue_map
grid_spr_firsts	dc.l	0,red0,yellow0,purple0,green0,blue0

grid_i_speed	dc.l	1	; initial speed
grid_i_delay	dc.l	1
grid_x_speed	dc.b	4


grid_randoms	dc.b	0,1,2,3,4,0,1,2,3,4,0,1,2,3,4,99

	section bss
		

grid_plr_s	equ	16
		
		rsreset
grid_plr_y_off	rs.l	1	; current-y-offset (change to byte?)
grid_plr_x	rs.b	1	; coords of bottom gem
grid_plr_y	rs.b	1
grid_plr_g2	rs.b	1	; 2nd and 3rd gem generated on spawn
grid_plr_g3	rs.b	1	; need them ready for rotation
grid_plr_next	rs.b	3	; next 3 gems (used for display)
grid_plr_res	rs.b	1	; reserved
grid_plr_a	rs.l	1	; current address of bottom gem


grid_plr	ds.b	grid_plr_s

grid_plr_prev	ds.l	2	; last two screen offsets for player

grid_inpt_x	ds.b	1	; rate limiter for x-movement
grid_inpt_rot	ds.b	1	; used to ensure distinct presses
grid_inpt_drop	ds.b	1	; for rotation and dropping

grid_speed	ds.l	1
grid_delay	ds.l	1
grid_ticks	ds.l	1

grid_fast	ds.l	1
grid_match_c	ds.l	1


grid_spawn	ds.b	1
grid_matched	ds.b	1

grid_timer	ds.l	1
grid		ds.b	grid_w*grid_h
grid_st_draw	ds.b	grid_w*grid_h		; draw state
grid_st_clear	ds.b	grid_w*grid_h		; clear state
grid_stable	ds.b	1

	section	text