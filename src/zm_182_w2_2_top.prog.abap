*&---------------------------------------------------------------------*
*& Include zm_182_w2_2_top
*&---------------------------------------------------------------------*
"사용하는 테이블, 변수 등을 선언하고 SELECTION-SCREEN을 정의하는 INCULDE.

TABLES: mara.

DATA: gt_mara TYPE TABLE OF mara.

"SELECTION-SCREEN BEGIN OF BLOCK으로 PARAMETER와 SELECT-OPTIONS를 한 박스 안에 담고 출력되도록 함.
"WITH FRAME TITLE을 이용하여 텍스트 심볼과 파라미터, SELECT-OPTIONS에 이름을 붙여 그대로 출력되게 함.
"TEXT-002를 새로 생성하는데 CTRL+1을 이용하면 생성 가능.
"CTRL+좌클릭을 통해 TEXT-002를 설정함.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_mtart TYPE mara-mtart.
SELECT-OPTIONS: s_matnr FOR mara-matnr.
SELECTION-SCREEN END OF BLOCK bl1.

"프로그램 이름 변경하기(왼쪽 트리에서 프로그램 클릭 후 ALT+ENTER로 Properties탭의 Discription 수정
