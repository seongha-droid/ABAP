*&---------------------------------------------------------------------*
*& Report ZM_182_W3_PRAC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zm_182_w3_prac_top                      .    " Global Data

* INCLUDE ZM_182_W3_PRAC_O01                      .  " PBO-Modules
* INCLUDE ZM_182_W3_PRAC_I01                      .  " PAI-Modules
* INCLUDE ZM_182_W3_PRAC_F01                      .  " FORM-Routines

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'. "버튼 설정
  SET TITLEBAR 'T100'. "화면 타이틀 설정
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv OUTPUT.

  IF go_grid IS INITIAL.

    CREATE OBJECT go_docking
      EXPORTING "어떤 데이터를 넣어줄 것이냐
        repid     = sy-repid
        dynnr     = sy-dynnr "스크린과 컨테이너 연결
        side      = go_docking->dock_at_top "어느 위치에 만들어줄거냐. 위에서부터
        "or 밑에서부터
        extension = 2000. "넓이

    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_docking.  "컨테이너랑 그리드랑 연결


*------------------ FIELD catalog ------------------*

  DATA : ls_fcat TYPE lvc_s_fcat.
  REFRESH gt_fcat.

  CLEAR : ls_fcat.
  ls_fcat-fieldname  = 'CARRID'.
  ls_fcat-coltext    = '코드'.
  ls_fcat-just       = 'C'.
  ls_fcat-outputlen  = 4.
  APPEND ls_fcat TO gt_fcat.

  CLEAR : ls_fcat.
  ls_fcat-fieldname  = 'CONNID'.
  ls_fcat-coltext    = '번호'.
  ls_fcat-just       = 'C'.
  ls_fcat-outputlen  = 4.
  APPEND ls_fcat TO gt_fcat.

  CLEAR : ls_fcat.
  ls_fcat-fieldname  = 'FLDATE'.
  ls_fcat-coltext    = '비행 날짜'.
  ls_fcat-just       = 'C'.
  ls_fcat-outputlen  = 12.
  APPEND ls_fcat TO gt_fcat.

*------------------ Layout ------------------*

  CLEAR gs_layout.
  gs_layout-zebra      = 'X'.   " 얼룩말 표시
  gs_layout-cwidth_opt = 'X'.   " 컬럼 너비 자동 조정
  gs_layout-sel_mode = 'A'.
  gs_layout-grid_title = '항공권 목록'.

*---------------------------------------------------------------------*

CALL METHOD go_grid->set_table_for_first_display
  EXPORTING
    i_structure_name = 'SFLIGHT'
    i_save           = 'X'
    i_default        = 'X'
    is_layout        = gs_layout
  CHANGING
    it_outtab        = gt_sflight
    it_fieldcatalog  = gt_fcat.

*---------------------------------------------------------------------*

ELSE.

CALL METHOD go_grid->refresh_table_display.
"PBO를 모두 돌리는 것이 아니라 빠르게 새로고침만 하도록 하는 코드.

ENDIF.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' or 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
