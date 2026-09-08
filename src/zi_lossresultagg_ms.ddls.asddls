// -----------------------------------------------------------------------------
// [CDS 역할] 자재별 결과 테이블을 평가 헤더 수준의 금액으로 축약한다.
// 결과 행마다 외주처 전체 금액이 반복 저장되므로 MAX를 사용해 한 번만 읽는다.
// SUM을 사용하면 자재 개수만큼 동일 금액이 중복 합산되므로 주의해야 한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Result Aggregation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_LossResultAgg_MS
  as select from zloss_res_MS as Result
{
  key Result.evaluation_id as EvaluationID,

      // 해당 평가에서 인정된 전체 절감액.
      @Semantics.amount.currencyCode: 'CurrencyCode'
      max( Result.supplier_total_saving_amount )
        as RecognizedSavingAmount,

      // 외주처에 귀속되는 40% 보상액.
      @Semantics.amount.currencyCode: 'CurrencyCode'
      max( Result.supplier_reward_amount )
        as SupplierRewardAmount,

      // 본사에 귀속되는 60% 이익액.
      @Semantics.amount.currencyCode: 'CurrencyCode'
      max( Result.company_benefit_amount )
        as CompanyBenefitAmount,

      Result.currency_code as CurrencyCode
}
group by
  Result.evaluation_id,
  Result.currency_code

