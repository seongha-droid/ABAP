// -----------------------------------------------------------------------------
// [CDS 역할] PO Item 영속 테이블과 계산 View를 결합한 RAP 자식 Interface View.
// 저장값과 계산값을 한 엔티티로 제공해 Object Page 표와 차트에서 함께 사용한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossEvaluationItem_MS
  as select from zloss_itm_MS as Item

  // 'to parent'는 이 Item이 반드시 하나의 평가 Header에 속함을 나타낸다.
  association to parent ZI_LossEvaluation_MS
    as _Evaluation
    on $projection.EvaluationID = _Evaluation.EvaluationID

  // 여러 Item이 하나의 완제품 기준정보를 참조하는 N:1 관계이다.
  association of many to one ZI_LossMaterial_MS
    as _FinishedMaterial
    on $projection.FinishedMaterialID = _FinishedMaterial.MaterialID

  // 동일 평가 ID + Item 번호의 계산 결과는 최대 한 건이므로 1:1 관계이다.
  association of one to one ZI_LossItemCalc_MS
    as _Calculation
    on  $projection.EvaluationID = _Calculation.EvaluationID
    and $projection.ItemNo       = _Calculation.ItemNo
{
  // 부모 평가 ID와 Item 순번이 복합키이다.
  key Item.evaluation_id             as EvaluationID,
  key Item.item_no                   as ItemNo,

      // 구매오더 기본정보. ReceiptDate는 차트 X축으로도 사용한다.
      Item.purchase_order            as PurchaseOrder,
      Item.purchase_order_item       as PurchaseOrderItem,
      Item.finished_material_id      as FinishedMaterialID,
      Item.receipt_date              as ReceiptDate,

      // 영속 테이블에서 직접 읽는 생산/소진 실적값이다.
      @Semantics.quantity.unitOfMeasure: 'ReceiptUOM'
      Item.receipt_qty               as ReceiptQty,

      Item.receipt_uom               as ReceiptUOM,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.standard_weight           as StandardWeight,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.standard_input_qty        as StandardInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.standard_total_input_qty  as StandardTotalInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.output_weight             as OutputWeight,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.actual_input_qty          as ActualInputQty,

      Item.weight_uom                as WeightUOM,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.normal_scrap_qty          as NormalScrapQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Item.abnormal_loss_qty         as AbnormalLossQty,

      // 아래 값은 직접 저장하지 않고 ZI_LossItemCalc_MS에서 계산해 가져온다.
      _Calculation.BaselineLossRate  as BaselineLossRate,
      _Calculation.POLossRate        as POLossRate,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      _Calculation.POSavingQty       as POSavingQty,

      _Calculation.LossCriticality   as LossCriticality,

      // Association 자체도 노출해야 상위 View와 OData가 탐색 경로로 사용할 수 있다.
      _Evaluation,
      _FinishedMaterial,
      _Calculation
}

