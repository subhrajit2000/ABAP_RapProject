@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Agent'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CMP_AGENT as select from zsn_agent
{
    key agent_id   as AgentId,
      agent_name as AgentName,
      email      as Email,
      department as Department
}
