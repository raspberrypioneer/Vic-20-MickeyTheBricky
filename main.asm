;Mickey the Bricky for the Commodore Vic20 (unexpanded)
;Added sys command at the start for ease of running the program
;Due to memory limitations, removed some # characters (bricks) from the scrolling message

player_score = $033c
player_lives = $40
screen_number = $41
music_on_off = $54
player_is_alive = $28  ;0=alive, 1 is not

;Character map
hammer = 27  ;hammer character (#$1b)
bag = 28  ;bag character (#$1c)
saw = 29  ;saw character (#$1d)
headstone = 30  ;headstone character (#$1e)
wall = 31  ;wall character (#$1f)
space = 32  ;space character ($20)
ladder = 33  ;ladder character (#$21)
topladder = 34  ;top of ladder character (#$22)
brick = 35  ;platform brick character (#$23)
body_stand_right = 36  ;Micky's body standing right (#$24)
body_walk_right = 37  ;Micky's body walking right (#$25)
head_look_right = 38 ;Micky's head looking right (#$26)
copyright_circle = 39  ;Copyright circle (#$27)
body_stand_left = 40  ;Micky's body standing left (#player_is_alive)
body_walk_left = 41  ;Micky's body walking left (#$29)
head_look_left = 42 ;Micky's head looking left (#$2a)
zero_char = 48  ;zero character (#$30)

;Key Vic addresses
joystick_addr = $9111
keyboard_addr = $9120
music_speaker2 = $900b
music_speaker3 = $900c

;Allow the program to run on either an unexpanded or 8K+ expanded VIC20
USE_8k_MEMORY_LAYOUT = 1  ;0 = unexpanded memory layout or 1 = 8K+ expanded memory layout
!if USE_8k_MEMORY_LAYOUT = 1 {
!source "exp8k.asm"
} else {
!source "unexp.asm"
}
