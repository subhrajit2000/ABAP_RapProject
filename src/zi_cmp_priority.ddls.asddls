@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Priority'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_CMP_PRIORITY as select from zsn_priority
{
    key priority_id   as PriorityId,
      priority_desc as PriorityDesc
    
}
