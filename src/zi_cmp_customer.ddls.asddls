@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Customer'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'CustomerId'
define view entity ZI_CMP_CUSTOMER as select from zsn_customer
{
  @ObjectModel.text.element: ['CustomerName']
  key customer_id   as CustomerId,
      @Semantics.text: true
      customer_name as CustomerName,
      email         as Email,
      phone         as Phone,
      city          as City,
      country       as Country,
      created_by    as CreatedBy,
      created_at    as CreatedAt
}
