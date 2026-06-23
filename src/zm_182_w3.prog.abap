*&---------------------------------------------------------------------*
*& Report zm_182_w3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w3.

INCLUDE zm_182_w3_top. " Internal Table, ALV Object, Selection Screen 선언
INCLUDE zm_182_w3_f01. " 서브 루틴 선언
INCLUDE zm_182_w3_o01. " PBO모듈: GUI 타이틀 설정, 버튼 설정, ALV Ojbject 생성
INCLUDE zm_182_w3_i01. " PAI모듈: 버튼 클릭에 따른 화면 흐름 제어

START-OF-SELECTION.
  PERFORM get_data.    " 인터널 테이블에 데이터를 담는 subroutine
  CALL SCREEN '100'.   " SAP GUI 열기 ( Ctrl + 6, 우클릭 -> open with )
