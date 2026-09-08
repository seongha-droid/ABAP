// -----------------------------------------------------------------------------
// [CDS 역할] Fiori Elements가 직접 소비하는 최상위 Root Projection View이다.
// 필드의 한글 라벨, 필수 필터, Value Help와 자식 Navigation을 최종 정의한다.
// -----------------------------------------------------------------------------
@EndUserText.label: '외주처 Loss 평가'
@AccessControl.authorizationCheck: #NOT_REQUIRED
// Metadata Extension 파일에서 List/Object Page UI Annotation을 분리 관리한다.
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_LossEvaluation_MS
  // transactional_query 계약은 RAP Query Provider로 사용할 Projection임을 명시한다.
  provider contract transactional_query
  as projection on ZI_LossEvaluation_MS
{
      @EndUserText.label: '평가 ID'
  key EvaluationID,
      @EndUserText.label: '외주처 ID'
      SupplierID,
      @EndUserText.label: '외주처명'
      SupplierName,
      @EndUserText.label: '플랜트'
      Plant,
      @EndUserText.label: '원자재 ID'
      RawMaterialID,
      @EndUserText.label: '기준 비정상 Loss율'
      BaselineAbnormalLossRate,
      @EndUserText.label: '기준 Loss율'
      BaselineLossRate,
      @EndUserText.label: '평가년도'
      // 평가년도는 반드시 한 값만 선택해야 조회되도록 필터를 강제한다.
      @Consumption.filter: { mandatory: true, selectionType: #SINGLE, multipleSelections: false }
      // 실제 존재하는 연도만 반환하는 전용 Value Help View와 연결한다.
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_LossEvaluationYear_MS', element: 'EvaluationYear' },
        useForValidation: true
      }]
      EvaluationYear,
      @EndUserText.label: 'PO 개수'
      POCount,
      @EndUserText.label: '정산 상태'
      // 코드 C/P 대신 EvaluationStatusText의 한글 설명만 화면에 보여준다.
      @ObjectModel.text.element: ['EvaluationStatusText']
      @UI.textArrangement: #TEXT_ONLY
      EvaluationStatus,
      @EndUserText.label: '정산 상태명'
      EvaluationStatusText,
      @EndUserText.label: 'Loss율'
      CurrentLossRate,
      @EndUserText.label: '인정 절감량'
      TotalSavingQty,
      @EndUserText.label: '중량 단위'
      WeightUOM,
      @EndUserText.label: '인정 절감액'
      RecognizedSavingAmount,
      @EndUserText.label: '외주처 보상액'
      SupplierRewardAmount,
      @EndUserText.label: '본사 이익액'
      CompanyBenefitAmount,
      @EndUserText.label: '통화'
      CurrencyCode,
      @EndUserText.label: '개선 상태'
      PerformanceStatus,
      // 기술적인 Criticality 필드는 화면 Annotation의 의미색 계산에 사용한다.
      PerformanceCriticality,
      LossCriticality,
      RewardCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,

      // Composition 자식은 Consumption 자식 Projection으로 redirect한다.
      _Supplier,
      _RawMaterial,
      _Items   : redirected to composition child ZC_LossEvaluationItem_MS,
      _Results : redirected to composition child ZC_LossEvaluationResult_MS,
      // S/M/L 고정 Facet에서 사용할 Item, 차트, 결과 전용 탐색 경로이다.
      _SmallItems  : redirected to ZC_LossEvaluationItem_MS,
      _MediumItems : redirected to ZC_LossEvaluationItem_MS,
      _LargeItems  : redirected to ZC_LossEvaluationItem_MS,
      _SmallTrend,
      _MediumTrend,
      _LargeTrend,
      _SmallResult  : redirected to ZC_LossEvaluationResult_MS,
      _MediumResult : redirected to ZC_LossEvaluationResult_MS,
      _LargeResult  : redirected to ZC_LossEvaluationResult_MS
}

