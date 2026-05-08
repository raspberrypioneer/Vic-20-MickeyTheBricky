;################################################################################
draw_screen_2
   jsr clear_screen

   ldy #3
   ldx #0
   lda #brick  ;platform brick character
.draw_platform_screen_2
   sta screen_ram+152,y
   sta screen_ram+362,y
   sta screen_ram+373,y
   sta screen_ram+289,y
   sta screen_ram+365,x
   sta screen_ram+224,x
.draw_more_platform_screen_2
   sta screen_ram+400,y
   sta screen_ram+316,y
   sta screen_ram+232,y
   sta screen_ram+148,y
   sta screen_ram+221,y
   sta screen_ram+431,y
   clc
   txa
   adc #22
   tax
   lda #brick  ;platform brick character
   dey
   beq .draw_more_platform_screen_2
   bpl .draw_platform_screen_2
   sta screen_ram+394
   sta screen_ram+414
   ldy #10
.draw_even_more_platform_screen_2
   sta screen_ram+68,y
   sta screen_ram+483,y
   sta screen_ram+493,y
   dey
   bpl .draw_even_more_platform_screen_2
   ldx #0
.draw_all_ladders_screen_2
   lda data_for_screen_2_setup, x
   sta $21
   inx
   lda data_for_screen_2_setup, x
   sta $22
   jsr draw_single_ladder
   inx
   cpx #22
   bne .draw_all_ladders_screen_2
   jsr colour_in_platforms
   ldy #hammer  ;hammer character
   sty screen_ram+214
   iny  ;bag character
   sty screen_ram+271
   iny  ;saw character
   sty screen_ram+134
   ldy #3  ;colour cyan
   sty colour_ram+134
   iny  ;colour purple
   sty colour_ram+214
   iny  ;colour green
   sty colour_ram+271
   ldx #5
   jsr draw_player_score

   ldx #21
.get_screen_2_data
   lda data_for_screen_2_setup+22, x
   sta $0f,x
   dex
   bne .get_screen_2_data
   lda #0  ;barrel character
   tay
   sta ($11),y  ;draw barrel character
   sta ($16),y  ;draw barrel character
   sta ($1b),y  ;draw barrel character
   lda #$1b
   sta $30
   ldy #4
   jsr draw_basic_screen
   lda #space  ;space character
   sta screen_ram+475
   lda #0
   sta player_is_alive
   rts

!source "scr2data.asm"

;################################################################################
draw_screen_3
  jsr clear_screen

  ldx #0
.get_screen_3_data
  lda data_for_screen_3_setup,x
  tay
  inx
  lda data_for_screen_3_setup,x
  sta $21
  inx
  lda data_for_screen_3_setup,x
  sta $22
  lda #brick  ;platform brick character
.draw_platform_screen_3
  sta ($21),y
  dey
  bne .draw_platform_screen_3
  inx
  cpx #24
  bne .get_screen_3_data
  ldx #0
.draw_all_ladders_screen_3
  lda data_for_screen_3_setup+24,x
  sta $21
  inx
  lda data_for_screen_3_setup+24,x
  sta $22
  jsr draw_single_ladder
  inx
  cpx #18
  bne .draw_all_ladders_screen_3
  ldx #3
  ldy #0
.draw_more_platform_screen_3
  lda #brick  ;platform brick character
  sta screen_ram+260,y
  sta screen_ram+182,y
  tya
  clc
  adc #22
  tay
  dex
  bne .draw_more_platform_screen_3
  lda #space  ;space character
  sta screen_ram+409
  sta screen_ram+412
  sta screen_ram+329
  jsr colour_in_platforms
  ldy #hammer  ;hammer character
  sty screen_ram+306
  iny  ;bag character
  sty screen_ram+295
  iny  ;saw character
  sty screen_ram+229
  ldy #3  ;colour cyan
  sty colour_ram+295
  iny  ;colour purple
  sty colour_ram+229
  iny  ;colour green
  sty colour_ram+306
  ldx #5
  jsr draw_player_score

  ldx #21
