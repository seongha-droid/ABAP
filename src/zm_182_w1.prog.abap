*&---------------------------------------------------------------------*
*& Report zm_182_w1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zm_182_w1.
*&---------------------------------------------------------------------*
*& 1주차: 26-1 ERP 연구회 회원 정보를 다루는 ABAP 기초 실습 프로그램입니다.
*&---------------------------------------------------------------------*


*--------------------------------------------------------------------*
* 1. 단일 변수 선언 및 값 할당
* 숫자형 데이터 하나와 텍스트형 데이터 하나를 생성하고, 임의의 값을 넣어주세요.
* Keyword(DATA, C 타입은 Length를 적절하게 지정해주기)
* cl_demo_output=>display (변수/스트럭처/인터널테이블명)을 사용해서 값이 잘 들어갔는지 확인
* ㄴ> WRITE보다 간편하고 보기좋은 출력방식이에요. (cl_demo_output 클래스의 display 메소드-> 객제지향개념 참고만!)
*--------------------------------------------------------------------*
TYPES: ty_int  TYPE i,
       ty_char TYPE c LENGTH 10.

DATA: gv_int  TYPE ty_int,
      gv_char TYPE ty_char.

gv_int = 1.
gv_char = '123'.

cl_demo_output=>display( gv_int ).
cl_demo_output=>display( gv_char ).

*--------------------------------------------------------------------*
* 2. Structure TYPE을 선언 (Structure(구조체)는 BEGIN OF, END OF 사용)
* -> ERP 연구회 회원 정보 구조를 정의해봅시다.
*    멤버ID(member_id: 숫자), 이름(name: 문자), 역할(role: 문자)구조를 가지도록 선언
*--------------------------------------------------------------------*

TYPES: BEGIN OF ty_str,
         member_id TYPE i,
         name      TYPE c LENGTH 4,
         role      TYPE c LENGTH 5,
       END OF ty_str.

*--------------------------------------------------------------------*
* 3. 2번에서 만든 Structure TYPE을 참조하여 스트럭처와 인터널 테이블 생성
*    인터널 테이블은 Standard Table를 사용하고, WITH NON-UNIQUE KEY 구문을 사용하시오.
*    NON-UNIQUE KEY의 의미: 키를 명시적으로 지정해줌 + 유일성 X, 중복가능
*   (KEY 지정을 안해주면 자동으로 모든 C,N 타입 필드를 KEY로 자동 지정.)
"   [왜 Standard 테이블은 UNIQUE KEY 사용이 안될까?-> 생각해보고 찾아보기]
*--------------------------------------------------------------------*

DATA: gs_str1 TYPE ty_str,
      gt_tab1 TYPE TABLE OF ty_str WITH NON-UNIQUE KEY member_id.

*--------------------------------------------------------------------*
* 4. LIKE 문을 사용해서 또 다른 스트럭처와 인터널 테이블을 생성해봅시다.
* 인터널 테이블을 Like로 복사하면 인터널 테이블이 생성된다. 테이블의 구조만 가져와서 스트럭쳐를 생성할 때는,
* LIKE LINE OF 구문을 사용
*--------------------------------------------------------------------*

DATA: gs_str2 LIKE LINE OF gt_tab1,
      gt_tab2 LIKE gt_tab1.

*--------------------------------------------------------------------*
* 5. 3번에서 만든 Structure에 값을 담아 봅시다.
* 인터널 테이블을 다루려면 스트럭처를 사용해야 합니다.
* 스트럭처에 접근할 때 ABAP은 Hyphen (-)을 이용합니다.
* 스트럭처 이름-변수(필드)이름 = '넣을 값'.
* 넣을 값은 타입에 맞는 값으로 임의로 넣어보세요.
* cl_demo_output=>display_data( 스트럭쳐 이름 ). 으로 잘 담겼는지 확인해봅시다
*--------------------------------------------------------------------*

gs_str1-member_id = 1.
gs_str1-name = '정성균'.
gs_str1-role = '학회장'.

cl_demo_output=>display_data( gs_str1 ).

*--------------------------------------------------------------------*
*6. 5번에서 연습한 것처럼 스트럭처에 값 담고 인터널 테이블에 추가 (APPEND)
* -> 정성균, 조장 이름, 자신 이름 3명의 정보를 3번에서 만든 Internal table에 추가합니다.
* 인터널 테이블은 스트럭쳐를 통해 핸들링합니다.
* 스트럭쳐에 값을 담고 APPEND, CLEAR 스트럭쳐 / 담고 APPEND, CLEAR 스트럭쳐...
* 넣을 값은 제공된 표를 참고하시오.
* 클리어를 해야하는 이유 생각해보기.
*cl_demo_output=>display( 변수/스트럭처/인터널테이블명 ) 통해서 값이 잘 들어갔는지 확인.
*--------------------------------------------------------------------*

