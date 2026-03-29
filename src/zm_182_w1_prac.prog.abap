*&---------------------------------------------------------------------*
*& Report ZM_182_W1_PRAC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w1_prac.

*-------------------------------------------------------------------------------------------------------------------------*
* 2주차 스터디 실습과제
*-----------------------------------------------------------------------------*
* 1. SFLIGHT(운항 정보) table을 사용하여 Airline Code, Flight Connection Number,
* Flight date, Air fair를 구조로 갖는 인터널 테이블을 만든 후, OPEN SQL을 통해 값을 담으세요.
*------------------------------------------------------------------------------*

TABLES: sflight.

TYPES: BEGIN OF ty_sfl,
         carrid TYPE sflight-carrid,
         connid TYPE sflight-connid,
         fldate TYPE sflight-fldate,
         price  TYPE sflight-price,
       END OF ty_sfl.

DATA: gs_sfl TYPE ty_sfl,
      gt_sfl TYPE TABLE OF ty_sfl.

SELECT
  a~carrid
  a~connid
  a~fldate
  a~price
  FROM sflight AS a
  INTO TABLE gt_sfl.

*cl_demo_output=>display( gt_sfl ).

*--------------------------------------------------------------------------------------------------------------------------*
* 1-1. 항공권 가격이 가장 ‘싼’ 데이터를 읽어오세요.(SORT 정렬, READ, 인덱스 이용)
* 단, 데이터 읽기에 실패한다면 '데이터 읽기에 실패했습니다.'를, 성공한다면 해당 스트럭처를 출력하도록 해주세요. (SY-SUBRC, 조건문 활용)
* SQL구문 SELECT절에 ',' 콤마 사용시 New Syntax 오류. 구문법은 쉼표 X.
* 정렬시 SORT (IT) BY columns Ascending/descending
*--------------------------------------------------------------------------------------------------------------------------*

SORT gt_sfl BY price ASCENDING.

READ TABLE gt_sfl INTO gs_sfl INDEX 1.

IF sy-subrc = 0.
*  cl_demo_output=>display_data( gs_sfl ).
ELSE.
*  cl_demo_output=>display_data( '데이터 읽기에 실패했습니다.' ).
ENDIF.

*------------------------------------------------------------------------*
* 2. 2시간 이상 운행되는 항공편은 기내식이 준비되어야 합니다. 기내식이 필요한 운항 일정을
*Display 하기위해, SPFLI(운항 일정) 테이블을 활용해 출발도시가 'SINGAPORE'인 데이터들 중
* 비행시간이 2시간 이상인 데이터들의 Airline Code, Flight Connection Number,
*  Departure city, Arrival city, Flight time를 출력하도록 하세요.
*-------------------------------------------------------------------------*

TYPES: BEGIN OF ty_spf,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         fltime   TYPE spfli-fltime,
       END OF ty_spf.

DATA: gs_spf TYPE ty_spf,
      gt_spf TYPE TABLE OF ty_spf.

SELECT
  a~carrid
  a~connid
  a~cityfrom
  a~cityto
  a~fltime
  FROM spfli AS a
  INTO TABLE gt_spf
  WHERE cityfrom = 'SINGAPORE' AND fltime >= 2.

*cl_demo_output=>display( gt_spf ).

*---------------------------------------------------------------------------------------------*
* 3. spfli 테이블을 활용해  Airline Code가 'AA', 'AZ', 'DL'인 데이터들 중 Airline Code별로 평균 이동 거리가
* 2,600 마일 이상인 데이터들의 Airline Code, 평균 이동 거리, 최대 이동 거리, 최소 이동거리를 출력하도록 하세요.
* CORRESPONDING FIELDS OF 사용하기
* corresponding 쓸떈 별칭(as) 필수.
*----------------------------------------------------------------------------------------------*

TYPES: BEGIN OF ty_spf2,
         carrid       TYPE spfli-carrid,
         distance_avg TYPE spfli-distance,
         distance_max TYPE spfli-distance,
         distance_min TYPE spfli-distance,
       END OF ty_spf2.

DATA: gs_spf2 TYPE ty_spf2,
      gt_spf2 TYPE TABLE OF ty_spf2.

SELECT
  a~carrid
  AVG( a~distance ) AS distance_avg
  MAX( a~distance ) AS distance_max
  MIN( a~distance ) AS distance_min
  FROM spfli AS a
  INTO CORRESPONDING FIELDS OF TABLE gt_spf2
  WHERE carrid = 'AA' OR carrid = 'AZ' OR carrid = 'DL' OR carrid = 'AA'
  GROUP BY carrid
  HAVING AVG( a~distance ) >= 2600.

*cl_demo_output=>display( gt_spf2 ).

*-----------------------------------------------------------------------------------------*
*4. 항공사 명칭/항공사 코드/항공편 연결 번호/항공편 일자/출발 도시/도착 도시/거리/거리 단위/
*    최대 좌석/점유 좌석/잔여 좌석을 구조로 갖는 테이블을 만들어 데이터를 출력하세요.
* 조건 1. 거리 단위가 마일일 경우 키로미터로 환산하고 거리 단위를 키로미터로 바꿔주세요.(직접 구글링 계산, 소수점 버림 함수- > ??? )
* 조건 2. 2020/01/01 이후 데이터만 출력하세요.
* 조건 3. 잔여 좌석이 남아있는 데이터만 오름차순으로 출력해주세요.
* 잔여 좌석은 seatsmax-seatsocc 로 계산하면 됩니다.
* 문제 푸는 동안 사용하는 DB 테이블은 SPFLI , SCARR , SFLIGHT 입니다. (JOIN)
*------------------------------------------------------------------------------------------*

