; Falcon demosystem
;
; January 13, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; loader.s

; in:   filename.l = address to filename (null term)
;     filebuffer.l = destination address


		even

; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------

loader:		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok					;ok
		move.l	#exit_filenotfound_text,error_adr	;error message
		bra.w	exit					;

.ok:		move.l	dta+26,filelength			;filelength

		move.w	#0,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber
 
		move.l	filebuffer,-(sp)			;buffer address
		move.l	filelength,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		;move.l	filebuffer,a0				;ice depack (autodetect)
		;jsr	ice_decrunch_2				;

		clr.l	filename

		rts



writer:		move.w	#0,-(sp)				;fsfirst() get fileinfo
		move.l	filename,-(sp)				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	w_fopen					;file exists
		
		move.w	#0,-(sp)
		move.l	filename,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,filenumber
		bra	w_fwrite				;fcreate
		

w_fopen:	move.w	#1,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber
		
w_fwrite:	move.l	filebuffer,-(sp)			;buffer address
		move.l	filelength,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$40,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;
								;fclose		
		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;
 		
		rts
		
		
		
		
; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even

filenumber:	ds.w	1
filename:	ds.l	1
filelength:	ds.l	1
filebuffer:	ds.l	1

		even

; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------