APPEND gs_str1 TO gt_tab1.
CLEAR gs_str1.

gs_str1-member_id = 2.
gs_str1-name = '김태섭'.
gs_str1-role = '1조 조장'.
APPEND gs_str1 TO gt_tab1.
CLEAR gs_str1.

gs_str1-member_id = 3.
gs_str1-name = '장성하'.
gs_str1-role = '신입학회원'.
APPEND gs_str1 TO gt_tab1.
CLEAR gs_str1.

cl_demo_output=>display( gt_tab1 ).

*--------------------------------------------------------------------*
* 6-1. 인터널 테이블 값 수정 (MODIFY)
* -> 2026-1학기가 시작되어 연구회 구성원의 역할이 변동되었습니다.
* 팀원의 role->O조 조원, 조장의 role -> O조 조장
* 다음과 같은 변동을 Internal Table에 반영하시오.
* MODIFY __ FROM ___ TRANSPORTING __ WHERE __ = ' '
*cl_demo_output=>display( 변수/스트럭처/인터널테이블명 ) 통해서 참고 사진과 비교해보기.
*--------------------------------------------------------------------*

gs_str1-role = '1조 조원'.
MODIFY gt_tab1 FROM gs_str1 TRANSPORTING role WHERE member_id = 3.
CLEAR gs_str1.

cl_demo_output=>display( gt_tab1 ).

*--------------------------------------------------------------------*
* 6-2. 인터널 테이블 값 삭제 (DELETE)
* -> 정성균 학회장이 탈주를 하게 되어 학회에 출석하지 못하게 되었습니다 ;;
* 정성균 학회장의 모든 데이터를 테이블에서 삭제하세요..
* cl_demo_output=>display( 변수/스트럭처/인터널테이블명 ) 통해서 확인
*--------------------------------------------------------------------*

DELETE gt_tab1 WHERE member_id = 1.

cl_demo_output=>display( gt_tab1 ).

*--------------------------------------------------------------------*
* 6-3. 인터널 테이블 값 삽입 (INSERT)
* -> 새로운 회원 '???'이 입회하였습니다. 다른 조원 이름 아무나~
*    신입 학회원 정보를 테이블의 '첫번째 줄'에 추가해주세요~ (INDEX 활용)
* cl_demo_output=>display( 변수/스트럭처/인터널테이블명 ) 통해서 확인
*--------------------------------------------------------------------*

gs_str1-member_id = 1.
gs_str1-name = '김은수'.
gs_str1-role = '신입학회원'.
INSERT gs_str1 INTO gt_tab1 INDEX 1.
CLEAR gs_str1.

cl_demo_output=>display( gt_tab1 ).

*--------------------------------------------------------------------*
* 7. 도전
* SFLIGHT는 SAP Dictionary의 DB 테이블입니다.
* SAP에서 제공하는 Dictionary에 존재하는 SFLIGHT 테이블(비행 정보 테이블)을 이용해서
* Airline Code, Flight date, Airfare의 정보를 담을 수 있는 스트럭처와 인터널 테이블을 생성하고,
* 임의로 값을 넣고 출력하시오.
* HINT:
* GUI버전: se11에 접속하여 sflight에 대한 정보와 데이터를 조회할 수 있습니다.(/o se11)
* ADT버전: Ctrl+Shift+A로 빠르게 SFLGIHT 검색 or sflight를 ctrl+클릭. ALT키+ <-로 마우스 없이 왔다 갔다 창 이동하면 편리
*         필드, 테이블명에 커서두고 F2를 누르면 필드들의 정보를 확인할 수 있다.
* sflight에 있는 각 필드에 대한 설명이 있으니 각 정보를 뜻하는 적절한 필드를 선택하세요.
*       __ TYPE sflight-??? 를 통해 SFLIGHT에 있는 필드 구조로 스트럭쳐 타입 생성 후 스트럭쳐와 인터널테이블 생성.
*--------------------------------------------------------------------*

TABLES: sflight.

TYPES: BEGIN OF ty_sflight,
         carrid TYPE sflight-carrid,
         fldate TYPE sflight-fldate,
         price  TYPE sflight-price,
       END OF ty_sflight.

DATA: gs_sfl TYPE ty_sflight,
      gt_sfl TYPE TABLE OF ty_sflight.

gs_sfl-carrid = 'SQ'.
gs_sfl-fldate = '20260317'.
gs_sfl-price = 1000.
APPEND gs_sfl TO gt_sfl.
CLEAR gs_sfl.

cl_demo_output=>display( gt_sfl ).
