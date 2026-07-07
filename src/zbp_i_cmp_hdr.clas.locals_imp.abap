CLASS lhc_Complaint DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Complaint RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Complaint RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Complaint.

    METHODS earlynumbering_cba_Comments FOR NUMBERING
      IMPORTING entities FOR CREATE Complaint\_Comments.

    METHODS CancelComplaint FOR MODIFY
      IMPORTING keys FOR ACTION Complaint~CancelComplaint RESULT result.

    METHODS CloseComplaint FOR MODIFY
      IMPORTING keys FOR ACTION Complaint~CloseComplaint RESULT result.

    METHODS SetInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Complaint~SetInitialValues.

    METHODS ValidateComplaint FOR VALIDATE ON SAVE
      IMPORTING keys FOR Complaint~ValidateComplaint.

    METHODS AssignAgent FOR MODIFY
      IMPORTING keys FOR ACTION Complaint~AssignAgent RESULT result.

    METHODS StartProcessing FOR MODIFY
      IMPORTING keys FOR ACTION Complaint~StartProcessing RESULT result.

ENDCLASS.

CLASS lhc_Complaint IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

"-------METHOD EARLYNUMBERING_CREATE STARTS HERE-------
  METHOD earlynumbering_create.

  CONSTANTS:
    gc_nr_object TYPE cl_numberrange_runtime=>nr_object VALUE 'ZSN_CMP_NR',
    gc_nr_range  TYPE cl_numberrange_runtime=>nr_interval VALUE '01',
    gc_prefix    TYPE string VALUE 'CMP',
    gc_width     TYPE i VALUE 7.

  DATA:
    lv_required_numbers TYPE i,
    lv_latest_number    TYPE cl_numberrange_runtime=>nr_number,
    lv_current_number   TYPE int8.

  "------------------------------------------------------------
  " Pass 1 : Preserve existing draft IDs and count new entities
  "------------------------------------------------------------
  LOOP AT entities INTO DATA(ls_entity).

    IF ls_entity-ComplaintId IS NOT INITIAL.

      " Existing draft -> keep previously assigned Complaint ID
      APPEND VALUE #(
        %cid        = ls_entity-%cid
        %is_draft   = ls_entity-%is_draft
        ComplaintId = ls_entity-ComplaintId
      ) TO mapped-complaint.

    ELSE.

      lv_required_numbers += 1.

    ENDIF.

  ENDLOOP.

  " Nothing requires numbering
  IF lv_required_numbers = 0.
    RETURN.
  ENDIF.

  "------------------------------------------------------------
  " Reserve all required numbers in a single Number Range call
  "------------------------------------------------------------
  TRY.

      cl_numberrange_runtime=>number_get(
        EXPORTING
          object            = gc_nr_object
          nr_range_nr       = gc_nr_range
          quantity          = CONV #( lv_required_numbers )
        IMPORTING
          number            = lv_latest_number
          returned_quantity = DATA(lv_returned_quantity)
      ).

    CATCH cx_number_ranges INTO DATA(lx_numberrange).

      LOOP AT entities INTO ls_entity
           USING KEY entity
           WHERE ComplaintId IS INITIAL.

        APPEND VALUE #(
          %cid      = ls_entity-%cid
          %is_draft = ls_entity-%is_draft
        ) TO failed-complaint.

        APPEND VALUE #(
          %cid      = ls_entity-%cid
          %is_draft = ls_entity-%is_draft
          %msg      = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = lx_numberrange->get_text( )
                      )
        ) TO reported-complaint.

      ENDLOOP.

      RETURN.

  ENDTRY.

  "------------------------------------------------------------
  " Determine the first number of the reserved block
  "------------------------------------------------------------
  lv_current_number = CONV int8( lv_latest_number ) - lv_returned_quantity.

  "------------------------------------------------------------
  " Pass 2 : Assign Complaint IDs
  "------------------------------------------------------------
  LOOP AT entities INTO ls_entity.

    IF ls_entity-ComplaintId IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    lv_current_number += 1.

    DATA(lv_complaint_id) =
      |{ gc_prefix }{ lv_current_number WIDTH = gc_width ALIGN = RIGHT PAD = '0' }|.

    APPEND VALUE #(
      %cid        = ls_entity-%cid
      %is_draft   = ls_entity-%is_draft
      ComplaintId = lv_complaint_id
    ) TO mapped-complaint.

  ENDLOOP.
