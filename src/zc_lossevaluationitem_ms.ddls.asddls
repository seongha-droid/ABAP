// -----------------------------------------------------------------------------
// [CDS 역할] PO Item Interface View를 OData 서비스에 노출하는 Projection View.
// ZI는 내부 모델, ZC는 소비(Consumption) 계층이라고 이해하면 된다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Item Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
// 화면 Annotation을 별도 Metadata Extension에서 추가할 수 있도록 허용한다.
@Metadata.allowExtensions: true
define view entity ZC_LossEvaluationItem_MS
  as projection on ZI_LossEvaluationItem_MS
{
  // 저장 필드와 계산 필드를 필요한 순서대로 서비스에 공개한다.
  key EvaluationID,
  key ItemNo,
      PurchaseOrder,
      PurchaseOrderItem,
      FinishedMaterialID,
      ReceiptDate,
      ReceiptQty,
      ReceiptUOM,
      StandardWeight,
      StandardInputQty,
      StandardTotalInputQty,
      OutputWeight,
      ActualInputQty,
      WeightUOM,
      NormalScrapQty,
      AbnormalLossQty,

      BaselineLossRate,
      POLossRate,

      POSavingQty,
      LossCriticality,

      // 부모 Association은 Consumption Root를 향하도록 redirect해야 한다.
      _Evaluation      : redirected to parent ZC_LossEvaluation_MS,
      _FinishedMaterial
}

