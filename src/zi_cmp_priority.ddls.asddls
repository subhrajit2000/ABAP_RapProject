@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Priority'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.representativeKey: 'PriorityId'
define view entity ZI_CMP_PRIORITY as select from zsn_priority
{
  @ObjectModel.text.element: ['PriorityDesc']
  key priority_id   as PriorityId,
      @Semantics.text: true
      priority_desc as PriorityDesc
}
