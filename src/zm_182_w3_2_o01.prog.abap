*&---------------------------------------------------------------------*
*& Include zm_182_w3_2_o01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv OUTPUT.
  IF go_grid IS INITIAL.
    CREATE OBJECT go_docking
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = go_docking->dock_at_top
        extension = 2000.
    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_docking.

*&---------------------------------------------------------------------*
    DATA: ls_fcat TYPE lvc_s_fcat.
    REFRESH gt_fcat.
*&---------------------------------------------------------------------*
* Call Function LVC_FIELDCATALOG_MERGE 형식 (Pattern 기능 이용)
*CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
* EXPORTING
*   I_BUFFER_ACTIVE        =     " 필드 카탈로그 정보를 메모리(Buffer)에 저장할지 여부
*   I_STRUCTURE_NAME       =     " 참조한 DB 테이블, 구조체 이름을 대문자로 입력(필수)
*   I_CLIENT_NEVER_DISPLAY = 'X' " X로 설정하면 클라이언트 필드(MANDT)를 화면에서 자동으로 숨김
*   I_BYPASSING_BUFFER     =     " X: 버퍼를 무시하고 항상 DB에서 새로 읽어오도록 함
*   I_INTERNAL_TABNAME     =     " DB 구조체가 아니라 프로그램 내에 정의된 로컬 테입르 정보를 읽을 때 사용
* CHANGING
*   ct_fieldcat            =     " 최종 필드 카탈로그가 담기는 인터널 테이블을 의미함
* EXCEPTIONS                     " 예외처리(실패 시 1~3 리턴)
*   INCONSISTENT_INTERFACE = 1   " 파라미터 타입이 서로 맞지 않을 때 발생
*   PROGRAM_ERROR          = 2   " 구조체 이름이 틀렸거나, 시스템 내부적인 오류가 났을 때 발생
*   OTHERS                 = 3   " 다른 예외사항

*IF sy-subrc <> 0.
* Implement suitable error handling here
*ENDIF.
*&---------------------------------------------------------------------*
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE' " Call Function을 통해서 자동으로 필드카탈로그 생성
      EXPORTING
        i_structure_name = 'MAKT'          " DB에 있는 MAKT 테이블의 구조를 가져오라고 명령
      CHANGING
        ct_fieldcat      = gt_fcat.        " 가져온 구조를 gt_fcat 테이블에 넣어줌

    LOOP AT gt_fcat INTO ls_fcat.          " Loop문을 이용하여 필드이름, 길이 지정
      ls_fcat-just = 'L'.
      ls_fcat-outputlen = 4.
      CASE ls_fcat-fieldname.
        WHEN 'MATNR'.
          ls_fcat-coltext = '자재 번호'.
        WHEN 'SPRAS'.
          ls_fcat-coltext = '언어'.
        WHEN 'MAKTX'.
          ls_fcat-coltext = '자재 설명(소)'.
          ls_fcat-outputlen = 12.
        WHEN 'MAKTG'.
          ls_fcat-coltext = '자재 설명(대)'.
          ls_fcat-outputlen = 12.
      ENDCASE.
      MODIFY gt_fcat FROM ls_fcat.          " 한 번의 modify 문으로 간단하고 빠르게 데이터 입력
    ENDLOOP.

*    LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<fs>). " <fs>: field symbol(데이터 주소를 직접 가리킴)
                                                   " INTO 대신 ASSIGNING 사용
                                                   " gt_fcat 테이블 내부 값이 즉시 변경됨(modify 필요X)
*      <fs>-just = 'L'.
*      CASE <fs>-fieldname.
*       WHEN 'MATNR'.
*          <fs>-coltext = '자재 번호'.
*          <fs>-outputlen = 18.
*       WHEN 'SPRAS'.
*          <fs>-coltext = '언어'.
*          <fs>-outputlen = 4.
*       WHEN 'MAKTX'.
*          <fs>-coltext = '자재 설명(소)'.
*          <fs>-outputlen = 20.
*       WHEN 'MAKTG'.
*          <fs>-coltext = '자재 설명(대)'.
*          <fs>-outputlen = 20.
*     ENDCASE.
*   ENDLOOP.


    CLEAR: gs_layout.
    gs_layout-zebra = 'X'.
    gs_layout-cwidth_opt = 'X'.
    gs_layout-sel_mode = 'A'.
    gs_layout-grid_title = '자재 설명'.

*&---------------------------------------------------------------------*
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        i_save          = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_makt
        it_fieldcatalog = gt_fcat.

*&---------------------------------------------------------------------*
  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDMODULE.
