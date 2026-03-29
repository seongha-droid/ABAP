*&---------------------------------------------------------------------*
*& Include          ZM_182_ALV_PRAC_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv .
  IF go_grid IS INITIAL.
    PERFORM create_object.
    PERFORM set_fieldcatalog.
    PERFORM set_layout.
    PERFORM display_alv.
  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT *
    FROM sflight
    WHERE carrid IN @s_carrid
    ORDER BY carrid, connid
    INTO CORRESPONDING FIELDS OF TABLE @gt_sflight.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object .
  CREATE OBJECT go_docking
    EXPORTING
      repid     = sy-repid
      dynnr     = sy-dynnr
      side      = go_docking->dock_at_top
      extension = 2000.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_docking.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcatalog .
  DATA: ls_fcat TYPE lvc_s_fcat.
  REFRESH gt_fcat.

  CLEAR: ls_fcat.
  ls_fcat-fieldname = 'CARRID'.
  ls_fcat-coltext = '코드'.
  ls_fcat-just = 'C'.
  ls_fcat-outputlen = 4.
  APPEND ls_fcat TO gt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = 'CONNID'.
  ls_fcat-coltext = '번호'.
  ls_fcat-just = 'C'.
  ls_fcat-outputlen = 4.
  APPEND ls_fcat TO gt_fcat.
  CLEAR ls_fcat.

  ls_fcat-fieldname = 'FLDATE'.
  ls_fcat-coltext = '일자'.
  ls_fcat-just = 'L'.
  ls_fcat-outputlen = 12.
  APPEND ls_fcat TO gt_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .

  CLEAR gs_layout.

  gs_layout-zebra = 'X'.
  gs_layout-sel_mode = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'SFLIGHT'
      i_save           = 'X'
      i_default        = 'X'
      is_layout        = gs_layout
    CHANGING
      it_outtab        = gt_sflight[]
      it_fieldcatalog  = gt_fcat.

ENDFORM.
