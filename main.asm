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
music_disabled = $54  ;0 = play music, nonzero = disabled
player_death_pending = $28  ;0 = alive, nonzero = kill player on the next collision check
frame_delay = $56  ;main-loop delay controlling barrel and player speed
music_note_index = $ff
music_delay_reload = $fd
music_delay_counter = $fe

;Temporary five-byte barrel record used by do_barrel_move
barrel_move_mode = $00  ;0 = right, 1 = down, 2 = left
barrel_screen_low = $01
barrel_screen_high = $02
barrel_under_character = $03
barrel_resume_direction = $04
barrel_colour_low = $05
barrel_colour_high = $06

barrel_direction_right = 0
barrel_direction_down = 1
barrel_direction_left = 2

;Persistent five-byte barrel records populated by each screen's setup block
barrel1_move_mode = $10
barrel1_low = $11
barrel1_high = $12
barrel1_under_character = $13
barrel1_resume_direction = $14
barrel2_move_mode = $15
barrel2_low = $16
barrel2_high = $17
barrel2_under_character = $18
barrel2_resume_direction = $19
barrel3_move_mode = $1a
barrel3_low = $1b
barrel3_high = $1c
barrel3_under_character = $1d
barrel3_resume_direction = $1e

screen_setup_destination_minus_one = $0f  ;indexed copy starts at offset 1, address $10
screen_setup_unused = $1f
jump_in_progress = $20
mickey_low = $21
mickey_high = $22
mickey_head_under_character = $23
mickey_body_under_character = $24
jump_return_delta = $27  ;20 = return down-left, 21 = straight down, 22 = down-right

general_counter = $50
scroll_delay = $51
mickey_new_head_character = $55
saved_x = $58
treasure_colour_low = $60
treasure_colour_high = $61
screen_state_30 = $30  ;initialised to 27 by every screen; wider purpose not yet established

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
body_stand_right = 36  ;Mickey's body standing right
body_walk_right = 37  ;Mickey's body walking right
head_look_right = 38 ;Mickey's head looking right
copyright_circle = 39  ;Copyright circle
body_stand_left = 40  ;Mickey's body standing left
body_walk_left = 41  ;Mickey's body walking left
head_look_left = 42 ;Mickey's head looking left
blank_space = 43  ;space character
body_climb_ladder1 = 44  ;Mickey's body climb ladder 1
body_climb_ladder2 = 45  ;Mickey's body climb ladder 2
head_climb_ladder = 46  ;Mickey's head climbing ladder
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

!if start_of_program != $120e { !error "8K BASIC SYS address no longer matches start_of_program" }
!if data_for_redefined_characters != $1c00 { !error "Character data must start at $1c00" }
!if draw_screen_2 != $1e00 { !error "8K code2 must start at $1e00" }

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

!if start_of_program != $100e { !error "Unexpanded BASIC SYS address no longer matches start_of_program" }
!if draw_screen_2 != $196b { !error "Unexpanded code2 address changed" }
!if data_for_redefined_characters != $1c00 { !error "Character data must start at $1c00" }

}
