// -----------------------------------------------------------------------------
// [CDS 역할] 자재별 계산 결과에 자재명·원자재명·자재별 PO 집계를 결합한다.
// Object Page 각 S/M/L 탭의 상세정보와 보상 산출 근거의 데이터 원천이다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Result'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossEvaluationResult_MS
  // Header는 기준율/원자재 ID에 필수이므로 INNER JOIN한다.
  as select from zloss_res_MS as Result
    inner join zloss_hdr_MS as Header
      on Result.evaluation_id = Header.evaluation_id
    // 원자재명이 없어도 계산 결과는 보여야 하므로 LEFT OUTER JOIN한다.
    left outer join zloss_mat_MS as RawMaterial
      on Header.raw_material_id = RawMaterial.material_id

  // 결과 행은 평가 Header의 Composition 자식이다.
  association to parent ZI_LossEvaluation_MS
    as _Evaluation
    on $projection.EvaluationID = _Evaluation.EvaluationID

  association of many to one ZI_LossMaterial_MS
    as _FinishedMaterial
    on $projection.FinishedMaterialID = _FinishedMaterial.MaterialID


  // 자재별 PO 수와 절감량을 가져오는 선택적 Association이다.
  // 데이터가 아직 집계되지 않은 경우를 허용하므로 Cardinality는 [0..1]이다.
  association [0..1] to ZI_LossItemMatAgg_MS
    as _ItemAggregation
    on  $projection.EvaluationID      = _ItemAggregation.EvaluationID
    and $projection.FinishedMaterialID = _ItemAggregation.FinishedMaterialID
{
  // 평가 ID + 완제품 자재 ID가 자재별 결과 한 행을 식별한다.
  key Result.evaluation_id               as EvaluationID,
  key Result.finished_material_id        as FinishedMaterialID,

      // 상세정보 영역에 표시할 완제품명, 공통 원자재 ID/명, 자재별 PO 수.
      _FinishedMaterial.MaterialName      as FinishedMaterialName,
      Header.raw_material_id              as RawMaterialID,
      RawMaterial.material_name            as RawMaterialName,
      _ItemAggregation.POCount            as MaterialPOCount,

      // 결과 테이블에 저장된 자재별 합계 수량이다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      _ItemAggregation.SavingQty          as MaterialSavingQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_output_weight          as TotalOutputWeight,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_standard_input_qty     as TotalStandardInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_actual_input_qty       as TotalActualInputQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_normal_scrap_qty       as TotalNormalScrapQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_abnormal_loss_qty      as TotalAbnormalLossQty,

      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.total_actual_loss_qty        as TotalActualLossQty,

      Result.actual_abnormal_loss_rate    as ActualAbnormalLossRate,
      Result.baseline_abnormal_loss_rate  as BaselineAbnormalLossRate,

      // 내부 소수 비율을 화면 표시용 백분율로 변환한다. 0.013 → 1.30
      cast( Result.actual_abnormal_loss_rate * 100
            as abap.dec(7,2) )            as ActualLossRate,

      cast( Result.baseline_abnormal_loss_rate * 100
            as abap.dec(7,2) )            as BaselineLossRate,

      // 실제 Loss율이 기준 Loss율보다 작을 때 3(Positive), 아니면 1(Negative).
      cast(
        case
          when Result.actual_abnormal_loss_rate
               < Result.baseline_abnormal_loss_rate
            then 3
          else 1
        end
        as abap.int1 )                    as LossCriticality,

      // 인정 절감량과 원자재 단가를 이용해 보상 관련 금액이 계산되어 저장된다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Result.recognized_saving_qty        as RecognizedSavingQty,

      Result.weight_uom                   as WeightUOM,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Result.raw_material_price           as RawMaterialPrice,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Result.recognized_saving_amount     as RecognizedSavingAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Result.supplier_total_saving_amount as SupplierTotalSavingAmount,

      Result.supplier_share               as SupplierShare,
      // 0.4000을 화면 표시용 40.00%로 변환한다.
      cast( Result.supplier_share * 100
            as abap.dec(5,2) )            as SupplierSharePercent,

      Result.company_share                as CompanyShare,
      // 0.6000을 화면 표시용 60.00%로 변환한다.
      cast( Result.company_share * 100
            as abap.dec(5,2) )            as CompanySharePercent,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Result.supplier_reward_amount       as SupplierRewardAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Result.company_benefit_amount       as CompanyBenefitAmount,

      Result.currency_code                as CurrencyCode,
      // 5는 Information 의미색이며 보상액을 정보성 강조로 표시한다.
      cast( 5 as abap.int1 )               as RewardCriticality,
      Result.calculated_at                as CalculatedAt,

      // 탐색 및 Composition 처리를 위해 Association을 결과에 노출한다.
      _Evaluation,
      _FinishedMaterial,
      _ItemAggregation
}

