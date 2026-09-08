// -----------------------------------------------------------------------------
// [CDS 역할] 평가년도 필터의 Value Help 전용 View이다.
// 헤더 테이블에 실제 존재하는 연도만 DISTINCT로 반환하므로 2025/2026만 선택된다.
// -----------------------------------------------------------------------------
@EndUserText.label: '평가년도 값 도움말'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
// 이 View가 일반 업무 조회가 아닌 값 도움말 용도임을 프레임워크에 알린다.
@ObjectModel.dataCategory: #VALUE_HELP
// 결과 건수가 매우 적은 고정/소규모 목록임을 표시하여 로딩을 최적화한다.
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_LossEvaluationYear_MS
  as select distinct from zloss_hdr_MS
{
      @EndUserText.label: '평가년도'
  key evaluation_year as EvaluationYear
}
// 초기값 또는 잘못된 값인 0000은 선택 목록에서 제외한다.
where evaluation_year <> '0000'

