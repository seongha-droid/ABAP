*&---------------------------------------------------------------------*
*& Include zm_182_w3_2_f01
*&---------------------------------------------------------------------*

FORM get_data.
  SELECT *
  FROM makt
  WHERE matnr IN @s_matnr
  ORDER BY matnr
  INTO CORRESPONDING FIELDS OF TABLE @gt_makt.
ENDFORM.
