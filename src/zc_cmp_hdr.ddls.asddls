@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Complaint Header'
@Metadata.allowExtensions: true
@Search.searchable: true // Enables global text filtering on the Fiori layout

define root view entity ZC_CMP_HDR
  provider contract transactional_query
  as projection on ZI_CMP_HDR
{
  key ComplaintId,

      CustomerId,
      PriorityId,
      StatusId,
      CategoryId,
      AgentId,

      @Search.defaultSearchElement: true // ◄ Add this: System will search this field
      @Search.fuzzinessThreshold: 0.8    // ◄ Optional: Catches typos (80% match spelling)
      Title,
      
      @Search.defaultSearchElement: true // ◄ Add this: System will also search the description
      Description,

      ClosedBy,
      ClosedOn,

      CreatedBy,
      CreatedAt,
      LastChangedAt,

      /* Master Data Associations (Passed through safely) */
      _Customer,
      _Agent,
      _ClosedByAgent,
      _Status,
      _Priority,
      _Category,
      
      /* Target Association Redirection (Required for RAP Composition Tree) */
      _Comments : redirected to composition child ZC_CMP_COMMENT
}
