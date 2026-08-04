@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.representativeKey: 'StatusId'
define view entity ZI_CMP_STATUS as select from zsn_status
{
  @ObjectModel.text.element: ['StatusDesc']
  key status_id   as StatusId,
      @Semantics.text: true
      status_desc as StatusDesc
}
