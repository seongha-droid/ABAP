*&---------------------------------------------------------------------*
*& Include zm_182_w3_team_top
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
" b1이라는 이름의 Block(구역)을 생성한다
" WITH FRAME: 블록 테이두리에 네모단 선을 그려서 시각적으로 깔끔하게 해줌
" TITLE TEXT-t01: 네모난 테두리 왼쪽 상단에 들어갈 제목을 설정한다.

PARAMETERS: p_all  RADIOBUTTON GROUP grp1 DEFAULT 'X', " sflight 전체 데이터 조회
            p_carr RADIOBUTTON GROUP grp1,             " 항공사별 조회 (carrid 조건)
            p_type RADIOBUTTON GROUP grp1,             " 기종별 조회 (planetype 조건)
            p_date RADIOBUTTON GROUP grp1.             " 날짜 범위 조회 (fldate 조건)
" 라디오 버튼 그룹을 선언한다.
" RADIOBUTTON: 변수를 체크박스나 빈칸이 아닌 라디오버튼 형태로 생성
" 4개의 버튼을 grp1 그룹으로 묶는다.
" 라디오 버튼은 같은 그룹으로 묶여 있어야 함. 그룹명이 다르면 여러 개가 동시에 선택되는 일이 생김
" DEFAULT 'X': 프로그램이 처음 실행될 때 기본적으로 선택되어 있음

SELECTION-SCREEN END OF BLOCK b1. " b1 블록을 단아주는 역할

*&---------------------------------------------------------------------*

TABLES: sflight.

DATA: gt_sflight TYPE TABLE OF sflight,
      go_alv     TYPE REF TO cl_salv_table.

*&---------------------------------------------------------------------*
