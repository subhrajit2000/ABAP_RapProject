@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Complaint Comments'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CMP_COMMENT
  as select from zsn_cmp_comment
  
  association to parent ZI_CMP_HDR as _Complaint on $projection.ComplaintId = _Complaint.ComplaintId
{
  key comment_id      as CommentId,
      complaint_id    as ComplaintId,
      comment_text    as CommentText,
      comment_by_type as CommentByType,
      comment_by_id   as CommentById, 
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      
      // Exposed Association back to parent
      _Complaint
}
