*&---------------------------------------------------------------------*
*& Report zm_182_w2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w2.
*--------------------------------------------------------------------------------------------------------------------------*
* 1. SFLIGHT(운항 정보) table을 사용하여 Airline Code, Flight Connection Number,
* Flight date, Air fair를 구조로 갖는 인터널 테이블을 만든 후, OPEN SQL을 통해 값을 담으세요.
* SQL구문 SELECT절에 ',' 콤마 사용시 New Syntax 오류가 납니다. 구 문법은 쉼표 X.
* cl_demo로 확인하기
*--------------------------------------------------------------------------------------------------------------------------*

TYPES: BEGIN OF ty_sfl,
         carrid TYPE sflight-carrid,
         connid TYPE sflight-connid,
         fldate TYPE sflight-fldate,
         price  TYPE sflight-price,
       END OF ty_sfl.

DATA: gs_sfl TYPE ty_sfl,
      gt_sfl TYPE TABLE OF ty_sfl.

" SELECT문을 이용하여 원하는 정보를 internal table에 넣음.
SELECT
    carrid
    connid
    fldate
    price
    FROM sflight
    INTO TABLE gt_sfl.

cl_demo_output=>display( gt_sfl ).

*--------------------------------------------------------------------------------------------------------------------------*
* 1-1. 항공권 가격이 가장 ‘비싼’ 데이터를 읽어오세요.(SORT 구문으로 정렬, READ table 구문 + 인덱스 활용)
* 단, 데이터 읽기에 실패한다면 '데이터 읽기에 실패했습니다.'를, 성공한다면 해당 스트럭처를 출력하도록 해주세요. (SY-SUBRC, 조건문 활용)
* 실패 시 [MESSAGE '데이터 읽기에 실패했습니다' TYPE 'E'.] 활용. 메시지를 출력하는 방법입니다!
* 정렬 시 구문 SORT (IT) BY columns Ascending/descending
* 테이블에서 특정 레코드를 가져오는 구문 read table (it) into (Structure) index (?)
* 스트럭쳐 출력이 잘 되면 index를 10000으로 바꿔서 데이터 읽기에 실패했을 때 매시지도 확인해서 캡쳐해주세요.
*--------------------------------------------------------------------------------------------------------------------------*

"SORT문을 이용하여 PRICE 필드를 내림차순 정렬. 값이 가장 높은 행부터 순차적으로 정렬됨.
"SORT 테이블명 BY 필드명 [ASCENDING/DESCENDING].
SORT gt_sfl BY price DESCENDING.

" READ TABLE을 이용하여 인터널 테이블의 첫번째에 있는 행을 스트럭쳐에 담음.
" READ TABLE 테이블명 INTO 스트럭쳐명 INDEX 숫자.
" READ TABLE의 다른 구조도 익히기
READ TABLE gt_sfl INTO gs_sfl INDEX 10000.

" 서브루틴 코드가 0일때와 0이 아닐 때를 나누고 0이 아닐때는 에러메세지를 띄우도록 함.
IF sy-subrc = 0.
  cl_demo_output=>display_data( gs_sfl ).
ELSE.
  MESSAGE e398(00) WITH '데이터 읽기에 실패했습니다'.  "에러메세지 띄우는 문법 익히기.
ENDIF.

*--------------------------------------------------------------------------------------------------------------------------*
* 2. 싱가포르 공항에서 2시간 이상 운행되는 항공편은 기내식이 준비되어야 합니다. 기내식이 필요한 운항 일정을 Display 하기위해,
* SPFLI(운항 일정) 테이블을 활용해 출발도시가 'SINGAPORE'인 데이터들 중
* 비행시간이 2시간 이상인 데이터들의 Airline Code, Flight Connection Number,
*  Departure city, Arrival city, Flight time를 출력하도록 하세요.
*--------------------------------------------------------------------------------------------------------------------------*

TYPES: BEGIN OF ty_spf,
         carrid   TYPE spfli-carrid,
         connid   TYPE spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         fltime   TYPE spfli-fltime,
       END OF ty_spf.

DATA: gs_spf TYPE ty_spf,
      gt_spf TYPE TABLE OF ty_spf.

"WHERE을 이용하여 필요한 데이터만 골라서 인터널 테이블에 담음.
SELECT
   carrid
   connid
   cityfrom
   cityto
   fltime
   FROM spfli
   INTO TABLE gt_spf
   WHERE cityfrom = 'SINGAPORE' AND fltime >= 120.

