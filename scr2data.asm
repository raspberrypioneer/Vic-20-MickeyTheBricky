;screen locations for ladders, barrels, etc
data_for_screen_2_setup

; 11x ladders
!byte $95, _SCREEN_HIGH
!byte $ea, _SCREEN_HIGH
!byte $3d, _SCREEN_HIGH+1
!byte $92, _SCREEN_HIGH+1
!byte $b1, _SCREEN_HIGH+1
!byte $9a, _SCREEN_HIGH
!byte $23, _SCREEN_HIGH+1
!byte $4c, _SCREEN_HIGH
!byte $de, _SCREEN_HIGH
!byte $f2, _SCREEN_HIGH-1
!byte $f3, _SCREEN_HIGH-1

screen_2_runtime_state
!byte $00  ;unused: indexed copy deliberately starts with the following byte
!byte barrel_direction_right
!byte $34, _SCREEN_HIGH  ;barrel 1 screen address
!byte space, barrel_direction_right
!byte barrel_direction_left
!byte $cb, _SCREEN_HIGH  ;barrel 2 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $9a, _SCREEN_HIGH+1  ;barrel 3 screen address
!byte space, barrel_direction_right
!byte $00, $00  ;unused state and jump-in-progress flag
!byte $ba, _SCREEN_HIGH+1  ;Mickey screen address
!byte $14, $14  ;characters initially underneath Mickey's head and body
