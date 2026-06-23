*&---------------------------------------------------------------------*
*& Include zm_182_w3_o01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT. " 100번 화면 상태 설정(버튼, 타이틀)
  SET PF-STATUS 'S100'.    " 버튼 설정 (Back, Exit, Cancel)
  SET TITLEBAR 'T100'.     " 화면 타이틀 설정 (SFLIGHT 조회)
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv OUTPUT.
  IF go_grid IS INITIAL.         " 화면이 처음에 로드될 때만 ALV 객체를 생성하게 함.
                                 " if문이 없다면 이미 만들어진 것을 다시 만들고 비효율적임
                                 " 기존 객체를 재사용하여 효율성을 높이기 위함
    CREATE OBJECT go_docking     " 컨테이너 생성(도킹 컨테이너)
      EXPORTING                  " 컨테이너에서 보여줄 내용 설정
        repid     = sy-repid     " sy-repid: 현재 실행중인 프로그램의 이름을 담은 시스템변수
                                 " 현재 실행중인 프로그램에 컨테이너를 생성하라는 뜻
        dynnr     = sy-dynnr     " sy-dynnr: 현재 띄워져 있는 화면 번호를 담은 시스템변수
                                 " 현재 화면 번호에 컨테이너를 붙여달라는 뜻.
        side      = go_docking->dock_at_top " 컨테이너 화면을 어느쪽에 붙일지 위치 지정
                                 " dock_at_bottom, dock_at_left, dock_at_right
        extension = 2000.        " 생성되는 컨테이너의 크기(너비 or 높이)를 지정

    CREATE OBJECT go_grid        " 그리드 생성
      EXPORTING
        i_parent = go_docking.   " 그리드와 컨테이너 연결

*----------------------------------------------------------------------*
    "필드 카탈로그 수동 생성
    DATA: ls_fcat TYPE lvc_s_fcat. " 필트카탈로그 스트럭처 생성
    REFRESH gt_fcat.

    CLEAR: ls_fcat.
    ls_fcat-fieldname = 'CARRID'.  " ALV표와 연결되는 실제 인터널테이블의 필드명
    ls_fcat-coltext = '코드'.       " ALV화면에서 보여질 칼럼명
    ls_fcat-just = 'C'.            " 가운데 정렬. L(왼쪽정렬), R(오른쪽정렬)
    ls_fcat-outputlen = 4.         " 칼럼의 너비 4칸 크기로 설정
    APPEND ls_fcat TO gt_fcat.     " gt_fcat 테이블에 append 해줘야 함.

    CLEAR: ls_fcat.
    ls_fcat-fieldname = 'CONNID'.
    ls_fcat-coltext = '번호'.
    ls_fcat-just = 'C'.
    ls_fcat-outputlen = 4.
    APPEND ls_fcat TO gt_fcat.

    CLEAR: ls_fcat.
    ls_fcat-fieldname = 'FLDATE'.
    ls_fcat-coltext = '비행 날짜'.
    ls_fcat-just = 'C'.
    ls_fcat-outputlen = 12.
    APPEND ls_fcat TO gt_fcat.

    CLEAR: gs_layout.                 " 레이아웃 설정
    gs_layout-zebra = 'X'.            " ALV 화면 얼룩말무늬로 디자인 설정 'X'는 true와 같은 뜻.
    gs_layout-cwidth_opt = 'X'.       " 칼럼의 너비를 데이터 길이에 맞춰 자동 조정
    gs_layout-sel_mode = 'A'.         " 선택하는 모드 지정. 'A': 여러 행과 여러 열 자유롭게 선택
                                      " 왼쪽에 행 전체를 선택할 수 있는 작은 네모 버튼을 생성.
    gs_layout-grid_title = '항공편 목록'. " ALV 상단 제목

*-------------------------------------------------------------------------*
    CALL METHOD go_grid->set_table_for_first_display
    " go_grid(그리드)에게 화면에 표를 그리라고 명령하는 메소드(데이터 Display)
    " ALV Grid에 데이터를 처음 표시할 때 호출하는 메소드
      EXPORTING                        " 설정값 전달(파라미터 값 전달), 호출자 -> 메소드(단방향)
*        i_structure_name = 'SFLIGHT'   " DB의 sflight 테이블 구조를 사용하겠다는 뜻
        i_save           = 'X'         " 사용자가 ALV화면에서 열순서 변경, 필터, 정렬 등을 바꾼
                                       " 레이아웃을 자신만의 설정으로 저장할 수 있도록 하는것.
                                       " 'X': 저장허용, ' ': 저장불가
        i_default        = ' '         " 기본 레이아웃을 사용할지 여부를 나타냄
                                       " ' ': 기본 레이이웃 사용 강제X, 'X': 기본 레이아웃 자동 사용
        is_layout        = gs_layout   " 위에서 만든 레이아웃 구조체를 전달
      CHANGING                         " 설정값 전달 및 메소드 수정 가능, 호출차 <-> 메소드(양방향)
        it_outtab        = gt_sflight  " 실제로 ALV에 표시될 데이터 테이블(gt_sflight)
        it_fieldcatalog  = gt_fcat.    " 각 컬럼의 속성을 정의한 Field Catalog 테이블
*-----------------------------------------------------------------------*
  ELSE.
    CALL METHOD go_grid->refresh_table_display. " ALV Grid 화면을 새로고침만 하는 메소드
                                                " 이미 go_grid가 설정되어 있으면 새로 생성하지 않고 새로고침만 진행

  ENDIF.
ENDMODULE.
