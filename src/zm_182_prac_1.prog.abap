*&---------------------------------------------------------------------*
*& Report ZM_182_PRAC_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_prac_1.

INCLUDE zm_182_prac_1_top.
INCLUDE zm_182_prac_1_f01.

INITIALIZATION.

  p_mtart = 'HALB'.
  s_matnr-low = 'CCWA1281'.
  s_matnr-high = 'CCWA1300'.

  APPEND s_matnr.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  PERFORM get_data.

END-OF-SELECTION.
  PERFORM write_data.
