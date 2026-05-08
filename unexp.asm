screen_ram = $1e00  ;7680
colour_ram = $9600  ;38400
screen_ptr1 = $95
screen_ptr2 = $ff
screen_high = $1e
screen_to_colour_high = $78

* = $1001
 !byte $0b,$10,$01,$00,$9e,$34,$31,$31,$30,$00,$00,$00  ;sys4110 i.e. $100E
;Note                  sys   4   1   1   0            is sys4110
   brk

!source "code1.asm"
!source "code2.asm"  ;place code here for unexpanded memory
* = $1C00  ;7168
!source "spr.asm"