TYPES: BEGIN OF ty_join,
         carrname    TYPE scarr-carrname,
         carrid      TYPE spfli-carrid,
         connid      TYPE spfli-connid,
         fldate      TYPE sflight-fldate,
         cityfrom    TYPE spfli-cityfrom,
         cityto      TYPE spfli-cityto,
         distance    TYPE spfli-distance,
         distid      TYPE spfli-distid,
         seatsmax    TYPE sflight-seatsmax,
         seatsocc    TYPE sflight-seatsocc,
         seatsremain TYPE i,
       END OF ty_join.

DATA: gs_join TYPE ty_join,
      gt_join TYPE TABLE OF ty_join.

SELECT
  c~carrname,
  a~carrid,
  a~connid,
  b~fldate,
  a~cityfrom,
  a~cityto,
  a~distance,
  a~distid,
  b~seatsmax,
  b~seatsocc
  FROM spfli AS a
  INNER JOIN sflight AS b
  ON a~carrid = b~carrid
  INNER JOIN scarr AS c
  ON a~carrid = c~carrid
  INTO CORRESPONDING FIELDS OF TABLE @gt_join
  WHERE b~fldate >= '20200101' AND b~seatsmax > b~seatsocc.

LOOP AT gt_join INTO gs_join.
  gs_join-seatsremain = gs_join-seatsmax - gs_join-seatsocc.
  IF gs_join-distid = 'MI'.
    gs_join-distid = 'KM'.
    gs_join-distance = trunc( gs_join-distance * '1.60934' ).
  ENDIF.
  MODIFY gt_join FROM gs_join TRANSPORTING seatsremain distid distance.
  CLEAR gs_join.
ENDLOOP.

SORT gt_join BY seatsremain ASCENDING.

*cl_demo_output=>display( gt_join ).

*----------------------------------------------------------------------*
* 5. 도전!
* SPFLI 테이블의 데이터를 활용해 다음 조건을 만족하는 모든 환승 경로를 찾아 출력하세요.
* 조건 1: 출발 도시가 'NEW YORK'인 항공편을 첫 번째 구간으로 선택하세요.
* 조건 2: 첫 번째 구간 항공편의 도착 도시를 경유지로 삼아, 그곳에서
* 출발하는 항공편을 두 번째 구간으로 선택하세요.
* 조건 3: 두 번째 구간 항공편의 도착 도시는 'SINGAPORE'여야 합니다.
* 힌트:
* SPFLI 테이블의 데이터를 모두 읽어와 이중 반복문(Nested LOOP)을 사용하여
* 논리적으로 연결되는 경로를 찾으세요.
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_cha,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
       END OF ty_cha.

DATA: gs_cha1 TYPE ty_cha,
      gs_cha2 TYPE ty_cha,
      gt_cha1 TYPE TABLE OF ty_cha,
      gt_cha2 TYPE TABLE OF ty_cha.

SELECT
  a~carrid
  a~connid
  a~cityfrom
  a~cityto
  FROM spfli AS a
  INTO TABLE gt_cha1
  WHERE a~cityfrom = 'NEW YORK'.

SORT gt_cha1 BY carrid.

SELECT
  a~carrid
  a~connid
  a~cityfrom
  a~cityto
  FROM spfli AS a
  INTO TABLE gt_cha2
  WHERE a~cityto = 'SINGAPORE'.

WRITE: AT 25 '<환승 경로 탐지 프로그램>'.
LOOP AT gt_cha1 INTO gs_cha1.
  LOOP AT gt_cha2 INTO gs_cha2.
*    IF gs_cha1-cityto = gs_cha2-cityfrom.
*      WRITE: / '환승 경로 발견!'.
*      WRITE: / '-----------------------------------------------------------'.
*      WRITE: / '1단계:', gs_cha1-carrid, ' ', gs_cha1-connid, '|', gs_cha1-cityfrom, '->', gs_cha1-cityto,'|'.
*      WRITE: / '2단계:', gs_cha2-carrid, ' ', gs_cha2-connid, '|', gs_cha2-cityfrom, '->', gs_cha2-cityto,'|'.
*      WRITE: / '-----------------------------------------------------------'.
*    ENDIF.
  ENDLOOP.
ENDLOOP.
*----------------------------------------------------------------------*
*INCLUDE문과 Subroutine 없이 기본 Report Program 생성
*조건: 1000번 스크린에서 자재타입(MTART)을 단일 값으로 입력 받고 자재번호(MATNR)는
*복수 값으로 입력 받아 MARA와 동일한 구조를 갖는 인터널 테이블에서 데이터를 출력하도록 해주세요.
*단, 1000번 스크린에서 MTART의 초기값을 HALB(반제품), MTART의 초기값을
*CCWA1281과 CCWA1300으로 설정해주세요.
*----------------------------------------------------------------------*

TABLES: mara.

DATA: gt_mara TYPE TABLE OF mara.

PARAMETERS: p_mtart LIKE mara-mtart.
SELECT-OPTIONS: s_matnr FOR mara-matnr.

INITIALIZATION.

  p_mtart = 'HALB'.
  s_matnr-low = 'CCWA1281'.
  s_matnr-high = 'CCWA1300'.

  APPEND s_matnr.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  SELECT *
    FROM mara
    INTO TABLE gt_mara
    WHERE mtart = p_mtart AND matnr IN s_matnr.

END-OF-SELECTION.

  cl_demo_output=>display_data( gt_mara ).
