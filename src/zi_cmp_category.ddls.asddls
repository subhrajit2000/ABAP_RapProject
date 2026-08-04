@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Category'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.representativeKey: 'CategoryId'
define view entity ZI_CMP_CATEGORY as select from zsn_category
{
  @ObjectModel.text.element: ['CategoryDesc']
  key category_id   as CategoryId,
      @Semantics.text: true
      category_desc as CategoryDesc
}
