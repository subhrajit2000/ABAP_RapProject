@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Complaint Header'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_CMP_HDR
  provider contract transactional_query
  as projection on ZI_CMP_HDR
{
  @EndUserText.label: 'Complaint ID'
  key ComplaintId,

      @EndUserText.label: 'Customer'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CMP_CUSTOMER', element: 'CustomerId' } }]
      CustomerId,
      
      @EndUserText.label: 'Priority'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CMP_PRIORITY', element: 'PriorityId' } }]
      PriorityId,
      
      @EndUserText.label: 'Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CMP_STATUS', element: 'StatusId' } }]
      StatusId,
      
      @EndUserText.label: 'Category'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CMP_CATEGORY', element: 'CategoryId' } }]
      CategoryId,
      
      @EndUserText.label: 'Assigned Agent'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CMP_AGENT', element: 'AgentId' } }]
      AgentId,
      
      @EndUserText.label: 'Title'  
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Title,
      
      @EndUserText.label: 'Description'
      @Search.defaultSearchElement: true
      Description,
      
      @EndUserText.label: 'Closed By'
      ClosedBy,
      
      @EndUserText.label: 'Closed On'
      ClosedOn,
        
      @EndUserText.label: 'Created By'  
      CreatedBy,
      
      @EndUserText.label: 'Created At'
      CreatedAt,
      
      @EndUserText.label: 'Last Changed At'
      LastChangedAt,

      /* Master Data Associations */
      _Customer,
      _Agent,
      _ClosedByAgent,
      _Status,
      _Priority,
      _Category,
      
      /* Composition Redirection */
      _Comments : redirected to composition child ZC_CMP_COMMENT
}
