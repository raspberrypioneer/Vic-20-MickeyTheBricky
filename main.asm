; Mickey the Bricky for the Commodore Vic20 (unexpanded)
; Written by Dave Tong and released by Firebird Software in 1984.
;
; Added sys command at the start for ease of running the program
; Due to memory limitations, removed some # characters (bricks) from the scrolling message
; Note: References in comments apply to COMPUTE! Mapping the VIC (MTV)
;
; This disassembly explains how this well-crafted game works in detail.
;--------------------------------------------------------------------------------------------------

_VIC_SCREEN_LEFT_EDGE  = $9000  ;36864 left edge of TV picture
_VIC_SOUND_ALTO        = $900b  ;36875 audio frequency generator 2
_VIC_SOUND_SOPRANO     = $900c  ;36876 audio frequency generator 3

_VIA_JOYSTICK          = $9111  ;37137 port A I/O register
_VIA_KEYB_ROWS         = $9120  ;37152 port B I/O register
_VIA_DATADIR_B         = $9122  ;37154 data direction register for port B
_VIA_DATADIR_A         = $9123  ;37155 data direction register for port A.

_IRQ_VECTOR_LOW = $0314  ;788
_IRQ_VECTOR_HIGH = $0315  ;789

;--------------------------------------------------------------------------------------------------
draw_screen_address = $0200
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
mickey_head_last_sprite = $23
mickey_body_last_sprite = $24
mickey_jump_right_same_left = $27  ;holds jump value 20 = up-right, 21 = straight-up, 22 = up-left

;same as mickey addresses above used for drawing ladders in screen draw
ladder_low = $21
ladder_high = $22

;--------------------------------------------------------------------------------------------------
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
blank_space = 43  ;space character
body_climb_ladder1 = 44  ;Mickey's body climb ladder 1
body_climb_ladder2 = 45  ;Mickey's body climb ladder 2
head_climb_ladder = 46  ;Micky's head climbing ladder
another_space = 47  ;space character used in score
zero_char = 48  ;zero character

;--------------------------------------------------------------------------------------------------
;Other
current_address_offset = 0  ;often used to point to Mickey's head address
line_below_offset = 21  ;often used to point to Mickey's body address
two_lines_below_offset = 42  ;used to point to what's below Mickey
three_lines_below_offset = 63  ;used to point to what's below Mickey

;--------------------------------------------------------------------------------------------------
;Colours
black = 0
white = 1
red = 2
cyan = 3
purple = 4
green = 5
blue = 6
yellow = 7

;--------------------------------------------------------------------------------------------------
;Allow the program to run on either an unexpanded or 8K+ expanded VIC20
;Value defined in build script
;USE_8k_MEMORY_LAYOUT = 1  ;0 = unexpanded memory layout or 1 = 8K+ expanded memory layout
!if USE_8k_MEMORY_LAYOUT = 1 {

    _SCREEN_ADDR = $1000  ;4096
    _COLOUR_SCREEN_ADDR = $9400  ;37888
    _SCREEN_TO_COLOUR_HIGH_OFFSET = $84  ;132
    _SCREEN_HIGH = $10  ;16
    _VIC_CR2_VALUE = $15
    _VIC_CR5_VALUE = $cf

* = $1201
!byte $0b,$10,$01,$00,$9e
!pet "4622"  ;SYS address of start_of_program
!byte $00,$00,$00
   brk

!source "code1.asm"
* = $1c00  ;7168
!source "spr.asm"
!source "code2.asm"  ;place code here for 8K+ memory

} else {
;--------------------------------------------------------------------------------------------------

    _SCREEN_ADDR = $1e00  ;7680
    _COLOUR_SCREEN_ADDR = $9600  ;38400
    _SCREEN_TO_COLOUR_HIGH_OFFSET = $78  ;120
    _SCREEN_HIGH = $1e  ;30
    _VIC_CR2_VALUE = $95
    _VIC_CR5_VALUE = $ff

* = $1001
!byte $0b,$10,$01,$00,$9e
!pet "4110"  ;SYS address of start_of_program
!byte $00,$00,$00
   brk

!source "code1.asm"
!source "code2.asm"  ;place code here for unexpanded memory
* = $1c00  ;7168
!source "spr.asm"

}
