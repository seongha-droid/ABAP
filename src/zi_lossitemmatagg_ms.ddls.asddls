// -----------------------------------------------------------------------------
// [CDS 역할] 평가 전체가 아니라 평가 + 완제품 자재 단위로 PO 실적을 집계한다.
// Object Page 자재 탭의 'PO 개수'와 '절감량'을 서로 독립적으로 보여주기 위함이다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Item Material Aggregation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossItemMatAgg_MS
  as select from ZI_LossItemCalc_MS
{
  key EvaluationID,
  // 동일 평가 안에서도 S/M/L 자재별로 한 행씩 생성한다.
  key FinishedMaterialID,

      // 자재별 실제 PO 개수. 하나의 PO가 중복 Item을 가져도 한 번만 센다.
      cast( count( distinct PurchaseOrder )
            as abap.int4 ) as POCount,

      // 자재에 속한 모든 PO Item의 인정 후보 절감량을 합산한다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast( sum( get_numeric_value( POSavingQty ) )
            as abap.dec(23,3) ) as SavingQty,

      WeightUOM
}
group by
  EvaluationID,
  FinishedMaterialID,
  WeightUOM

