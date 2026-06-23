*&---------------------------------------------------------------------*
*& Include ZM_182_W3_PRAC_TOP                       - Report ZM_182_W3_PRAC
*&---------------------------------------------------------------------*
REPORT zm_182_w3_prac.

TABLES: sflight.

SELECT-OPTIONS s_carrid FOR sflight-carrid.

DATA: go_docking TYPE REF TO cl_gui_docking_container,
      go_grid    TYPE REF TO cl_gui_alv_grid.

DATA: ok_code LIKE sy-ucomm.

DATA: gt_sflight TYPE TABLE OF sflight,
      gt_fcat    TYPE lvc_t_fcat,
      gs_layout  TYPE lvc_s_layo.

SELECT *
  FROM sflight
  INTO TABLE gt_sflight.

CALL SCREEN 0100.
