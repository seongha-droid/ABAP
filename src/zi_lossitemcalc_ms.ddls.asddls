// -----------------------------------------------------------------------------
// [CDS 역할] PO Item 한 건 단위의 계산 View이다.
// 저장된 실적값을 그대로 읽는 데서 끝나지 않고 다음 파생값을 계산한다.
// 1) 기준 Loss율(%), 2) 실제 PO Loss율(%), 3) 절감량, 4) 의미색 상태값
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Item Calculation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossItemCalc_MS
  // Item의 평가 ID로 Header를 INNER JOIN하여 평가별 기준 Loss율을 가져온다.
  // 부모 헤더가 없는 고아 Item은 업무상 유효하지 않으므로 결과에서 제외된다.
  as select from zloss_itm_MS as Item
    inner join zloss_hdr_MS as Header
      on Item.evaluation_id = Header.evaluation_id
{
  // EvaluationID + ItemNo 조합이 PO 실적 한 행을 고유하게 식별한다.
  key Item.evaluation_id   as EvaluationID,
  key Item.item_no         as ItemNo,

      Item.purchase_order       as PurchaseOrder,
      Item.purchase_order_item  as PurchaseOrderItem,
      Item.finished_material_id as FinishedMaterialID,
      Item.receipt_date         as ReceiptDate,

      @Semantics.quantity.unitOfMeasure: 'ReceiptUOM'
      Item.receipt_qty          as ReceiptQty,
      Item.receipt_uom          as ReceiptUOM,

      // 실제 투입량, 표준 투입량, Loss 수량은 모두 WeightUOM(KG)을 사용한다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.actual_input_qty     as ActualInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.standard_total_input_qty as StandardTotalInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.normal_scrap_qty     as NormalScrapQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.abnormal_loss_qty    as AbnormalLossQty,

      Item.weight_uom           as WeightUOM,
      // DB에는 0.015 형태로 저장된 기준율을 화면 표시용 1.50%로 변환한다.
      cast( Header.baseline_abnormal_loss_rate * 100
            as abap.dec(7,2) ) as BaselineLossRate,
      // PO Loss율 = 비정상 Loss 수량 / 표준 총투입량 × 100
      // 분모가 0이면 나눗셈 오류를 방지하기 위해 결과를 0으로 반환한다.
      cast(
        case
          when get_numeric_value( Item.standard_total_input_qty ) = 0
            then 0
          else
            get_numeric_value( Item.abnormal_loss_qty )
            / get_numeric_value( Item.standard_total_input_qty ) * 100
        end
        as abap.dec(7,2) ) as POLossRate,

      // PO 절감량 = 기준상 허용 Loss 수량 - 실제 비정상 Loss 수량
      // 상위 집계 View에서 평가별/자재별 합계를 계산할 때 사용한다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast(
        get_numeric_value( Item.standard_total_input_qty )
        * Header.baseline_abnormal_loss_rate
        - get_numeric_value( Item.abnormal_loss_qty )
        as abap.dec(15,3) ) as POSavingQty,

      // Fiori Criticality 코드: 3=Positive(초록), 1=Negative(빨강).
      // 표준 투입량이 없거나 실제 Loss율이 기준보다 낮으면 개선으로 판단한다.
      cast(
        case
          when get_numeric_value( Item.standard_total_input_qty ) = 0
            then 3
          when get_numeric_value( Item.abnormal_loss_qty )
               / get_numeric_value( Item.standard_total_input_qty )
               < Header.baseline_abnormal_loss_rate
            then 3
          else 1
        end
        as abap.int1 ) as LossCriticality
}

