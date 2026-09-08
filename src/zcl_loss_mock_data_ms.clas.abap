" -----------------------------------------------------------------------------
" [클래스 역할]
" Fiori 시연에 필요한 외주처/자재/평가/PO Item/결과 데이터를 한 번에 생성한다.
" ADT에서 F9(Run As > ABAP Application Console)로 실행하는 일회성 적재 클래스다.
" 화면에서 계산하지 않고, 운영 로직과 동일한 계산식을 사용해 결과 테이블까지 만든다.
" -----------------------------------------------------------------------------
CLASS zcl_loss_mock_data_ms DEFINITION
  " 다른 패키지에서도 실행할 수 있는 공개 클래스다.
  PUBLIC
  " 상속을 허용하지 않는 최종 클래스다.
  FINAL
  " 외부에서 인스턴스를 생성할 수 있다.
  CREATE PUBLIC.

  PUBLIC SECTION.
    " ADT Console 실행 진입점 main 메서드를 제공하는 표준 인터페이스다.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_loss_mock_data_ms IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " 외주처별 담당 완제품을 표현하는 임시 구조 타입이다.
    " 예: supplier_no=1, material=FG-STL-S이면 1번 외주처가 S 자재를 담당한다.
    TYPES:
      BEGIN OF ty_assignment,
        supplier_no          TYPE i,
        finished_material_id TYPE zloss_mat_ms-material_id,
      END OF ty_assignment.

    " 모든 평가에서 공통으로 사용하는 고정 업무 규칙이다.
    " 원자재 단가 800 KRW/KG, 외주처 40%, 본사 60% 배분을 적용한다.
    CONSTANTS lc_raw_price      TYPE zloss_res_ms-raw_material_price VALUE '800.00'.
    CONSTANTS lc_supplier_share TYPE zloss_res_ms-supplier_share     VALUE '0.4000'.
    CONSTANTS lc_company_share  TYPE zloss_res_ms-company_share      VALUE '0.6000'.

    " DB에 한 번에 INSERT할 데이터를 먼저 메모리 내부 테이블에 생성한다.
    DATA lt_material   TYPE STANDARD TABLE OF zloss_mat_ms WITH EMPTY KEY.
    DATA lt_supplier   TYPE STANDARD TABLE OF zloss_sup_ms WITH EMPTY KEY.
    DATA lt_header     TYPE STANDARD TABLE OF zloss_hdr_ms WITH EMPTY KEY.
    DATA lt_item       TYPE STANDARD TABLE OF zloss_itm_ms WITH EMPTY KEY.
    DATA lt_result     TYPE STANDARD TABLE OF zloss_res_ms WITH EMPTY KEY.
    DATA lt_assignment TYPE STANDARD TABLE OF ty_assignment WITH EMPTY KEY.

    " 생성/계산 시각과 전 평가에서 중복되지 않는 PO 번호 카운터다.
    DATA lv_timestamp     TYPE timestampl.
    DATA lv_calculated_at TYPE utclong.
    DATA lv_po_counter    TYPE i VALUE 1.

    " RAP 관리 필드용 타임스탬프와 결과 계산 시각을 실행 시점 기준으로 설정한다.
    GET TIME STAMP FIELD lv_timestamp.
    lv_calculated_at = utclong_current( ).

    " -------------------------------------------------------------------------
    " 1단계: 자재 기준정보 생성
    " 원자재는 RM-HRC 한 종류, 완제품은 S/M/L 세 종류를 사용한다.
    " standard_weight는 완제품 중량, standard_input_qty는 개당 표준 투입량이다.
    " -------------------------------------------------------------------------
    lt_material = VALUE #(
      ( client = sy-mandt material_id = 'RM-HRC'
        material_name = '열연강판 코일' material_type = 'RM'
        base_uom = 'KG' weight_uom = 'KG' active_flag = 'X' )
      ( client = sy-mandt material_id = 'FG-STL-S'
        material_name = '소형 절단 강판' material_type = 'FG'
        base_uom = 'EA' standard_weight = '5.000'
        standard_input_qty = '5.300' weight_uom = 'KG' active_flag = 'X' )
      ( client = sy-mandt material_id = 'FG-STL-M'
        material_name = '중형 절단 강판' material_type = 'FG'
        base_uom = 'EA' standard_weight = '10.000'
        standard_input_qty = '10.200' weight_uom = 'KG' active_flag = 'X' )
      ( client = sy-mandt material_id = 'FG-STL-L'
        material_name = '대형 절단 강판' material_type = 'FG'
        base_uom = 'EA' standard_weight = '20.000'
        standard_input_qty = '20.100' weight_uom = 'KG' active_flag = 'X' ) ).

    " -------------------------------------------------------------------------
    " 2단계: List Page에 표시할 외주처 10곳 생성
    " 모든 외주처에 동일한 40:60 배분율을 지정한다.
    " -------------------------------------------------------------------------
    lt_supplier = VALUE #(
      ( client = sy-mandt supplier_id = 'SUP0000001' supplier_name = '대한스틸'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000002' supplier_name = '한강금속'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000003' supplier_name = '미래철강'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000004' supplier_name = '동양가공'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000005' supplier_name = '세진강판'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000006' supplier_name = '대성메탈'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000007' supplier_name = '한국정밀'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000008' supplier_name = '신우산업'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000009' supplier_name = '태광철강'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' )
      ( client = sy-mandt supplier_id = 'SUP0000010' supplier_name = '우진스틸'
        supplier_share = lc_supplier_share company_share = lc_company_share active_flag = 'X' ) ).

    " -------------------------------------------------------------------------
    " 3단계: 외주처별 담당 자재 조합 정의
    " 외주처마다 S만, S/M, M/L, S/M/L 등 서로 다른 현장 구성을 만든다.
    " 이 목록이 PO 데이터와 Object Page 자재 탭의 실제 데이터 범위를 결정한다.
    " -------------------------------------------------------------------------
    lt_assignment = VALUE #(
      ( supplier_no = 1  finished_material_id = 'FG-STL-S' )
      ( supplier_no = 1  finished_material_id = 'FG-STL-M' )
      ( supplier_no = 2  finished_material_id = 'FG-STL-M' )
      ( supplier_no = 2  finished_material_id = 'FG-STL-L' )
      ( supplier_no = 3  finished_material_id = 'FG-STL-S' )
      ( supplier_no = 4  finished_material_id = 'FG-STL-S' )
      ( supplier_no = 4  finished_material_id = 'FG-STL-M' )
      ( supplier_no = 5  finished_material_id = 'FG-STL-L' )
      ( supplier_no = 6  finished_material_id = 'FG-STL-S' )
      ( supplier_no = 6  finished_material_id = 'FG-STL-M' )
      ( supplier_no = 6  finished_material_id = 'FG-STL-L' )
      ( supplier_no = 7  finished_material_id = 'FG-STL-S' )
      ( supplier_no = 8  finished_material_id = 'FG-STL-M' )
      ( supplier_no = 8  finished_material_id = 'FG-STL-L' )
      ( supplier_no = 9  finished_material_id = 'FG-STL-L' )
      ( supplier_no = 10 finished_material_id = 'FG-STL-S' )
      ( supplier_no = 10 finished_material_id = 'FG-STL-M' )
      ( supplier_no = 10 finished_material_id = 'FG-STL-L' ) ).

    " -------------------------------------------------------------------------
    " 4단계: 2025년과 2026년 평가 Header 및 PO Item 생성
    " 바깥 DO 2회는 연도, 안쪽 DO 10회는 외주처를 의미한다.
    " 결과적으로 평가 Header는 2년 × 10개 외주처 = 20건이다.
    " -------------------------------------------------------------------------
    DO 2 TIMES.
      " sy-index는 현재 반복 순번이다. 첫 반복은 2025년, 두 번째는 2026년이다.
      DATA(lv_year_index) = sy-index.
      DATA lv_year TYPE zloss_hdr_ms-evaluation_year.
      IF lv_year_index = 1.
        lv_year = '2025'.
      ELSE.
        lv_year = '2026'.
      ENDIF.

      DO 10 TIMES.
        " 외주처 순번으로 SUP0000001 형태의 ID를 동적으로 만든다.
        " WIDTH/PAD 옵션은 부족한 자릿수를 왼쪽 0으로 채운다.
        DATA(lv_supplier_no) = sy-index.
        DATA(lv_supplier_id) = CONV zloss_sup_ms-supplier_id(
          |SUP{ lv_supplier_no WIDTH = 7 ALIGN = RIGHT PAD = '0' }| ).
        " 평가 ID 형식: EV + 연도 + '-' + 외주처 4자리 순번.
        DATA(lv_evaluation_id) = CONV zloss_hdr_ms-evaluation_id(
          |EV{ lv_year }-{ lv_supplier_no WIDTH = 4 ALIGN = RIGHT PAD = '0' }| ).

        " 외주처 번호 구간에 따라 플랜트 1000/1100/1200을 배정한다.
        DATA lv_plant TYPE zloss_hdr_ms-plant.
        IF lv_supplier_no <= 4.
          lv_plant = '1000'.
        ELSEIF lv_supplier_no <= 7.
          lv_plant = '1100'.
        ELSE.
          lv_plant = '1200'.
        ENDIF.

        " 외주처마다 기준 Loss율이 완전히 같지 않도록 5.5%부터 단계적으로 만든다.
        " 내부 저장값은 백분율이 아닌 소수이므로 0.055000은 5.5%를 뜻한다.
        DATA(lv_baseline_df) =
          CONV decfloat34( '0.055000' )
          + CONV decfloat34( lv_supplier_no MOD 4 )
          * CONV decfloat34( '0.002500' ).
        DATA(lv_baseline) = CONV zloss_hdr_ms-baseline_abnormal_loss_rate(
          lv_baseline_df ).

        " 2025년은 모두 완료, 2026년은 앞의 4개 외주처만 완료로 구성한다.
        " C=정산 완료, P=정산 미완료.
        DATA lv_status TYPE zloss_hdr_ms-evaluation_status.
        IF lv_year = '2025' OR lv_supplier_no <= 4.
          lv_status = 'C'.
        ELSE.
          lv_status = 'P'.
        ENDIF.

        " 평가 안에서 사용할 Item 번호와 실제 DISTINCT PO 개수의 누적 변수다.
        DATA(lv_item_no) = 0.
        DATA(lv_eval_po_count) = 0.

        " 세 번째 패턴마다 미개선 데이터를 의도적으로 만들어 비교 시연이 가능하게 한다.
        " xsdbool은 논리식 결과를 ABAP_BOOLEAN의 X/공백으로 변환한다.
        DATA(lv_improved) = xsdbool(
          ( lv_supplier_no + lv_year_index ) MOD 3 <> 0 ).

        " PO를 만들기 전에 평가 Header를 먼저 메모리 테이블에 추가한다.
        " po_count는 아래 Item 생성이 끝난 후 실제 개수로 다시 갱신한다.
        APPEND VALUE #(
          client = sy-mandt
          evaluation_id = lv_evaluation_id
          supplier_id = lv_supplier_id
          plant = lv_plant
          raw_material_id = 'RM-HRC'
          baseline_abnormal_loss_rate = lv_baseline
          evaluation_year = lv_year
          po_count = 0
          evaluation_status = lv_status
          created_by = sy-uname
          created_at = lv_timestamp
          last_changed_by = sy-uname
          local_last_changed_at = lv_timestamp ) TO lt_header.

        " 현재 외주처에 배정된 자재만 WHERE 조건으로 반복한다.
        DATA(lv_material_seq) = 0.
        LOOP AT lt_assignment INTO DATA(ls_assignment)
          WHERE supplier_no = lv_supplier_no.
          lv_material_seq += 1.

          " 자재 기준정보를 읽어 표준 중량/투입량 계산에 사용한다.
          READ TABLE lt_material INTO DATA(ls_finished_material)
            WITH KEY material_id = ls_assignment-finished_material_id.
          IF sy-subrc <> 0.
            " 기준정보가 없으면 계산할 수 없으므로 해당 자재를 건너뛴다.
            CONTINUE.
          ENDIF.

          " S/M/L을 각각 숫자 1/2/3으로 변환해 PO 개수 변화식에 사용한다.
          DATA lv_material_code TYPE i.
          CASE ls_assignment-finished_material_id.
            WHEN 'FG-STL-S'.
              lv_material_code = 1.
            WHEN 'FG-STL-M'.
              lv_material_code = 2.
            WHEN OTHERS.
              lv_material_code = 3.
          ENDCASE.
          " 자재별 PO 수를 4~8건 범위에서 다르게 만든다.
          " 외주처·자재·연도 조합이 달라지면 같은 개수로 고정되지 않는다.
          DATA(lv_material_po_count) =
            4 + ( ( lv_supplier_no + lv_material_code * 2 + lv_year_index ) MOD 5 ).

          " -------------------------------------------------------------------
          " 현재 자재에 필요한 PO 수만큼 Item을 생성한다.
          " 시연 데이터에서는 PO 1개당 관련 Item 1개를 생성하고,
          " PO Item 번호는 00010/00020/00030 중 하나로 변화시킨다.
          " -------------------------------------------------------------------
          DO lv_material_po_count TIMES.
            DATA(lv_po_seq) = sy-index.
            " 45로 시작하는 10자리 PO 번호를 전체 평가에서 순차 생성한다.
            DATA(lv_po_number) = CONV zloss_itm_ms-purchase_order(
              |45{ lv_po_counter WIDTH = 8 ALIGN = RIGHT PAD = '0' }| ).
            " 평가 Header에 기록할 PO 개수를 1 증가시킨다.
            lv_eval_po_count += 1.

            " 외주처·자재·PO 순번에 따라 구매오더 Item을 10/20/30으로 변화시킨다.
            DATA(lv_po_item_value) =
              10 + ( ( lv_supplier_no + lv_material_code + lv_po_seq ) MOD 3 ) * 10.
            DATA(lv_po_item) = CONV zloss_itm_ms-purchase_order_item(
              |{ lv_po_item_value WIDTH = 5 ALIGN = RIGHT PAD = '0' }| ).

            " 입고량 역시 외주처/자재/연도/PO별로 달라 실제 같은 반복값처럼 보이지 않게 한다.
            lv_item_no += 1.
            DATA(lv_receipt_qty) = CONV zloss_itm_ms-receipt_qty(
              320 + lv_supplier_no * 18 + lv_material_seq * 25
              + lv_po_seq * 22 + lv_year_index * 20 ).
            " 완제품 총중량 = 입고수량 × 완제품 1개당 표준중량.
            DATA(lv_output_weight) =
              lv_receipt_qty * ls_finished_material-standard_weight.
            " 표준 총투입량 = 입고수량 × 완제품 1개당 표준 원자재 투입량.
            DATA(lv_standard_total) =
              lv_receipt_qty * ls_finished_material-standard_input_qty.

            " 그래프가 직선처럼 단조롭지 않도록 -0.07%, 0%, +0.07% 파동을 반복한다.
            DATA(lv_wave) = CONV decfloat34(
              ( lv_po_seq MOD 3 ) - 1 ) * CONV decfloat34( '0.000700' ).
            " 현재 PO가 연간 진행 구간의 몇 % 지점인지 0~1 사이 값으로 계산한다.
            DATA(lv_progress) =
              CONV decfloat34( lv_po_seq )
              / CONV decfloat34( lv_material_po_count ).
            DATA lv_abnormal_rate TYPE decfloat34.
            IF lv_improved = abap_true.
              " 개선 패턴: 연초에는 기준보다 높게 시작하고 연말로 갈수록 감소한다.
              lv_abnormal_rate = CONV decfloat34( lv_baseline )
                + CONV decfloat34( '0.004000' )
                - lv_progress * CONV decfloat34( '0.010000' )
                + lv_wave.
            ELSE.
              " 미개선 패턴: 연초에는 기준 아래에서 시작하지만 연말로 갈수록 증가한다.
              lv_abnormal_rate = CONV decfloat34( lv_baseline )
                - CONV decfloat34( '0.002000' )
                + lv_progress * CONV decfloat34( '0.009000' )
                + lv_wave.
            ENDIF.
            " 계산 결과가 음수가 되는 극단적인 경우 Loss율을 최소 0으로 보정한다.
            IF lv_abnormal_rate < 0.
              lv_abnormal_rate = 0.
            ENDIF.

            " ---------------------------------------------------------------
            " 수량 계산식
            " 정상 Scrap = 표준 투입량 - 완제품 중량
            " 비정상 Loss = 표준 투입량 × 생성한 비정상 Loss율
            " 실제 투입량 = 완제품 중량 + 정상 Scrap + 비정상 Loss
            " 따라서 Actual = Output + Normal + Abnormal 관계가 항상 성립한다.
            " ---------------------------------------------------------------
            DATA(lv_normal_qty) = lv_standard_total - lv_output_weight.
            DATA(lv_abnormal_qty) = lv_standard_total * lv_abnormal_rate.
            DATA(lv_actual_qty) =
              lv_output_weight + lv_normal_qty + lv_abnormal_qty.
            " PO 날짜를 1월~12월에 고르게 배치해 연간 추이가 차트에 보이게 한다.
            DATA(lv_receipt_month) =
              1 + ( lv_po_seq - 1 ) * 11 DIV ( lv_material_po_count - 1 ).
            DATA(lv_receipt_day) =
              10 + ( ( lv_supplier_no + lv_material_seq + lv_po_seq ) MOD 15 ).
            DATA(lv_receipt_date) = CONV zloss_itm_ms-receipt_date(
              |{ lv_year }{ lv_receipt_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }{ lv_receipt_day WIDTH = 2 ALIGN = RIGHT PAD = '0' }| ).

            " 계산한 모든 값을 PO Item 내부 테이블에 한 행으로 추가한다.
            APPEND VALUE #(
              client = sy-mandt
              evaluation_id = lv_evaluation_id
              item_no = |{ lv_item_no WIDTH = 6 ALIGN = RIGHT PAD = '0' }|
              purchase_order = lv_po_number
              purchase_order_item = lv_po_item
              finished_material_id = ls_assignment-finished_material_id
              receipt_date = lv_receipt_date
              receipt_qty = lv_receipt_qty
              receipt_uom = 'EA'
              standard_weight = ls_finished_material-standard_weight
              standard_input_qty = ls_finished_material-standard_input_qty
              standard_total_input_qty = lv_standard_total
              output_weight = lv_output_weight
              actual_input_qty = lv_actual_qty
              weight_uom = 'KG'
              normal_scrap_qty = lv_normal_qty
              abnormal_loss_qty = lv_abnormal_qty ) TO lt_item.
            " 다음 PO 번호가 중복되지 않도록 전역 카운터를 증가시킨다.
            lv_po_counter += 1.
          ENDDO.
        ENDLOOP.

        " 현재 평가 Header를 찾아 실제 생성된 PO 개수로 po_count를 갱신한다.
        READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<ls_header_count>)
          WITH KEY evaluation_id = lv_evaluation_id.
        IF sy-subrc = 0.
          <ls_header_count>-po_count = lv_eval_po_count.
        ENDIF.
      ENDDO.
    ENDDO.

    " -------------------------------------------------------------------------
    " 5단계: 생성된 PO Item에서 자재별 결과를 계산
    " 결과값을 임의로 입력하지 않고 Item 수량을 합산해 가중 평균을 계산한다.
    " SORTED TABLE + UNIQUE KEY를 사용해 평가별 자재 ID 중복을 자동 제거한다.
    " -------------------------------------------------------------------------
    DATA lt_finished_material_ids
      TYPE SORTED TABLE OF zloss_res_ms-finished_material_id
      WITH UNIQUE KEY table_line.

    " 평가 Header 한 건씩 자재별 계산을 수행한다.
    LOOP AT lt_header INTO DATA(ls_header).
      CLEAR lt_finished_material_ids.
      " 현재 평가에 실제 존재하는 S/M/L 자재 ID만 고유 목록에 수집한다.
      LOOP AT lt_item INTO DATA(ls_source_item)
        WHERE evaluation_id = ls_header-evaluation_id.
        INSERT ls_source_item-finished_material_id
          INTO TABLE lt_finished_material_ids.
      ENDLOOP.

      " 평가 전체의 금액과 가중 평균 판단에 사용할 누적 변수다.
      DATA lv_total_saving_amt TYPE zloss_res_ms-supplier_total_saving_amount.
      DATA lv_supplier_reward  TYPE zloss_res_ms-supplier_reward_amount.
      DATA lv_company_benefit  TYPE zloss_res_ms-company_benefit_amount.
      DATA lv_eval_standard    TYPE zloss_res_ms-total_standard_input_qty.
      DATA lv_eval_abnormal    TYPE zloss_res_ms-total_abnormal_loss_qty.
      CLEAR: lv_total_saving_amt, lv_supplier_reward, lv_company_benefit,
             lv_eval_standard, lv_eval_abnormal.

      " 현재 평가가 담당하는 자재별로 결과 한 행을 만든다.
      LOOP AT lt_finished_material_ids INTO DATA(lv_finished_material_id).
        " 자재별 총합과 계산 결과를 담을 작업 변수.
        DATA lv_total_output   TYPE zloss_res_ms-total_output_weight.
        DATA lv_total_standard TYPE zloss_res_ms-total_standard_input_qty.
        DATA lv_total_actual   TYPE zloss_res_ms-total_actual_input_qty.
        DATA lv_total_normal   TYPE zloss_res_ms-total_normal_scrap_qty.
        DATA lv_total_abnormal TYPE zloss_res_ms-total_abnormal_loss_qty.
        DATA lv_total_loss     TYPE zloss_res_ms-total_actual_loss_qty.
        DATA lv_weighted_rate  TYPE zloss_res_ms-actual_abnormal_loss_rate.
        DATA lv_saving_qty     TYPE zloss_res_ms-recognized_saving_qty.
        DATA lv_saving_amount  TYPE zloss_res_ms-recognized_saving_amount.
        CLEAR: lv_total_output, lv_total_standard, lv_total_actual,
               lv_total_normal, lv_total_abnormal, lv_total_loss,
               lv_weighted_rate, lv_saving_qty, lv_saving_amount.

        " 동일 평가 + 동일 완제품 자재에 속한 모든 PO Item 수량을 합산한다.
        LOOP AT lt_item INTO DATA(ls_material_item)
          WHERE evaluation_id = ls_header-evaluation_id
            AND finished_material_id = lv_finished_material_id.
          lv_total_output   += ls_material_item-output_weight.
          lv_total_standard += ls_material_item-standard_total_input_qty.
          lv_total_actual   += ls_material_item-actual_input_qty.
          lv_total_normal   += ls_material_item-normal_scrap_qty.
          lv_total_abnormal += ls_material_item-abnormal_loss_qty.
        ENDLOOP.

        " 실제 전체 Loss = 정상 Scrap + 비정상 Loss.
        lv_total_loss = lv_total_normal + lv_total_abnormal.
        IF lv_total_standard <> 0.
          " [핵심] 가중 평균 Loss율 = 비정상 Loss 수량 합계 / 표준 투입량 합계.
          " 각 PO의 Loss율을 단순 AVG하지 않아 대형 PO의 수량 비중이 정확히 반영된다.
          lv_weighted_rate = lv_total_abnormal / lv_total_standard.
        ENDIF.

        " 인정 절감량 = 기준상 허용 Loss 수량 - 실제 비정상 Loss 수량.
        lv_saving_qty =
          lv_total_standard * ls_header-baseline_abnormal_loss_rate
          - lv_total_abnormal.
        " 기준보다 나빠 계산값이 음수이면 절감으로 인정하지 않고 0 처리한다.
        IF lv_saving_qty < 0.
          lv_saving_qty = 0.
        ENDIF.
        " 인정 절감액 = 인정 절감량(KG) × 원자재 단가(800 KRW/KG).
        lv_saving_amount = lv_saving_qty * lc_raw_price.
        " 평가 전체 보상 판정용 누적값도 동시에 갱신한다.
        lv_total_saving_amt += lv_saving_amount.
        lv_eval_standard += lv_total_standard.
        lv_eval_abnormal += lv_total_abnormal.

        " 현재 자재의 계산 결과를 결과 내부 테이블에 추가한다.
        " 전체 외주처 금액 세 필드는 아래 평가 전체 판단 후 채운다.
        APPEND VALUE #(
          client = sy-mandt
          evaluation_id = ls_header-evaluation_id
          finished_material_id = lv_finished_material_id
          total_output_weight = lv_total_output
          total_standard_input_qty = lv_total_standard
          total_actual_input_qty = lv_total_actual
          total_normal_scrap_qty = lv_total_normal
          total_abnormal_loss_qty = lv_total_abnormal
          total_actual_loss_qty = lv_total_loss
          actual_abnormal_loss_rate = lv_weighted_rate
          baseline_abnormal_loss_rate = ls_header-baseline_abnormal_loss_rate
          recognized_saving_qty = lv_saving_qty
          weight_uom = 'KG'
          raw_material_price = lc_raw_price
          recognized_saving_amount = lv_saving_amount
          supplier_share = lc_supplier_share
          company_share = lc_company_share
          currency_code = 'KRW'
          calculated_at = lv_calculated_at ) TO lt_result.
      ENDLOOP.

      " -----------------------------------------------------------------------
      " 평가 전체 보상 판단
      " 평가 전체 가중 Loss율이 기준보다 낮은 '개선' 평가만 외주처 보상을 지급한다.
      " 미개선 평가는 인정 절감액이 일부 존재하더라도 외주처 보상액을 0으로 만든다.
      " -----------------------------------------------------------------------
      IF lv_eval_standard <> 0
        AND lv_eval_abnormal / lv_eval_standard
          < ls_header-baseline_abnormal_loss_rate.
        lv_supplier_reward = lv_total_saving_amt * lc_supplier_share.
      ELSE.
        lv_supplier_reward = 0.
      ENDIF.
      " 본사 이익액은 전체 인정 절감액의 60%로 계산한다.
      lv_company_benefit = lv_total_saving_amt * lc_company_share.

      " 앞에서 만든 자재별 결과 모든 행에 평가 전체 금액을 동일하게 기록한다.
      " 조회 CDS는 이 반복값을 MAX로 한 번만 읽어 중복 합산을 방지한다.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>)
        WHERE evaluation_id = ls_header-evaluation_id.
        <ls_result>-supplier_total_saving_amount = lv_total_saving_amt.
        <ls_result>-supplier_reward_amount = lv_supplier_reward.
        <ls_result>-company_benefit_amount = lv_company_benefit.
      ENDLOOP.
    ENDLOOP.

    " -------------------------------------------------------------------------
    " 6단계: 기존 시연 데이터 교체
    " SUP0000001~SUP0000010의 평가만 찾아 자식→부모 순서로 삭제한다.
    " 연습 패키지 안의 다른 사용자/다른 평가 데이터는 삭제하지 않는다.
    " -------------------------------------------------------------------------
    SELECT evaluation_id
      FROM zloss_hdr_ms
      WHERE supplier_id BETWEEN 'SUP0000001' AND 'SUP0000010'
      INTO TABLE @DATA(lt_old_evaluation_ids).

    " FK/Composition 관계를 고려해 Result, Item을 먼저 삭제하고 Header를 삭제한다.
    LOOP AT lt_old_evaluation_ids INTO DATA(ls_old_evaluation_id).
      DELETE FROM zloss_res_ms
        WHERE evaluation_id = @ls_old_evaluation_id-evaluation_id.
      DELETE FROM zloss_itm_ms
        WHERE evaluation_id = @ls_old_evaluation_id-evaluation_id.
      DELETE FROM zloss_hdr_ms
        WHERE evaluation_id = @ls_old_evaluation_id-evaluation_id.
    ENDLOOP.

    " 동일 키의 자재/외주처 기준정보만 교체한다.
    DELETE zloss_mat_ms FROM TABLE @lt_material.
    DELETE zloss_sup_ms FROM TABLE @lt_supplier.

    " 부모 기준정보와 Header를 먼저 넣은 뒤 Item과 Result를 저장한다.
    INSERT zloss_mat_ms FROM TABLE @lt_material.
    INSERT zloss_sup_ms FROM TABLE @lt_supplier.
    INSERT zloss_hdr_ms FROM TABLE @lt_header.
    INSERT zloss_itm_ms FROM TABLE @lt_item.
    INSERT zloss_res_ms FROM TABLE @lt_result.
    " 모든 DB 변경을 확정하고 완료될 때까지 기다린다.
    COMMIT WORK AND WAIT.

    " ADT Console에 적재 건수를 출력해 결과를 빠르게 검증한다.
    out->write( |Materials: { lines( lt_material ) }| ).
    out->write( |Suppliers: { lines( lt_supplier ) }| ).
    out->write( |Evaluation headers: { lines( lt_header ) }| ).
    out->write( |PO items: { lines( lt_item ) }| ).
    out->write( |Material results: { lines( lt_result ) }| ).
  ENDMETHOD.
ENDCLASS.


