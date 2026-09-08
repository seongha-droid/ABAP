// -----------------------------------------------------------------------------
// [CDS 역할] 자재별 결과를 서비스에 노출하는 Consumption Projection View.
// 자재 탭의 상세정보·보상 산출 근거에 필요한 필드를 모두 공개한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Result Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_LossEvaluationResult_MS
  as projection on ZI_LossEvaluationResult_MS
{
  // 평가 ID + 완제품 자재 ID가 서비스 엔티티의 복합키이다.
  key EvaluationID,
  key FinishedMaterialID,
      FinishedMaterialName,
      RawMaterialID,
      RawMaterialName,
      MaterialPOCount,
      MaterialSavingQty,
      TotalOutputWeight,
      TotalStandardInputQty,
      TotalActualInputQty,
      TotalNormalScrapQty,
      TotalAbnormalLossQty,
      TotalActualLossQty,
      ActualAbnormalLossRate,
      BaselineAbnormalLossRate,
      ActualLossRate,
      BaselineLossRate,
      LossCriticality,
      RecognizedSavingQty,
      WeightUOM,
      RawMaterialPrice,
      RecognizedSavingAmount,
      SupplierTotalSavingAmount,
      SupplierShare,
      SupplierSharePercent,
      CompanyShare,
      CompanySharePercent,
      SupplierRewardAmount,
      CompanyBenefitAmount,
      CurrencyCode,
      RewardCriticality,
      CalculatedAt,

      // 부모 평가로 돌아가는 탐색 경로를 Consumption 계층으로 redirect한다.
      _Evaluation      : redirected to parent ZC_LossEvaluation_MS,
      _FinishedMaterial
}

