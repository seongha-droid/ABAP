*&---------------------------------------------------------------------*
*& Include zm_182_w3_2_top
*&---------------------------------------------------------------------*

TABLES: makt.

DATA: gt_makt TYPE TABLE OF makt,
      gs_makt TYPE makt.

SELECT-OPTIONS: s_matnr FOR makt-matnr.

DATA: ok_code LIKE sy-ucomm.

DATA: go_docking TYPE REF TO cl_gui_docking_container,
      go_grid    TYPE REF TO cl_gui_alv_grid,
      gt_fcat    TYPE lvc_t_fcat,
      gs_layout  TYPE lvc_s_layo.
