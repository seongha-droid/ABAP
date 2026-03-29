*&---------------------------------------------------------------------*
*& Include zm_182_w2_2_f01
*&---------------------------------------------------------------------*
"SUBROUTINE에 대한 정의를 해주는 INCLUDE

"NEW SYNTAX
"GET_DATA SUBROUTINE에 대한 정의
FORM get_data.
  SELECT *
    FROM mara
    INTO TABLE @gt_mara
    WHERE mtart = @p_mtart AND matnr IN @s_matnr.
ENDFORM.

"WRITE_DATA SUBROUTINE에 대한 정의
FORM write_data.
  cl_demo_output=>display( gt_mara ).
ENDFORM.
