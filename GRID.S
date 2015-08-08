		section text

grid_w:		equ	6
grid_h:		equ	13
grid_c:		equ	(grid_w*grid_h)
grid_s:		equ	16

grid_x:		equ	(320-(grid_s*grid_w))/2
grid_y:		equ	16

; offsets for vertical checks
grid_dir_n:	equ	(grid_w)
grid_dir_ne:	equ	(grid_w-1)
grid_dir_nw:	equ	(grid_w+1)
grid_dir_w	equ	(1)

; masks, type is bits 0-2, flags are 3-8
grid_type_mask:	equ	$7
grid_flag_mask:	equ	$f8

; flags
grid_clr1_f:	equ	$8			; masks for the two
grid_clr2_f:	equ	$10			; clear flags
grid_match_f:	equ	$20			; mask for match flag
grid_skip_f:	equ	$40			; skip flag - for now
						; this is only set when
						; a gem is falling down
						; the screen.
						

grid_type_wild:	equ	7

; flag bit numbers
grid_clr1_bit:	equ	3			; two flags because of
grid_clr2_bit:	equ	4			; double buffering
grid_clr12_bit:	equ	$18
grid_match_bit:	equ	5
grid_skip_bit:	equ	6




grid_init:	movem.l	d0/a0,-(sp)

		; clear grid to zero
		move.l	#grid_c-1,d0	
		lea	grid,a0
ig1:		move.b	#0,(a0)+
		dbf	d0,ig1
	
		movem.l	(sp)+,d0/a0
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
		



grid_random:	; intialises d0 rows to random
		; colours

		movem.l d0-d2/a0,-(sp)

		; number of squares to set
		move.l	d0,d1
		mulu.l	#grid_w,d1
		sub.l	#1,d1

		lea	grid,a0

rg1:		movem.l	d1-d2/a0-a2,-(sp)
		move.w	#17,-(sp)		; 17 is rand
		trap	#14			; call XBIOS
		addq.l	#2,sp
		movem.l	(sp)+,d1-d2/a0-a2
		and.l	#3,d0

		move.b	d0,(a0)+
		
		;addq.l	#1,d0
		;and.l	#3,d0

		dbf	d1,rg1


		movem.l	(sp)+,d0-d2/a0		
		rts




grid_update:
		movem.l d0-d6/a0-a3,-(sp)

		; pre-processing before the main update
		; for now this just clears existing flags
		; later on it should allow for double
		; buffering so logic can be run every frame

		lea	grid,a0
		move.l	#grid_c-1,d0

gu_init_loop:	btst	#grid_match_bit,(a0)	; check for match
		beq	gu_init_clear		
		move.b	#grid_clr1_f,(a0)+	; found, set clear
		dbf	d0,gu_init_loop
		bra	gu_init_done
		
gu_init_clear:	and.b	#grid_type_mask,(a0)+	; clear old flags
gu_init_skip:	dbf	d0,gu_init_loop


		; start at end of grid (bottom of screen)
		; and move values down, flagging squares
		; that need to be cleared when drawing
gu_init_done:	lea	grid,a0
		adda.l	#grid_c-1,a0
		move.l	#grid_w*(grid_h-1)-1,d0


gu_loop:	moveq.l	#0,d3
		move.b	(a0),d3
		and.b	#grid_type_mask,d3	; type of gem in d3

		cmp.b	#0,d3
		bgt	gu_skip			; skip filled squares

		move.l	a0,a1			; get square above
		suba.l	#grid_w,a1		; address into a1 

		moveq.l	#0,d4
		move.b	(a1),d4
		and.b	#grid_type_mask,d4	; type of above in d4

		cmp.b	#0,d4
		beq	gu_skip			; empty above, no-op

		move.b	d4,(a0)			; else move the type down
		or.b	#grid_skip_f,(a0)	; set skip flag for moving
		
		; BUG - skip flag should not be set for the last row!
		
		move.b	#grid_clr1_f,(a1)	; and set above to 0
		
