@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Complaint Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_CMP_HDR
  as select from zsn_cmp_hdr
  
  composition [0..*] of ZI_CMP_COMMENT as _Comments
  
  association [1..1] to ZI_CMP_CUSTOMER as _Customer      on $projection.CustomerId = _Customer.CustomerId
  association [0..1] to ZI_CMP_AGENT    as _Agent         on $projection.AgentId    = _Agent.AgentId
  association [0..1] to ZI_CMP_AGENT    as _ClosedByAgent on $projection.ClosedBy   = _ClosedByAgent.AgentId
  association [1..1] to ZI_CMP_STATUS   as _Status        on $projection.StatusId   = _Status.StatusId
  association [1..1] to ZI_CMP_PRIORITY as _Priority      on $projection.PriorityId = _Priority.PriorityId
  association [1..1] to ZI_CMP_CATEGORY as _Category      on $projection.CategoryId = _Category.CategoryId
{
  key complaint_id as ComplaintId,
      customer_id  as CustomerId,
      priority_id  as PriorityId,
      status_id    as StatusId,
      category_id  as CategoryId,
      agent_id     as AgentId,
      title        as Title,
      description  as Description,
      closed_by    as ClosedBy,
      closed_on    as ClosedOn,
      created_by   as CreatedBy,
      created_at   as CreatedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      // Exposed Associations
      _Customer,
      _Agent,
      _ClosedByAgent,
      _Status,
      _Priority,
      _Category,
      _Comments
}
