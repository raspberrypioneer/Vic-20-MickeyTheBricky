;################################################################################
draw_screen_2
   jsr clear_screen

   ldy #3
   ldx #0
   lda #brick  ;platform brick character
.draw_platform_screen_2
   sta _SCREEN_ADDR+152,y
   sta _SCREEN_ADDR+362,y
   sta _SCREEN_ADDR+373,y
   sta _SCREEN_ADDR+289,y
   sta _SCREEN_ADDR+365,x
   sta _SCREEN_ADDR+224,x
.draw_more_platform_screen_2
   sta _SCREEN_ADDR+400,y
   sta _SCREEN_ADDR+316,y
   sta _SCREEN_ADDR+232,y
   sta _SCREEN_ADDR+148,y
   sta _SCREEN_ADDR+221,y
   sta _SCREEN_ADDR+431,y
   clc
   txa
   adc #22
   tax
   lda #brick  ;platform brick character
   dey
   beq .draw_more_platform_screen_2
   bpl .draw_platform_screen_2
   sta _SCREEN_ADDR+394
   sta _SCREEN_ADDR+414

   ldy #10
.draw_even_more_platform_screen_2
   sta _SCREEN_ADDR+68,y
   sta _SCREEN_ADDR+483,y
   sta _SCREEN_ADDR+493,y
   dey
   bpl .draw_even_more_platform_screen_2

   ldx #0
.draw_all_ladders_screen_2
   lda data_for_screen_2_setup,x
   sta mickey_low
   inx
   lda data_for_screen_2_setup,x
   sta mickey_high
   jsr draw_single_ladder
   inx
   cpx #22
   bne .draw_all_ladders_screen_2

   jsr colour_in_platforms
   ldy #hammer  ;hammer character
   sty _SCREEN_ADDR+214
   iny  ;bag character
   sty _SCREEN_ADDR+271
   iny  ;saw character
   sty _SCREEN_ADDR+134
   ldy #cyan
   sty _COLOUR_SCREEN_ADDR+134
   iny  ;colour purple
   sty _COLOUR_SCREEN_ADDR+214
   iny  ;colour green
   sty _COLOUR_SCREEN_ADDR+271
   ldx #5
   jsr draw_player_score

   ldx #21
.set_screen_2_zero_page_data
   lda data_for_screen_2_setup+22,x
   sta $0f,x
   dex
   bne .set_screen_2_zero_page_data

   lda #barrel
   tay
   sta (barrel1_low),y  ;draw barrel character
   sta (barrel2_low),y  ;draw barrel character
   sta (barrel3_low),y  ;draw barrel character
   lda #27
   sta $30
   ldy #4
   jsr draw_basic_screen
   lda #space  ;space character
   sta _SCREEN_ADDR+475
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
  sta mickey_low
  inx
  lda data_for_screen_3_setup,x
  sta mickey_high
  lda #brick  ;platform brick character
.draw_platform_screen_3
  sta (mickey_low),y
  dey
  bne .draw_platform_screen_3
  inx
  cpx #24
  bne .get_screen_3_data

  ldx #0
.draw_all_ladders_screen_3
  lda data_for_screen_3_setup+24,x
  sta mickey_low
  inx
  lda data_for_screen_3_setup+24,x
  sta mickey_high
  jsr draw_single_ladder
  inx
  cpx #18
  bne .draw_all_ladders_screen_3

  ldx #3
  ldy #0
.draw_more_platform_screen_3
  lda #brick  ;platform brick character
  sta _SCREEN_ADDR+260,y
  sta _SCREEN_ADDR+182,y
  tya
  clc
  adc #22
  tay
  dex
  bne .draw_more_platform_screen_3

  lda #space  ;space character
  sta _SCREEN_ADDR+409
  sta _SCREEN_ADDR+412
  sta _SCREEN_ADDR+329
  jsr colour_in_platforms
  ldy #hammer  ;hammer character
  sty _SCREEN_ADDR+306
  iny  ;bag character
  sty _SCREEN_ADDR+295
  iny  ;saw character
  sty _SCREEN_ADDR+229
  ldy #cyan
  sty _COLOUR_SCREEN_ADDR+295
  iny  ;colour purple
  sty _COLOUR_SCREEN_ADDR+229
  iny  ;colour green
  sty _COLOUR_SCREEN_ADDR+306
  ldx #5
  jsr draw_player_score

  ldx #21
