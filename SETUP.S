
		section text
		
setup_all:	jsr 	bg_init
		jsr	font_load
		jsr	game_pre_init
		
		move.l	#seq_menuinit,current_fx
		
		rts
		
