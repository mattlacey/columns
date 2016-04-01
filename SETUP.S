
		section text
		
setup_all:	move.l	#0,ticks		; clear ticks
		
		jsr 	bg_init
		jsr	font_load
		jsr	sfx_init
		
		move.l	#seq_menuinit,current_fx
		
		rts
		