.set_screen_3_zero_page_data
  lda data_for_screen_3_setup+42,x
  sta $0f,x
  dex
  bne .set_screen_3_zero_page_data

  lda #barrel
  tay
  sta (barrel1_low),y  ;draw barrel character
  sta (barrel2_low),y  ;draw barrel character
  sta (barrel3_low),y  ;draw barrel character
  lda #27
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
   sta _SCREEN_ADDR,y
   sta _SCREEN_ADDR+256,y
   lda #yellow
   sta _COLOUR_SCREEN_ADDR,y
   sta _COLOUR_SCREEN_ADDR+256,y
   dey
   bne .clear_screen_char
   rts

draw_single_ladder
   lda #topladder  ;top of ladder character
   ldy #0
   sta (mickey_low),y  ;draw in first given address

.next_ladder_line
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   lda (mickey_low),y
   cmp #space  ;space character
   bne .end_draw_single_ladder  ;not a space then end
   lda #ladder  ;ladder character
   sta (mickey_low),y
   bne .next_ladder_line

.end_draw_single_ladder
   rts

colour_in_platforms
   ldy #0

.colour_in_platforms1
   lda _SCREEN_ADDR,y
   cmp #brick  ;platform brick character
   bne .colour_in_platforms2
   lda #red
   sta _COLOUR_SCREEN_ADDR,y

.colour_in_platforms2
   lda _SCREEN_ADDR+256,y
   cmp #brick  ;platform brick character
   bne .colour_in_platforms_end
   lda #red
   sta _COLOUR_SCREEN_ADDR+256,y

.colour_in_platforms_end
   dey
   bne .colour_in_platforms1
   rts

draw_player_score
   lda player_score,x
   sta _SCREEN_ADDR,x
   lda #cyan
   sta _COLOUR_SCREEN_ADDR,x
   dex
   bpl draw_player_score
   rts

draw_basic_screen
   ldy #5
draw_screen_bonus
   lda data_bonus_score,y
   and #63
   sta _SCREEN_ADDR+16,y  ;bonus title
   lda data_bonus_score+5,y
   sta _SCREEN_ADDR+57,y  ;bonus value
   lda #white
   sta _COLOUR_SCREEN_ADDR+16,y  ;bonus title
   sta _COLOUR_SCREEN_ADDR+57,y  ;bonus value
   dey
   bpl draw_screen_bonus

   lda #wall  ;wall character
   sta _SCREEN_ADDR+441  ;start first line
   sta _SCREEN_ADDR+462  ;start next line
   lda player_lives
   ora #zero_char  ;zero character
   sta _SCREEN_ADDR+43  ;lives left
   lda screen_number
   ora #zero_char  ;zero character
   sta _SCREEN_ADDR+45  ;screen number
   ldy #purple
   sty _COLOUR_SCREEN_ADDR+43  ;lives left
   iny  ;colour green
   sty _COLOUR_SCREEN_ADDR+45  ;screen number
   rts

data_bonus_score
    !byte $42, $4f, $4e, $55, $53, $20, $20, $39, $39, $35
    ;       B    O    N    U    S              9    9    5

data_junk_hex_1bbf_65_bytes
    !byte $20, $22, $42, $2a, $c1, $9f, $97, $d4
    !byte $e8, $fd, $f1, $93, $cb, $01, $e7, $d9
    !byte $cb, $cc, $a8, $cc, $ce, $cc, $dc, $cc
    !byte $cc, $4c, $ce, $cc, $cc, $4c, $d6, $fc
    !byte $ce, $9c, $89, $cc, $48, $ec, $ee, $8d
    !byte $8c, $ec, $cc, $dc, $cc, $bc, $9a, $cc
    !byte $ce, $ed, $23, $3b, $b3, $b1, $2b, $b9
    !byte $be, $36, $e7, $77, $03, $12, $43, $75
    !byte $e3
