
// -----------------------------------------------------------------------------
// [CDS 역할] 전체 RAP Business Object의 Root Interface View이다.
// 평가 헤더 한 행에 외주처, 전체 집계, 자재별 Item/Trend/Result를 연결한다.
// List Page의 한 행과 Object Page의 한 객체가 이 View의 한 행에 대응한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

// 평가 Entity를 Business Object의 Root로 지정하는 코드 (define root)
define root view entity ZI_LossEvaluation_MS
  as select from zloss_hdr_ms as Header

  // 외주처 ID를 기준으로 이름과 배분율을 탐색하는 N:1 Association.
  association of many to one ZI_LossSupplier_MS
    as _Supplier
    on $projection.SupplierID = _Supplier.SupplierID

  // 평가 Header에 저장된 공통 원자재 ID의 기준정보를 탐색한다.
  association of many to one ZI_LossMaterial_MS
    as _RawMaterial
    on $projection.RawMaterialID = _RawMaterial.MaterialID

  // 평가별 PO/수량 집계는 존재하지 않을 수도 있으므로 [0..1]이다.
  association [0..1] to ZI_LossItemAgg_MS
    as _ItemAggregation
    on $projection.EvaluationID = _ItemAggregation.EvaluationID

  // 평가별 금액 집계를 연결한다.
  association [0..1] to ZI_LossResultAgg_MS
    as _ResultAggregation
    on $projection.EvaluationID = _ResultAggregation.EvaluationID

  // Composition은 Header가 부모이고 Item/Result가 생명주기를 공유하는 자식임을 뜻한다.
  // Evaluation 하나는 Item을 0개 이상 포함할 수 있다.
  composition [0..*] of ZI_LossEvaluationItem_MS
    as _Items
  // Evaluation 하나는 Result를 0개 이상 포함할 수 있다.
  composition [0..*] of ZI_LossEvaluationResult_MS
    as _Results

  // 아래 세 Association은 완제품 ID 조건으로 S/M/L PO Item을 미리 분리한다.
  // Fiori Preview에서 자재별 고정 탭에 서로 다른 데이터를 공급하기 위한 구조이다.
  association [0..*] to ZI_LossEvaluationItem_MS
    as _SmallItems
    on  $projection.EvaluationID = _SmallItems.EvaluationID
    and _SmallItems.FinishedMaterialID = 'FG-STL-S'

  association [0..*] to ZI_LossEvaluationItem_MS
    as _MediumItems
    on  $projection.EvaluationID = _MediumItems.EvaluationID
    and _MediumItems.FinishedMaterialID = 'FG-STL-M'

  association [0..*] to ZI_LossEvaluationItem_MS
    as _LargeItems
    on  $projection.EvaluationID = _LargeItems.EvaluationID
    and _LargeItems.FinishedMaterialID = 'FG-STL-L'

  // 차트도 같은 방식으로 S/M/L 전용 탐색 경로를 각각 제공한다.
  association [0..*] to ZI_LossTrend_MS
    as _SmallTrend
    on  $projection.EvaluationID = _SmallTrend.EvaluationID
    and _SmallTrend.FinishedMaterialID = 'FG-STL-S'

  association [0..*] to ZI_LossTrend_MS
    as _MediumTrend
    on  $projection.EvaluationID = _MediumTrend.EvaluationID
    and _MediumTrend.FinishedMaterialID = 'FG-STL-M'

  association [0..*] to ZI_LossTrend_MS
    as _LargeTrend
    on  $projection.EvaluationID = _LargeTrend.EvaluationID
    and _LargeTrend.FinishedMaterialID = 'FG-STL-L'

  // 자재별 계산 결과는 평가+자재 조합당 최대 한 행이므로 [0..1]이다.
  association [0..1] to ZI_LossEvaluationResult_MS
    as _SmallResult
    on  $projection.EvaluationID = _SmallResult.EvaluationID
    and _SmallResult.FinishedMaterialID = 'FG-STL-S'

  association [0..1] to ZI_LossEvaluationResult_MS
    as _MediumResult
    on  $projection.EvaluationID = _MediumResult.EvaluationID
    and _MediumResult.FinishedMaterialID = 'FG-STL-M'

  association [0..1] to ZI_LossEvaluationResult_MS
    as _LargeResult
    on  $projection.EvaluationID = _LargeResult.EvaluationID
    and _LargeResult.FinishedMaterialID = 'FG-STL-L'
{
      // 통합 검색창에서 평가 ID를 검색 가능하게 한다.
      @Search.defaultSearchElement: true
  key Header.evaluation_id                as EvaluationID,

      // 외주처명은 Association을 통해 읽기 때문에 Header에 중복 저장하지 않는다.
      Header.supplier_id                  as SupplierID,
      _Supplier.SupplierName              as SupplierName,
      Header.plant                        as Plant,
      Header.raw_material_id              as RawMaterialID,

      // 기준율은 내부 계산용 소수와 화면용 백분율 두 형태로 제공한다.
      Header.baseline_abnormal_loss_rate  as BaselineAbnormalLossRate,
      cast( Header.baseline_abnormal_loss_rate * 100
            as abap.dec(7,2) )            as BaselineLossRate,

      // StoredPOCount는 적재 당시 값, POCount는 실제 Item을 DISTINCT 집계한 현재 값이다.
      Header.evaluation_year              as EvaluationYear,
      Header.po_count                     as StoredPOCount,
      _ItemAggregation.POCount            as POCount,

      // 원본 코드(C/P)와 화면 표시용 한글 텍스트를 함께 제공한다.
      Header.evaluation_status            as StoredEvaluationStatus,
      Header.evaluation_status            as EvaluationStatus,
      cast(
        case Header.evaluation_status
          when 'C' then '정산 완료'
          else '정산 미완료'
        end
        as abap.char(10) )                 as EvaluationStatusText,

      // Item 전체를 이용한 가중 평균 Loss율이다.
      _ItemAggregation.CurrentLossRate    as CurrentLossRate,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      _ItemAggregation.TotalSavingQty     as TotalSavingQty,
      _ItemAggregation.WeightUOM          as WeightUOM,

      // Result 집계에서 평가 전체 금액을 읽어 Object Page Header에 표시한다.
      @Semantics.amount.currencyCode: 'CurrencyCode'
      _ResultAggregation.RecognizedSavingAmount
                                             as RecognizedSavingAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      _ResultAggregation.SupplierRewardAmount
                                             as SupplierRewardAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      _ResultAggregation.CompanyBenefitAmount
                                             as CompanyBenefitAmount,

      _ResultAggregation.CurrencyCode     as CurrencyCode,

      // 실제 Loss율이 기준보다 낮으면 '개선', 그렇지 않으면 '미개선'.
      cast(
        case
          when _ItemAggregation.CurrentLossRate
               < Header.baseline_abnormal_loss_rate * 100
            then '개선'
          else '미개선'
        end
        as abap.char(6) )                  as PerformanceStatus,

      // Fiori 상태 색상용 값: 3=초록(Positive), 1=빨강(Negative).
      cast(
        case
          when _ItemAggregation.CurrentLossRate
               < Header.baseline_abnormal_loss_rate * 100
            then 3
          else 1
        end
        as abap.int1 )                     as PerformanceCriticality,

      // Loss 수치 자체에도 동일한 판단 기준을 적용한다.
      cast(
        case
          when _ItemAggregation.CurrentLossRate
               < Header.baseline_abnormal_loss_rate * 100
            then 3
          else 1
        end
        as abap.int1 )                     as LossCriticality,

      // 보상액은 Information 의미색 코드 5를 사용한다.
      cast( 5 as abap.int1 )               as RewardCriticality,

      // RAP 관리 필드 Annotation은 생성/변경 시각과 사용자를 자동 관리한다.
      @Semantics.user.createdBy: true
      Header.created_by                   as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      Header.created_at                   as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      Header.last_changed_by              as LastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Header.local_last_changed_at        as LocalLastChangedAt,

      // 마지막에 Association을 노출해야 상위 Projection과 OData에서 탐색할 수 있다.
      _Supplier,
      _RawMaterial,
      _ItemAggregation,
      _ResultAggregation,
      _Items,
      _Results,
      _SmallItems,
      _MediumItems,
      _LargeItems,
      _SmallTrend,
      _MediumTrend,
      _LargeTrend,
      _SmallResult,
      _MediumResult,
      _LargeResult
}

