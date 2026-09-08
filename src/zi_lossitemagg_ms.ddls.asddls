// -----------------------------------------------------------------------------
// [CDS 역할] PO Item 계산 결과를 평가 ID 단위로 집계한다.
// List/Object Page 헤더의 전체 PO 수, 전체 Loss율, 절감량에 사용된다.
// 중요: 전체 Loss율은 행별 비율의 단순 평균이 아니라 가중 평균으로 계산한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Item Aggregation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossItemAgg_MS
  as select from ZI_LossItemCalc_MS
{
  // GROUP BY 기준이 되는 평가 ID.
  key EvaluationID,

      // 평가에 속한 모든 PO Item의 실제 투입량 합계.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast( sum( get_numeric_value( ActualInputQty ) )
            as abap.dec(23,3) ) as TotalActualInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast( sum( get_numeric_value( StandardTotalInputQty ) )
            as abap.dec(23,3) ) as TotalStandardInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast( sum( get_numeric_value( AbnormalLossQty ) )
            as abap.dec(23,3) ) as TotalAbnormalLossQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      cast( sum( get_numeric_value( POSavingQty ) )
            as abap.dec(23,3) ) as TotalSavingQty,

      WeightUOM,

      // 같은 PO에 여러 Item이 존재해도 PO 번호는 한 번만 계산한다.
      cast( count( distinct PurchaseOrder )
            as abap.int4 ) as POCount,
      // 가중 평균 Loss율 = 전체 비정상 Loss 합계 / 전체 표준 투입량 합계 × 100
      // PO별 Loss율을 AVG하지 않기 때문에 투입량이 큰 PO가 적절한 비중을 가진다.
      cast(
        case
          when sum( get_numeric_value( StandardTotalInputQty ) ) = 0
            then 0
          else
            sum( get_numeric_value( AbnormalLossQty ) )
            / sum( get_numeric_value( StandardTotalInputQty ) ) * 100
        end
        as abap.dec(7,2) ) as CurrentLossRate
}
group by
  // 집계되지 않은 필드는 모두 GROUP BY에 포함해야 한다.
  EvaluationID,
  WeightUOM

