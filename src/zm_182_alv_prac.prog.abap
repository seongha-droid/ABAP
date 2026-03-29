*&---------------------------------------------------------------------*
*& Report ZM_182_ALV_PRAC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zm_182_alv_prac_top                     .    " Global Data

INCLUDE zm_182_alv_prac_o01                     .  " PBO-Modules
INCLUDE zm_182_alv_prac_i01                     .  " PAI-Modules
INCLUDE zm_182_alv_prac_f01                     .  " FORM-Routines

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN '100'.
