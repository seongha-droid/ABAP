*&---------------------------------------------------------------------*
*& Include ZM_182_ALV_PRAC_TOP                      - Report ZM_182_ALV_PRAC
*&---------------------------------------------------------------------*
REPORT zm_182_alv_prac.

TABLES : sflight.

DATA : gs_sflight LIKE sflight,
      gt_sflight TYPE TABLE OF sflight.

DATA: ok_code LIKE sy-ucomm.

DATA: go_docking TYPE REF TO cl_gui_docking_container,
      go_grid TYPE REF TO cl_gui_alv_grid,
      gt_fcat TYPE lvc_t_fcat,
      gs_layout TYPE lvc_s_layo.

SELECT-OPTIONS: s_carrid FOR sflight-carrid.
