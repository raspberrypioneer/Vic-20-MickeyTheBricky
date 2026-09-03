;screen locations for ladders, barrels, etc
data_for_screen_4_setup

; 11x ladders
!byte $4e, _SCREEN_HIGH
!byte $96, _SCREEN_HIGH
!byte $ee, _SCREEN_HIGH
!byte $3e, _SCREEN_HIGH+1
!byte $91, _SCREEN_HIGH+1
!byte $9e, _SCREEN_HIGH
!byte $f8, _SCREEN_HIGH
!byte $48, _SCREEN_HIGH+1
!byte $a0, _SCREEN_HIGH+1
!byte $f2, _SCREEN_HIGH-1
!byte $f3, _SCREEN_HIGH-1

screen_4_runtime_state
!byte $00  ;unused: indexed copy deliberately starts with the following byte
!byte barrel_direction_right
!byte $35, _SCREEN_HIGH  ;barrel 1 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $de, _SCREEN_HIGH  ;barrel 2 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $86, _SCREEN_HIGH+1  ;barrel 3 screen address
!byte space, barrel_direction_right
!byte $00, $00  ;unused state and jump-in-progress flag
!byte $ba, _SCREEN_HIGH+1  ;Mickey screen address
!byte $14, $14  ;characters initially underneath Mickey's head and body
