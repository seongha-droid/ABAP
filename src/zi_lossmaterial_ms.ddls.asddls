// -----------------------------------------------------------------------------
// [CDS 역할] S/M/L 완제품 기준정보를 제공하는 Interface View이다.
// 기술적인 DB 필드명을 Fiori와 상위 CDS에서 사용할 CamelCase 이름으로 변환한다.
// -----------------------------------------------------------------------------
@EndUserText.label: 'Loss Evaluation Material'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity ZI_LossMaterial_MS
  as select from zloss_mat_MS as Material
{
      // MaterialID의 설명 필드로 MaterialName을 연결한다.
      @ObjectModel.text.element: [ 'MaterialName' ]
      @Search.defaultSearchElement: true
  key Material.material_id        as MaterialID,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      Material.material_name      as MaterialName,

      // S/M/L 구분값. 외주처별 자재 탭 및 필터 조건에 사용된다.
      Material.material_type      as MaterialType,
      // 완제품 수량 단위(EA 등).
      Material.base_uom           as BaseUOM,

      // 수량 필드와 단위 필드를 연결하면 Fiori가 '값 + 단위'로 표시한다.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Material.standard_weight    as StandardWeight,

      // 완제품 1개를 만들 때 필요한 기준 원자재 투입량.
      @Semantics.quantity.unitOfMeasure: 'WeightUOM'
      Material.standard_input_qty as StandardInputQty,

      // StandardWeight와 StandardInputQty의 공통 단위(KG).
      Material.weight_uom         as WeightUOM,
      Material.active_flag        as ActiveFlag
}