cl_demo_output=>display( gt_spf ).

*--------------------------------------------------------------------------------------------------------------------------*
* 3. spfli 테이블을 활용해  Airline Code가 'AA', 'AZ', 'DL'인 데이터들 중 Airline Code 별로 평균 이동 거리가
* 2,600 마일 이상인 데이터들의 Airline Code, 평균 이동 거리, 최대 이동 거리, 최소 이동거리를 출력하도록 하세요.
* CORRESPONDING FIELDS OF 사용하기(필드명에 근거하여 매핑)
* corresponding 쓸떈 별칭(as) 필수.
*--------------------------------------------------------------------------------------------------------------------------*

TYPES: BEGIN OF ty_spf1,
         carrid       TYPE spfli-carrid,
         avg_distance TYPE spfli-distance,
         max_distance TYPE spfli-distance,
         min_distance TYPE spfli-distance,
       END OF ty_spf1.

DATA: gs_spf1 TYPE ty_spf1,
      gt_spf1 TYPE TABLE OF ty_spf1.

"집계함수를 이용하여 SELECT문을 사용하여 인터널 테이블에 넣음
"CORRESPONDING FIELDS OF TABLE을 이용하여 이름이 같은 필드에 알아서 매핑되어 데이터를 가져올 수 있도록 함.
"GROUP BY와 HAVING을 이용하여 집계함수에 대해서도 SELECT 조건을 걸어줌.
SELECT
    carrid,
    AVG( distance ) AS avg_distance,
    MAX( distance ) AS max_distance,
    MIN( distance ) AS min_distance
    FROM spfli
    INTO CORRESPONDING FIELDS OF TABLE @gt_spf1
    WHERE carrid = 'AA' OR carrid = 'AZ' OR carrid = 'DL'
    GROUP BY carrid
    HAVING AVG( distance ) >= 2600.

cl_demo_output=>display( gt_spf1 ).

*--------------------------------------------------------------------------------------------------------------------------*
*4. 항공사 명칭/항공사 코드/항공편 연결 번호/항공편 일자/출발 도시/도착 도시/거리/거리 단위/
*    최대 좌석/점유 좌석/잔여 좌석을 구조로 갖는 테이블을 만들어 데이터를 출력하세요.
* 조건 1. 거리 단위가 마일일 경우 키로미터로 환산하고 거리 단위를 키로미터로 바꿔주세요.(직접 구글링 계산, 소수점 버림 함수- > ??? )
* 조건 2. 2019/01/01 이후 데이터만 출력하세요.
* 조건 3. 잔여 좌석이 남아있는 데이터만 오름차순으로 출력해주세요.
* 잔여 좌석은 seatsmax-seatsocc 로 계산하면 됩니다.
* 문제 푸는 동안 사용하는 DB 테이블은 SPFLI ,SCARR, SFLIGHT 입니다. (JOIN)
*--------------------------------------------------------------------------------------------------------------------------*

TABLES: spfli, scarr, sflight.

"SEATSREMAIN이라는 필드는 ABAP DICTIONARY에 있는 테이블에 속한 필드가 아님.
"SEATSREMAIN = SEATSMAX - SEATSOCC로 계산되기 때문에 TYPE을 정수형으로 설정.
TYPES: BEGIN OF ty_airinfo,
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
       END OF ty_airinfo.

DATA: gs_airinfo TYPE ty_airinfo,
      gt_airinfo TYPE TABLE OF ty_airinfo.

"LOOP문의 performance를 고려하여 처음에 데이터를 가져올 때부터 필요한 데이터만 가져오도록 WHERE문 설정
"JOIN문을 통해 3개의 테이블을 합침.
"WHERE문을 작성할때 SEATSMAX-SEATSOCC 값이 0이 되는 데이터를 제거하기 위해서 SEATSMAX가 SEATSOCC보다
"큰 데이터만 가져오도록 함.
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
     ON a~carrid = b~carrid AND a~connid = b~connid
     INNER JOIN scarr AS c
     ON a~carrid = c~carrid
     INTO CORRESPONDING FIELDS OF TABLE @gt_airinfo
     WHERE b~fldate >= '20190101' and b~seatsmax > b~seatsocc.