gu_skip:	
		suba.l	#1,a0
		dbf	d0,gu_loop
		
		movem.l (sp)+,d0-d6/a0-a3
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
		lea	grid,a0

		adda.l	#grid_c-1,a0
		move.l	#grid_c-1,d0
		sub.l	#grid_w*2,d0
		
		moveq.l #0,d1		; x
		moveq.l	#0,d2		; y 
		moveq.l	#0,d3		; current value
		moveq.l	#0,d4		; track blanks in d4 so we
		moveq.l	#0,d5		; can stop on a row of blank
		

gm_loop:	move.b	(a0),d3

		btst	#grid_clr1_bit,d3	; flagged as clear?
		bne	gm_skip
		
		btst	#grid_skip_bit,d3	; flagged as skip (moving)?
		bne	gm_skip

		and.b	#grid_type_mask,d3
		cmp.b	#0,d3			; empty?
		beq	gm_skip
		
		moveq.l	#0,d6
;		cmp	#grid_h-2,d2		; check North?
;		bge	gm_west			; no, only west to do		
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

match_skip:		
		movem.l	(sp)+,d0-d6/a0-a3
		rts

		


grid_check_3:	; d3 holds current value
		; d5 holds offset to use
		; a0 points to current square
		; d6,a1-a2 are for working
		
		movem.l d6/a0-a2,-(sp)

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

; crash happening here, but only when processing
; the end of the buffer

		;or.b	#grid_match_f,d3	; got a match of 3!
gc3_setflags:	or.b	#grid_match_f,(a0)
		or.b	#grid_match_f,(a1)	; flag ready for
		or.b	#grid_match_f,(a2)	; clearing next time
								
gc3_noop:		movem.l	(sp)+,d6/a0-a2
		rts




grid_draw:	; draw fixed gems to screen
		movem.l	d0-d7/a0-a2,-(sp)

		lea	grid,a2
		
		movea.l	screen_adr,a1		; start of grid in buffer
		adda.l	#grid_x*2,a1
		adda.l	#grid_y*scr_w*2,a1

		move.l	#grid_c-1,d0		; loop counter		
		moveq.l	#0,d3			; tracks x-wrapping
		moveq.l	#0,d4


dg1:
		move.b	(a2),d4			; get type in d4

		btst	#grid_clr1_bit,d4	; need to clear?
		bne	dg_bg

		and.b	#grid_type_mask,d4

		cmp.b	#0,d4			; zero, so skip
		beq	dg_bg ; temp - draw bg to clear everything
		
		cmp.b	#1,d4			; render gem		
		beq	dg_green
	
		cmp.b	#2,d4		
		beq	dg_red
		
		; blue
		move.w	#$1f,d1
		bra	dg_draw

dg_green:	move.w	#$07e0,d1
		bra	dg_draw

dg_yellow:	move.w	#$ffe0,d1
		bra	dg_draw

dg_red:		move.w	#$f800,d1
	
dg_draw:	movea.l	a1,a0
		
		REPT	grid_s
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		move.w	d1,(a0)+
		adda.l	#scr_w*2-grid_s*2,a0
		ENDR		
	
		bra	dg_clear

dg_bg:		move.l	a1,a0
		jsr 	dg_drawbg

	
dg_clear:
		adda.l	#1,a2			; next square
		adda.l	#grid_s*2,a1		; next screen pos

		addq.l	#1,d3			; end of row?
		cmp	#grid_w,d3
		bne	dg_next

		; yep, move to next row of grid
		adda.l	#scr_w*grid_s*2-grid_w*grid_s*2,a1
		moveq.l	#0,d3

dg_next:		
		dbf	d0,dg1

		movem.l	(sp)+,d0-d7/a0-a2
		rts




dg_drawbg:	
		movem.l	d0/a0-a1,-(sp)		; draw 16x16 of bg at a0, using
						; offset based on a0-screen_adr

		lea	background,a1
		move.l	a0,d0
		sub.l	screen_adr,d0
		adda.l	d0,a1

		REPT	grid_s

		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		adda.l	#scr_w*2-grid_s*2,a0

		ENDR
		
		movem.l	(sp)+,d0/a0-a1
		rts

	section bss

grid:		ds.b	grid_w*grid_h
filler		ds.b	1