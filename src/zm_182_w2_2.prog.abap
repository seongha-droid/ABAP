*&---------------------------------------------------------------------*
*& Report zm_182_w2_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w2_2.

"INCLUDE PROGRAM 선언
"TOP, F01 두가지 선언
INCLUDE: zm_182_w2_2_top,
         zm_182_w2_2_f01.

"초기값 설정
INITIALIZATION.
  p_mtart = 'HALB'.
  s_matnr-sign = 'I'.
  s_matnr-option = 'BT'.
  s_matnr-low = 'CCWA1281'.
  s_matnr-high = 'CCWA1300'.
  APPEND s_matnr.

AT SELECTION-SCREEN.

START-OF-SELECTION.
  PERFORM get_data. "데이터를 가져오는 SUBROUTINE

END-OF-SELECTION.
  PERFORM write_data. "데이터를 써주는 SUBROUTINE