"DISTID 필드가 MI이면 KM로 변경하고 DISTANCE필드의 값에 1.60934를 곱하여 KM에 맞는 거리값으로 수정해줌.
"TRUNC()함수를 이용하여 소수점 아래부분을 버림
"SEATSREMAIN 필드를 SEATSMAX-SEATSOCC로 계산하여 채워주고 MODIFY를 이용하여 테이블에 수정된 값을 넣어줌.
LOOP AT gt_airinfo INTO gs_airinfo.
  IF gs_airinfo-distid = 'MI'.
    gs_airinfo-distid = 'KM'.
    gs_airinfo-distance = trunc( gs_airinfo-distance * '1.60934' ).
  ENDIF.
  gs_airinfo-seatsremain = gs_airinfo-seatsmax - gs_airinfo-seatsocc.
  MODIFY gt_airinfo FROM gs_airinfo TRANSPORTING seatsremain distid distance.
ENDLOOP.

SORT gt_airinfo BY seatsremain ASCENDING.

cl_demo_output=>display( gt_airinfo ).


*--------------------------------------------------------------------------------------------------------------------------*
*참고 문제. spfli 테이블의 데이터를 활용해 다음 조건을 만족하는 모든 환승 경로를 찾아 출력하세요.
*조건 1: 출발 도시가 'NEW YORK'인 항공편을 첫 번째 구간으로 선택하세요.
*조건 2: 첫 번째 구간 항공편의 도착 도시를 경유지로 삼아, 그곳에서출발하는 항공편을 두 번째 구간으로 선택하세요.
*조건 3: 두 번째 구간 항공편의 도착 도시는 'SINGAPORE'여야 합니다.
*힌트:spfli 테이블의 데이터를 모두 읽어와 이중 반복문(nested loop)을 사용하여논리적으로 연결되는 경로를 찾으세요.
*--------------------------------------------------------------------------------------------------------------------------*
DATA: gt_flights  TYPE TABLE OF spfli,
      gs_flight1  TYPE spfli,
      gs_flight2  TYPE spfli.

" 1. 전체 비행 일정 데이터를 읽어옵니다.
SELECT * FROM spfli INTO TABLE gt_flights.

"AT 25 의미: 현재 줄의 25번째 칸부터 글자를 찍기 시작하라는 뜻.
"AT 25가 없으면 왼쪽(첫번째 칸)부터 글자가 출력됨
"SKIP 1은 한줄을 띄우라는 뜻.
WRITE: AT 25 '< 환승 경로 탐지 프로그램 >', /.
SKIP 1.

" 2. 첫 번째 루프: 출발지가 'NEW YORK'인 비행편을 찾습니다.
"SELECT 할때 모든 데이터를 가져오고 LOOP AT에서 WHERE을 이용하여 출발지가 NEW YORK인 데이터만 반복하도록 설정
LOOP AT gt_flights INTO gs_flight1 WHERE cityfrom = 'NEW YORK'.

  " 3. 두 번째 루프: 첫 번째 비행의 도착지(cityto)가
  " 나의 출발지(cityfrom)가 되고, 최종 목적지가 'SINGAPORE'인 항공편을 찾습니다.
  "도착지가 SINGAPORE이면서 출발지가 gs_flight1의 도착지와 동일한 데이터만 반복하도록 설정.
  LOOP AT gt_flights INTO gs_flight2
    WHERE cityfrom = gs_flight1-cityto
      AND cityto   = 'SINGAPORE'.

    WRITE: / '✅ 환승 경로 발견!'.
    WRITE: / '-------------------------------------------------------------------'.
    WRITE: / '  1단계:', gs_flight1-carrid, gs_flight1-connid,
             ' | ', gs_flight1-cityfrom, ' -> ', gs_flight1-cityto.
    WRITE: / '  2단계:', gs_flight2-carrid, gs_flight2-connid,
             ' | ', gs_flight2-cityfrom, ' -> ', gs_flight2-cityto.
    WRITE: / '-------------------------------------------------------------------'.
    SKIP 1.

  ENDLOOP. " 두 번째 루프 종료

ENDLOOP. " 첫 번째 루프 종료

" 만약 검색 결과가 없을 때를 대비한 로직 (선택 사항)
IF sy-subrc <> 0.
  WRITE: / '검색된 환승 경로가 없습니다.'.
ENDIF.
*--------------------------------------------------------------------------------------------------------------------------*
*실습 5부터는 강의자료 참고하고, 새로운 프로그램 생성해서 진행하기