ENDMETHOD.
"-------METHOD EARLYNUMBERING_CREATE ENDS HERE-------

"-------METHOD EARLYNUMBERING_CBA_COMMENTS STARTS HERE-------
  METHOD earlynumbering_cba_Comments.
    CONSTANTS:
      gc_nr_object TYPE cl_numberrange_runtime=>nr_object   VALUE 'ZSN_COM_NR', "  Comment Object
      gc_nr_range  TYPE cl_numberrange_runtime=>nr_interval VALUE '01',           "  Exact runtime type
      gc_prefix    TYPE string                              VALUE 'COM',
      gc_width     TYPE i                                   VALUE 7.

    DATA:
      lv_required_numbers TYPE i,
      lv_latest_number    TYPE cl_numberrange_runtime=>nr_number,
      lv_current_number   TYPE int8.

    "------------------------------------------------------------
    " Pass 1 : Count all new comments across all parent tickets
    "------------------------------------------------------------
    LOOP AT entities INTO DATA(ls_parent).
      LOOP AT ls_parent-%target INTO DATA(ls_comment_target).
        IF ls_comment_target-CommentId IS NOT INITIAL.
          " Map existing child draft keys back to the framework
          APPEND VALUE #(
            %cid        = ls_comment_target-%cid
            %is_draft   = ls_comment_target-%is_draft
            CommentId   = ls_comment_target-CommentId
          ) TO mapped-comment.
        ELSE.
          lv_required_numbers += 1.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " Nothing requires numbering
    IF lv_required_numbers = 0.
      RETURN.
    ENDIF.

    "------------------------------------------------------------
    " Reserve all required numbers in a single Number Range call
    "------------------------------------------------------------
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            object            = gc_nr_object
            nr_range_nr       = gc_nr_range
            quantity          = CONV #( lv_required_numbers )
          IMPORTING
            number            = lv_latest_number
            returned_quantity = DATA(lv_returned_quantity)
        ).

      CATCH cx_number_ranges INTO DATA(lx_numberrange).
        " Fail cleanly across the entire nested structure
        LOOP AT entities INTO ls_parent.
          LOOP AT ls_parent-%target INTO ls_comment_target
               USING KEY entity
               WHERE CommentId IS INITIAL.

            APPEND VALUE #(
              %cid      = ls_comment_target-%cid
              %is_draft = ls_comment_target-%is_draft
            ) TO failed-comment.

            APPEND VALUE #(
              %cid      = ls_comment_target-%cid
              %is_draft = ls_comment_target-%is_draft
              %msg      = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = lx_numberrange->get_text( )
                          )
            ) TO reported-comment.
          ENDLOOP.
        ENDLOOP.
        RETURN.
    ENDTRY.

    "------------------------------------------------------------
    " Determine the first number of the reserved block
    "------------------------------------------------------------
    lv_current_number = CONV int8( lv_latest_number ) - lv_returned_quantity.

    "------------------------------------------------------------
    " Pass 2 : Assign Global Comment IDs
    "------------------------------------------------------------
    LOOP AT entities INTO ls_parent.
      LOOP AT ls_parent-%target INTO ls_comment_target.
        IF ls_comment_target-CommentId IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        lv_current_number += 1.

        DATA(lv_comment_id) =
          |{ gc_prefix }{ lv_current_number WIDTH = gc_width ALIGN = RIGHT PAD = '0' }|.

        APPEND VALUE #(
          %cid        = ls_comment_target-%cid
          %is_draft   = ls_comment_target-%is_draft
          CommentId   = lv_comment_id
        ) TO mapped-comment.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
