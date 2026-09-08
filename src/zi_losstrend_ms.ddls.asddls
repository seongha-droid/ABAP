// -----------------------------------------------------------------------------
// [CDS 역할] Fiori Elements Object Page의 Loss율 선형 차트 전용 View이다.
// PO Item별 실제 Loss율과 동일 평가의 기준 Loss율을 입고일 순으로 제공한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Rate Trend'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
// OData가 $apply 집계 질의를 허용하도록 선언한다. Fiori 차트 렌더링에 필요하다.
@OData.applySupportedForAggregation: #FULL

// qualifier는 화면 Facet이 이 차트 정의를 정확히 찾아가는 식별자이다.
@UI.chart: [{
  qualifier: 'LossTrend',
  description: '입고일 기준 PO Item별 Loss율',
  // LINE 차트에서 입고일은 X축 Category, 두 Loss율은 Y축 Measure가 된다.
  chartType: #LINE,
  dimensions: [ 'ReceiptDate' ],
  measures: [ 'POLossRate', 'BaselineLossRate' ],
  dimensionAttributes: [{
    dimension: 'ReceiptDate',
    role: #CATEGORY
  }],
  measureAttributes: [
    // asDataPoint=true이면 각 Measure에 연결된 DataPoint 의미를 함께 사용한다.
    { measure: 'POLossRate', role: #AXIS_1, asDataPoint: true },
    { measure: 'BaselineLossRate', role: #AXIS_1, asDataPoint: true }
  ]
}]

// 차트 데이터를 입고일 오름차순으로 정렬하고 LossTrend 차트를 기본 시각화로 지정한다.
@UI.presentationVariant: [{
  qualifier: 'LossTrend',
  sortOrder: [{ by: 'ReceiptDate', direction: #ASC }],
  visualizations: [{ type: #AS_CHART, qualifier: 'LossTrend' }]
}]

define view entity ZI_LossTrend_MS
  as select from ZI_LossEvaluationItem_MS
{
  // EvaluationID + ItemNo는 차트 원본 데이터의 고유 행 키이다.
  key EvaluationID,
  key ItemNo,
      PurchaseOrder,
      PurchaseOrderItem,
      FinishedMaterialID,
      @EndUserText.label: '입고일'
      ReceiptDate,

      // 실제 PO Loss율. AVG는 같은 차원 그룹에서 집계할 기본 방식을 지정한다.
      @EndUserText.label: 'PO별 Loss율'
      @UI.dataPoint: {
        title: 'Loss율',
        criticality: 'ActualCriticality'
      }
      @Aggregation.default: #AVG
      POLossRate,

      // 모든 날짜에 동일한 평가 기준율을 표시하여 실제선과 비교하게 한다.
      @EndUserText.label: '기준 Loss율'
      @UI.dataPoint: {
        title: '기준 Loss율',
        criticality: 'BaselineCriticality'
      }
      @Aggregation.default: #AVG
      BaselineLossRate,

      // 차트 의미색 계산용 기술 필드라 사용자가 직접 보지 않도록 숨긴다.
      // 5=Information, 0=Neutral이다. 실제 색상은 Fiori 테마가 최종 결정한다.
      @UI.hidden: true
      cast( 5 as abap.int1 ) as ActualCriticality,

      @UI.hidden: true
      cast( 0 as abap.int1 ) as BaselineCriticality
}

