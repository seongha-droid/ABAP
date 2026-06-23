*&---------------------------------------------------------------------*
*& Include zm_182_w3_team_f01
*&---------------------------------------------------------------------*

FORM get_data.

  CLEAR gt_sflight.

  IF p_all = 'X'.
    SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_sflight.

  ELSEIF p_carr = 'X'.
    SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_sflight
    WHERE carrid = 'AA'.

  ELSEIF p_type = 'X'.
    SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_sflight
    WHERE planetype = '747-400'.

  ELSEIF p_date = 'X'.
    SELECT *
    FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_sflight
    WHERE fldate BETWEEN '00000000' AND sy-datum. " 오늘 이후 날짜의 항공편만 가져옴
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*

FORM display_alv.

  IF go_alv IS INITIAL.         " go_alv에 아무것도 담겨있지 않다면 새로 생성하고 그렇지 않으면 refresh만 진행
    TRY.                        " try catch 구문을 통하여 오류에도 대처할 수 있게 설계
        cl_salv_table=>factory( " cl_salv_table클래스의 static 메소드 factory를 호출하여 인스턴스 생성
        IMPORTING               " IMPORTING: 생성이 완료된 cl_salv_table 클래스의 인스턴스 참조값을 반환
        r_salv_table = go_alv   "            받아 전경 참조 변수인 go_alv에 할당한다.
        CHANGING                " CHANGING: 화면에 띄울 데이터가 담긴 인터널 테이블을 매개변수로 전달
        t_table = gt_sflight ).

        DATA(lo_functions) = go_alv->get_functions( ).
        " DATA(lo_functions): 최신 ABAP 문법. 변수 선언과 동시에 값을 집어넣는 방법.
        " 생성된 ALV 인스턴스(go_alv)의 메소드를 호출하여 ALV의 상단 툴바 기능을 제어하는 참조값을 반환받아
        " lo_functions에 할당한다.
        lo_functions->set_all( abap_true ).
        " set_all 메소드에 abap_true라는 인자를 전달하여 ALV 표준 컨트롤에서 제공하는 모든 부가 기능을 활성화함.

        go_alv->display( ). " 내부적으로 완성된 ALV를 화면에 보여줌

      CATCH cx_salv_msg.       " SALV를 만들다가 발생하는 특수한 에러의 경우에 시스템을 멈추지 않고 오류메시지 출력
        MESSAGE 'ALV 생성 중 오류가 발생했습니다.' TYPE 'E'.
    ENDTRY.

  ELSE.
    go_alv->refresh( ).
  ENDIF.
ENDFORM.
