@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Agent'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'AgentId'
define view entity ZI_CMP_AGENT as select from zsn_agent
{
  @ObjectModel.text.element: ['AgentName']
  key agent_id   as AgentId,
      @Semantics.text: true
      agent_name as AgentName,
      email      as Email,
      department as Department
}
