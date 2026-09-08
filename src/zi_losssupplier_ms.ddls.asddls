// -----------------------------------------------------------------------------
// [CDS 역할] 외주처 기준 테이블을 업무에서 읽기 쉬운 필드명으로 노출하는
// Interface View이다. 이후 평가 CDS에서 Association 대상으로 사용된다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Supplier'
// 교육/시연용이므로 별도 DCL 권한검사를 적용하지 않는다.
@AccessControl.authorizationCheck: #NOT_REQUIRED
// 원본 테이블의 Annotation이 의도치 않게 전달되지 않도록 차단한다.
@Metadata.ignorePropagatedAnnotations: true
// List Page의 통합 검색창에서 이 엔티티를 검색할 수 있게 한다.
@Search.searchable: true

define view entity ZI_LossSupplier_MS
  as select from zloss_sup_MS as Supplier
{
      // ID를 표시할 때 SupplierName을 설명 텍스트로 함께 사용할 수 있게 연결한다.
      @ObjectModel.text.element: [ 'SupplierName' ]
      // 별도 필드 선택 없이 기본 검색 대상에 SupplierID를 포함한다.
      @Search.defaultSearchElement: true
  key Supplier.supplier_id    as SupplierID,

      // 이 필드가 코드의 설명(Text) 역할임을 Fiori에 알린다.
      @Semantics.text: true
      @Search.defaultSearchElement: true
      Supplier.supplier_name  as SupplierName,

      // 보상 계산에 사용할 외주처 40%, 본사 60% 배분율이다.
      Supplier.supplier_share as SupplierShare,
      Supplier.company_share  as CompanyShare,
      // 비활성 외주처를 향후 조회 대상에서 제외할 때 사용할 수 있다.
      Supplier.active_flag    as ActiveFlag
}

