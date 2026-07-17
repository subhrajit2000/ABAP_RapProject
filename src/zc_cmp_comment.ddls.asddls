@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Complaint Comments'
@Metadata.allowExtensions: true

define view entity ZC_CMP_COMMENT
  as projection on ZI_CMP_COMMENT
{
  key CommentId,

      ComplaintId,
      CommentText,
      CommentByType,
      CommentById,

      CreatedBy,
      CreatedAt,

      /* Redirect parent composition */
      _Complaint : redirected to parent ZC_CMP_HDR
}