"-------METHOD EARLYNUMBERING_CBA_COMMENTS ENDS HERE-------

  METHOD CancelComplaint.
  ENDMETHOD.

  METHOD CloseComplaint.
  ENDMETHOD.


"-------METHOD SETINITIALVALUES STARTS HERE-------
  METHOD SetInitialValues.

  "------------------------------------------------------------------
  " Step 1 : Read the newly created complaints from RAP transaction buffer
  "------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId PriorityId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint.

  "------------------------------------------------------------------
  " Step 2 : Initialize only business fields that are still empty
  "------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    IF <ls_complaint>-StatusId IS INITIAL
    OR <ls_complaint>-PriorityId IS INITIAL.

      APPEND VALUE #(

        %tky = <ls_complaint>-%tky

        StatusId = COND #(
                      WHEN <ls_complaint>-StatusId IS INITIAL
                      THEN 'NEW'
                      ELSE <ls_complaint>-StatusId )

        PriorityId = COND #(
                        WHEN <ls_complaint>-PriorityId IS INITIAL
                        THEN 'MEDIUM'
                        ELSE <ls_complaint>-PriorityId )

      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  "------------------------------------------------------------------
  " Step 3 : Update the RAP transactional buffer in one bulk operation
  "------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( StatusId PriorityId )
        WITH lt_update
      REPORTED DATA(lt_reported).

    " Forward RAP framework messages to the UI
    reported-complaint = CORRESPONDING #( lt_reported-complaint ).

  ENDIF.

ENDMETHOD.
"-------METHOD SETINITIALVALUES ENDS HERE-------

"-------METHOD VALIDATECOMPLAINT STARTS HERE-------
  METHOD ValidateComplaint.
    " ------------------------------------------------------------------
    " Step 1: Bulk Read the text inputs out of memory buffer
    " ------------------------------------------------------------------
    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        FIELDS ( Title Description )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_complaints).

    " ------------------------------------------------------------------
    " Step 2: The Evaluation Loop (Phase 1 Local Constraints)
    " ------------------------------------------------------------------
    LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

      " Check A: Enforce Mandatory Title
      IF <ls_complaint>-Title IS INITIAL.
        " Block the database save pipeline
        APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

        " Highlight the specific field and pass the error message
        APPEND VALUE #(
          %tky           = <ls_complaint>-%tky
          %element-Title = if_abap_behv=>mk-on
          %msg           = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text     = 'A summary Title is mandatory for every complaint record.'
                           )
        ) TO reported-complaint.
      ENDIF.

      " Check B: Enforce Mandatory Description & Minimum Length
      IF <ls_complaint>-Description IS INITIAL.
        " Case 1: Field is completely blank
        APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

        APPEND VALUE #(
          %tky                 = <ls_complaint>-%tky
          %element-Description = if_abap_behv=>mk-on
          %msg                 = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Detailed Description cannot be left empty.'
                                 )
        ) TO reported-complaint.

      ELSEIF numofchar( <ls_complaint>-Description ) < 10.
        " Case 2: Field has data, but it fails the 10-character minimum threshold
        APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

        APPEND VALUE #(
          %tky                 = <ls_complaint>-%tky
          %element-Description = if_abap_behv=>mk-on
          %msg                 = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Description is too short. Please provide at least 10 characters of context.'
                                 )
        ) TO reported-complaint.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
"-------METHOD VALIDATECOMPLAINT ENDS HERE-------

  METHOD AssignAgent.
  ENDMETHOD.

  METHOD StartProcessing.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Comment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS SetCommentDetails FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Comment~SetCommentDetails.

    METHODS ValidateComment FOR VALIDATE ON SAVE
      IMPORTING keys FOR Comment~ValidateComment.

ENDCLASS.

CLASS lhc_Comment IMPLEMENTATION.

  METHOD SetCommentDetails.
  ENDMETHOD.

  METHOD ValidateComment.
  ENDMETHOD.

ENDCLASS.
