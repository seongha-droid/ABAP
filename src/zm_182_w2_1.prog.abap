*&---------------------------------------------------------------------*
*& Report zm_182_w2_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w2_1.

TABLES: mara.

DATA: gt_mara TYPE TABLE OF mara.

"PARAMETES로 단일값 입력받고 SELECT-OPTIONS로 범위값 입력받음.
PARAMETERS: p_mtart TYPE mara-mtart.
SELECT-OPTIONS: s_matnr FOR mara-matnr.

"이벤트 구조
"SIGN, OPTION, LOW, HIGH 필드 설정 이후에는 꼭 APPEND를 통해 값을 넣어줘야 함.
INITIALIZATION.
  p_mtart = 'HALB'.
  s_matnr-sign = 'I'.
  s_matnr-option = 'BT'.
  s_matnr-low = 'CCWA1281'.
  s_matnr-high = 'CCWA1300'.
  APPEND s_matnr.

AT SELECTION-SCREEN.

START-OF-SELECTION.
  SELECT *
      FROM mara
      INTO TABLE gt_mara
      WHERE mtart = p_mtart AND matnr IN s_matnr.

END-OF-SELECTION.
  cl_demo_output=>display( gt_mara ).
