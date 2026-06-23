*&---------------------------------------------------------------------*
*& Report zm_182_w3_team
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w3_team.

INCLUDE zm_182_w3_team_top.
INCLUDE zm_182_w3_team_f01.

START-OF-SELECTION.
  PERFORM get_data.

END-OF-SELECTION.
  PERFORM display_alv.
