*&---------------------------------------------------------------------*
*& Include zm_182_w3_top
*&---------------------------------------------------------------------*

"SELECT-OPTIONS를 위해 테이블 선언
TABLES: sflight.

DATA: gt_sflight TYPE TABLE OF sflight,
      gs_sflight TYPE sflight.

"selection screen
SELECT-OPTIONS: s_carrid FOR sflight-carrid.

"ALV object ALV 객체 선언
"sy-ucomm: user command -> 사용자의 입력을 저장하고 있는 시스템변수.
DATA: ok_code LIKE sy-ucomm.

"abap에 존재하는 클래스에 정의된 type을 이용하여 변수 선언.
"컨테이너, 그리드, 필드카탈로그 테이블, 레이아웃 선언.
DATA: go_docking TYPE REF TO cl_gui_docking_container, "도킹 컨테이너
      go_grid    TYPE REF TO cl_gui_alv_grid,          "그리드
      gt_fcat    TYPE lvc_t_fcat,                      "필드카탈로그 테이블
      gs_layout  TYPE lvc_s_layo.                      "레이아웃
