;Mickey the Bricky for the Commodore Vic20 (unexpanded)
;Added sys command at the start for ease of running the program
;Due to memory limitations, removed some # characters (bricks) from the scrolling message
; Note: References in comments apply to COMPUTE! Mapping the VIC (MTV)

_SOUND2 = $900b  ;36875
_SOUND3 = $900c  ;36876
_DATADIR_B = $9122  ;37154
_DATADIR_A = $9123  ;37155
_JOYSTICK = $9111  ;37137
_KEYB_COLS = $9120  ;37152
_VICCR0 = $9000  ;36864
_IRQ_VECTOR_LOW = $0314  ;788
_IRQ_VECTOR_HIGH = $0315  ;789

;-----------------------------------------------------------------------------------
player_score = $033c
player_lives = $40
screen_number = $41
music_on_off = $54
player_is_alive = $28  ;0=alive, 1 is not
barrel_delay_x = $56  ;barrel delay / speed
sound_pointer = $ff  ;sound data pointer
sound_delay1 = $fd
sound_delay2 = $fe

barrel1_low = $11
barrel1_high = $12
barrel2_low = $16
barrel2_high = $17
barrel3_low = $1b
barrel3_high = $1c
jump_allowed = $20
mickey_low = $21
mickey_high = $22

;-----------------------------------------------------------------------------------
;Character map
barrel = 0  ;barrel character
hammer = 27  ;hammer character
bag = 28  ;bag character
saw = 29  ;saw character
headstone = 30  ;headstone character
wall = 31  ;wall character
space = 32  ;space character
ladder = 33  ;ladder character
topladder = 34  ;top of ladder character
brick = 35  ;platform brick character
body_stand_right = 36  ;Micky's body standing right
body_walk_right = 37  ;Micky's body walking right
head_look_right = 38 ;Micky's head looking right
copyright_circle = 39  ;Copyright circle
body_stand_left = 40  ;Micky's body standing left (#player_is_alive)
body_walk_left = 41  ;Micky's body walking left
head_look_left = 42 ;Micky's head looking left
head_climb_ladder = 46  ;Micky's head climbing ladder
another_space = 47  ;space character used in score
zero_char = 48  ;zero character (#$30)

;-----------------------------------------------------------------------------------
;Colours
black = 0
white = 1
red = 2
cyan = 3
purple = 4
green = 5
blue = 6
yellow = 7

;-----------------------------------------------------------------------------------
;Allow the program to run on either an unexpanded or 8K+ expanded VIC20
;Value defined in build script
;USE_8k_MEMORY_LAYOUT = 1  ;0 = unexpanded memory layout or 1 = 8K+ expanded memory layout
!if USE_8k_MEMORY_LAYOUT = 1 {

    _SCREEN_ADDR = $1000  ;4096
    _COLOUR_SCREEN_ADDR = $9400  ;37888
    _OFFSET_TO_COLOUR_RAM = $84  ;132
    _SCREEN_HIGH = $10  ;16
    _VICCR2_VALUE = $15
    _VICCR5_VALUE = $cf

* = $1201
 !byte $0b,$10,$01,$00,$9e,$34,$36,$32,$32,$00,$00,$00  ;sys4622 ($120e) to start_of_program
;Note                  sys   4   6   2   2            is sys4622
   brk

!source "code1.asm"
* = $1c00  ;7168
!source "spr.asm"
!source "code2.asm"  ;place code here for 8K+ memory

} else {
;-----------------------------------------------------------------------------------

    _SCREEN_ADDR = $1e00  ;7680
    _COLOUR_SCREEN_ADDR = $9600  ;38400
    _OFFSET_TO_COLOUR_RAM = $78  ;120
    _SCREEN_HIGH = $1e  ;30
    _VICCR2_VALUE = $95
    _VICCR5_VALUE = $ff

* = $1001
 !byte $0b,$10,$01,$00,$9e,$34,$31,$31,$30,$00,$00,$00  ;sys4110 ($100e) to start_of_program
;Note                  sys   4   1   1   0            is sys4110
   brk

!source "code1.asm"
!source "code2.asm"  ;place code here for unexpanded memory
* = $1c00  ;7168
!source "spr.asm"

}