.get_more_screen_3_data
  lda data_for_screen_3_setup+42,x
  sta $0f,x
  dex
  bne .get_more_screen_3_data
  lda #0  ;barrel character
  tay
  sta ($11),y  ;draw barrel character
  sta ($16),y  ;draw barrel character
  sta ($1b),y  ;draw barrel character
  lda #$1b
  sta $30
  ldy #4
  jsr draw_basic_screen
  lda #0
  sta player_is_alive
  rts

!source "scr3data.asm"

;################################################################################
clear_screen

   ldy #0
.clear_screen_char
   lda #space  ;space character
   sta screen_ram, y
   sta screen_ram+256, y
   lda #7  ;colour yellow
   sta colour_ram, y
   sta colour_ram+256, y
   dey
   bne .clear_screen_char
   rts

draw_single_ladder
   lda #topladder  ;top of ladder character
   ldy #0
   sta ( $21 ), y  ;draw in first given address

.next_ladder_line
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc .draw_ladder_char
   inc $22  ;add to second address if carry over

.draw_ladder_char
   lda ( $21 ), y
   cmp #space  ;space character
   bne .end_draw_single_ladder  ;not a space then end
   lda #ladder  ;ladder character
   sta ( $21 ), y
   bne .next_ladder_line

.end_draw_single_ladder
   rts

colour_in_platforms
   ldy #0

.colour_in_platforms1
   lda screen_ram, y
   cmp #brick  ;platform brick character
   bne .colour_in_platforms2
   lda #2  ;brown
   sta colour_ram, y

.colour_in_platforms2
   lda screen_ram+256, y
   cmp #brick  ;platform brick character
   bne .colour_in_platforms_end
   lda #2  ;brown
   sta colour_ram+256, y

.colour_in_platforms_end
   dey
   bne .colour_in_platforms1
   rts

draw_player_score
   lda player_score, x
   sta screen_ram, x
   lda #3  ;colour cyan
   sta colour_ram, x
   dex
   bpl draw_player_score
   rts

draw_basic_screen
   ldy #5

draw_screen_bonus
   lda data_for_more_stuff, y
   and #$3f
   sta screen_ram+16, y  ;bonus title
   lda data_for_more_stuff+5, y
   sta screen_ram+57, y  ;bonus value
   lda #1  ;colour white
   sta colour_ram+16, y  ;bonus title
   sta colour_ram+57, y  ;bonus value
   dey
   bpl draw_screen_bonus
   lda #wall  ;wall character
   sta screen_ram+441  ;start first line
   sta screen_ram+462  ;start next line
   lda player_lives
   ora #zero_char  ;zero character
   sta screen_ram+43  ;lives left
   lda screen_number
   ora #zero_char  ;zero character
   sta screen_ram+45  ;screen number
   ldy #4  ;colour purple
   sty colour_ram+43  ;lives left
   iny  ;colour green
   sty colour_ram+45  ;screen number
   rts

data_for_more_stuff
!byte $42,$4F,$4E,$55,$53,$20,$20,$39  ; BONUS  9
!byte $39,$35,$20,$22,$42,$2A,$C1,$9F  ; 95
!byte $97,$D4,$E8,$FD,$F1,$93,$CB,$01
!byte $E7,$D9,$CB,$CC,$A8,$CC,$CE,$CC
!byte $DC,$CC,$CC,$4C,$CE,$CC,$CC,$4C
!byte $D6,$FC,$CE,$9C,$89,$CC,$48,$EC
!byte $EE,$8D,$8C,$EC,$CC,$DC,$CC,$BC
!byte $9A,$CC,$CE,$ED,$23,$3B,$B3,$B1
!byte $2B,$B9,$BE,$36,$E7,$77,$03,$12
!byte $43,$75,$E3

end_code2