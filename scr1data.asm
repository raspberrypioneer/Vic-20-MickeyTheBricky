;screen locations for ladders, barrels, etc
data_for_screen_1_setup

; 8x ladders
!byte $f3, _SCREEN_HIGH-1
!byte $f4, _SCREEN_HIGH-1
!byte $3f, _SCREEN_HIGH+1
!byte $9f, _SCREEN_HIGH+1
!byte $46, _SCREEN_HIGH
!byte $4c, _SCREEN_HIGH
!byte $97, _SCREEN_HIGH
!byte $f7, _SCREEN_HIGH

screen_1_runtime_state
!byte $00  ;unused: indexed copy deliberately starts with the following byte
!byte barrel_direction_right
!byte $35, _SCREEN_HIGH  ;barrel 1 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $de, _SCREEN_HIGH  ;barrel 2 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $84, _SCREEN_HIGH+1  ;barrel 3 screen address
!byte space, barrel_direction_right
!byte $00, $00  ;unused state and jump-in-progress flag
!byte $ba, _SCREEN_HIGH+1  ;Mickey screen address
!byte $14, $14  ;characters initially underneath Mickey's head and body
