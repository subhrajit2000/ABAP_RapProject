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

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Complaint RESULT result.

    METHODS resolvecomplaint FOR MODIFY
      IMPORTING keys FOR ACTION complaint~resolvecomplaint RESULT result.

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

"-------METHOD CANCELCOMPLAINT STARTS HERE-------
METHOD CancelComplaint.

  " ------------------------------------------------------------------
  " Step 1 : Read current complaint state from RAP transactional buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint.

  " ------------------------------------------------------------------
  " Step 2 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    "--------------------------------------------------------------
    " Rule 1 : Assigned complaints cannot be cancelled
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'ASSIGNED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Assigned complaints cannot be cancelled.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 2 : Complaints already in progress cannot be cancelled
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'INPROGRESS'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Complaints already in progress cannot be cancelled.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 3 : Resolved complaints cannot be cancelled
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'RESOLVED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Resolved complaints cannot be cancelled.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 4 : Closed complaints cannot be cancelled
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CLOSED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Closed complaints cannot be cancelled.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 5 : Already cancelled (Backend Idempotency)
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CANCELLED'.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 6 : NEW -> CANCELLED
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'NEW'.

      APPEND VALUE #(
        %tky     = <ls_complaint>-%tky
        StatusId = 'CANCELLED'
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Step 3 : Update RAP Transaction Buffer
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( StatusId )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    reported-complaint = CORRESPONDING #(
      BASE ( reported-complaint )
      lt_reported-complaint ).

    failed-complaint = CORRESPONDING #(
      BASE ( failed-complaint )
      lt_failed-complaint ).

  ENDIF.

  " ------------------------------------------------------------------
  " Step 4 : Refresh only modified entities ($self)
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        ALL FIELDS
        WITH CORRESPONDING #( lt_update )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDIF.

ENDMETHOD.
"-------METHOD CANCELCOMPLAINT ENDS HERE-------


"-------METHOD CLOSECOMPLAINT STARTS HERE-------
METHOD CloseComplaint.

  " ------------------------------------------------------------------
  " Step 1 : Read current complaint state from RAP transactional buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId AgentId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  DATA:
    lt_update    TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint,
    lv_timestamp TYPE timestampl.

  " Current UTC timestamp - universally accepted in BTP environments
  GET TIME STAMP FIELD lv_timestamp.

  " ------------------------------------------------------------------
  " Step 2 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    "--------------------------------------------------------------
    " Rule 1 : NEW complaints cannot be closed
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'NEW'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Assign an agent and start processing before closing the complaint.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 2 : ASSIGNED complaints cannot be closed
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'ASSIGNED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Start processing the complaint before closing it.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 3 : Complaint must first be resolved
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'INPROGRESS'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Resolve the complaint before closing it.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 4 : CANCELLED complaints cannot be closed
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CANCELLED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky )
        TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Cancelled complaints cannot be closed.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 5 : Already closed (Backend Idempotency)
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CLOSED'.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 6 : RESOLVED -> CLOSED
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'RESOLVED'.

      APPEND VALUE #(
        %tky      = <ls_complaint>-%tky
        StatusId  = 'CLOSED'
        ClosedBy  = <ls_complaint>-AgentId
        ClosedOn  = lv_timestamp
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Step 3 : Update RAP Transaction Buffer
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( StatusId ClosedBy ClosedOn )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    reported-complaint = CORRESPONDING #(
      BASE ( reported-complaint )
      lt_reported-complaint ).

    failed-complaint = CORRESPONDING #(
      BASE ( failed-complaint )
      lt_failed-complaint ).

  ENDIF.

  " ------------------------------------------------------------------
  " Step 4 : Refresh only modified entities ($self)
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        ALL FIELDS
        WITH CORRESPONDING #( lt_update )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDIF.

ENDMETHOD.
"-------METHOD CLOSECOMPLAINT ENDS HERE-------


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
  " Phase 1 : Read complaint data from RAP Transaction Buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( CustomerId CategoryId Title Description )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  " ------------------------------------------------------------------
  " Phase 2 : Collect unique Customer IDs and Category IDs
  " ------------------------------------------------------------------
  DATA:
    lt_customer_ids TYPE SORTED TABLE OF zsn_customer-customer_id
                       WITH UNIQUE KEY table_line,
    lt_category_ids TYPE SORTED TABLE OF zsn_category-category_id
                       WITH UNIQUE KEY table_line.

  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    IF <ls_complaint>-CustomerId IS NOT INITIAL.
      INSERT <ls_complaint>-CustomerId INTO TABLE lt_customer_ids.
    ENDIF.

    IF <ls_complaint>-CategoryId IS NOT INITIAL.
      INSERT <ls_complaint>-CategoryId INTO TABLE lt_category_ids.
    ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Phase 3 : Bulk Read Customer Master
  " ------------------------------------------------------------------
  DATA lt_customers TYPE SORTED TABLE OF zsn_customer
                       WITH UNIQUE KEY customer_id.

  IF lt_customer_ids IS NOT INITIAL.

    SELECT FROM zsn_customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer_ids
      WHERE customer_id = @lt_customer_ids-table_line
      INTO TABLE @lt_customers.

  ENDIF.

  " ------------------------------------------------------------------
  " Phase 4 : Bulk Read Category Master
  " ------------------------------------------------------------------
  DATA lt_categories TYPE SORTED TABLE OF zsn_category
                        WITH UNIQUE KEY category_id.

  IF lt_category_ids IS NOT INITIAL.

    SELECT FROM zsn_category
      FIELDS category_id
      FOR ALL ENTRIES IN @lt_category_ids
      WHERE category_id = @lt_category_ids-table_line
      INTO TABLE @lt_categories.

  ENDIF.

  " ------------------------------------------------------------------
  " Phase 5 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING <ls_complaint>.

    "--------------------------------------------------------------
    " Check A : Title is Mandatory
    "--------------------------------------------------------------
    IF <ls_complaint>-Title IS INITIAL.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky           = <ls_complaint>-%tky
        %element-Title = if_abap_behv=>mk-on
        %msg           = new_message_with_text(
                           severity = if_abap_behv_message=>severity-error
                           text     = 'A summary Title is mandatory for every complaint record.'
                         )
      ) TO reported-complaint.

    ENDIF.

    "--------------------------------------------------------------
    " Check B : Description is Mandatory
    "--------------------------------------------------------------
    IF <ls_complaint>-Description IS INITIAL.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky                 = <ls_complaint>-%tky
        %element-Description = if_abap_behv=>mk-on
        %msg                 = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Detailed Description cannot be left empty.'
                               )
      ) TO reported-complaint.

    ELSEIF numofchar( <ls_complaint>-Description ) < 10.

      "------------------------------------------------------------
      " Check C : Description Minimum Length
      "------------------------------------------------------------
      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky                 = <ls_complaint>-%tky
        %element-Description = if_abap_behv=>mk-on
        %msg                 = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Description must contain at least 10 meaningful characters.'
                               )
      ) TO reported-complaint.

    ENDIF.

    "--------------------------------------------------------------
    " Check D : Customer Must Exist
    "--------------------------------------------------------------
    READ TABLE lt_customers
      WITH TABLE KEY customer_id = <ls_complaint>-CustomerId
      TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky                = <ls_complaint>-%tky
        %element-CustomerId = if_abap_behv=>mk-on
        %msg                = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Selected Customer does not exist.'
                              )
      ) TO reported-complaint.

    ENDIF.

    "--------------------------------------------------------------
    " Check E : Category Must Exist
    "--------------------------------------------------------------
    READ TABLE lt_categories
      WITH TABLE KEY category_id = <ls_complaint>-CategoryId
      TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky                = <ls_complaint>-%tky
        %element-CategoryId = if_abap_behv=>mk-on
        %msg                = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Selected Category does not exist.'
                              )
      ) TO reported-complaint.

    ENDIF.

  ENDLOOP.

ENDMETHOD.
"-------METHOD VALIDATECOMPLAINT ENDS HERE-------

"-------METHOD ASSIGNAGENT STARTS HERE-------
METHOD AssignAgent.

  " ------------------------------------------------------------------
  " Phase 1 : Read Complaint data from RAP Transaction Buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( AgentId StatusId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  " ------------------------------------------------------------------
  " Phase 2 : Collect unique Agent IDs from Action Parameters
  " ------------------------------------------------------------------
  DATA:
    lt_agent_ids TYPE SORTED TABLE OF zsn_agent-agent_id
                   WITH UNIQUE KEY table_line.

  LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

    IF <ls_key>-%param-AgentId IS NOT INITIAL.
      INSERT <ls_key>-%param-AgentId
        INTO TABLE lt_agent_ids.
    ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Phase 3 : Bulk Read Agent Master
  " ------------------------------------------------------------------
  DATA lt_agents TYPE SORTED TABLE OF zsn_agent
                   WITH UNIQUE KEY agent_id.

  IF lt_agent_ids IS NOT INITIAL.

    SELECT FROM zsn_agent
      FIELDS agent_id
      FOR ALL ENTRIES IN @lt_agent_ids
      WHERE agent_id = @lt_agent_ids-table_line
      INTO TABLE @lt_agents.

  ENDIF.

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint.

  " ------------------------------------------------------------------
  " Phase 4 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    READ TABLE keys ASSIGNING <ls_key>
      WITH KEY id COMPONENTS %tky = <ls_complaint>-%tky.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 1 : Agent ID must be provided
    "--------------------------------------------------------------
    IF <ls_key>-%param-AgentId IS INITIAL.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'A valid Agent ID must be provided.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 2 : Agent must exist
    "--------------------------------------------------------------
    READ TABLE lt_agents
      WITH TABLE KEY agent_id = <ls_key>-%param-AgentId
      TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Selected Agent does not exist.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 3 : Only NEW complaints can be assigned
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId <> 'NEW'.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
      ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Only NEW complaints can be assigned.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 4 : Assign Agent
    "--------------------------------------------------------------
    APPEND VALUE #(
      %tky     = <ls_complaint>-%tky
      AgentId  = <ls_key>-%param-AgentId
      StatusId = 'ASSIGNED'
    ) TO lt_update.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Phase 5 : Update RAP Transaction Buffer
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( AgentId StatusId )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    reported-complaint = CORRESPONDING #(
      BASE ( reported-complaint )
      lt_reported-complaint ).

    failed-complaint = CORRESPONDING #(
      BASE ( failed-complaint )
      lt_failed-complaint ).

  ENDIF.

  " ------------------------------------------------------------------
  " Phase 6 : Refresh updated instances
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        ALL FIELDS
        WITH CORRESPONDING #( lt_update )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDIF.

ENDMETHOD.
"-------METHOD ASSIGNAGENT ENDS HERE-------

"-------METHOD STARTPROCESSING STARTS HERE-------
  METHOD StartProcessing.

  " ------------------------------------------------------------------
  " Step 1 : Read current complaint state from RAP transactional buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId AgentId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint.

  " ------------------------------------------------------------------
  " Step 2 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    "--------------------------------------------------------------
    " Rule 1 : Complaint must first be assigned
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'NEW'.
      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Assign an agent before starting processing.'
               )
      ) TO reported-complaint.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 2 : Closed complaints cannot be processed
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CLOSED'.
      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Closed complaints cannot be processed.'
               )
      ) TO reported-complaint.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 3 : Cancelled complaints cannot be processed
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CANCELLED'.
      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Cancelled complaints cannot be processed.'
               )
      ) TO reported-complaint.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 4 : Already in progress (Backend Idempotency)
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'INPROGRESS'.
      CONTINUE.
    ENDIF.

   "--------------------------------------------------------------
   " Rule 5 : Allowed State Transition
   " ASSIGNED  -> INPROGRESS
   " RESOLVED  -> INPROGRESS (Resume Processing)
   "--------------------------------------------------------------
   IF <ls_complaint>-StatusId = 'ASSIGNED'
   OR <ls_complaint>-StatusId = 'RESOLVED'.

   APPEND VALUE #(
     %tky     = <ls_complaint>-%tky
     StatusId = 'INPROGRESS'
   ) TO lt_update.

   ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Step 3 : Update RAP Transaction Buffer
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( StatusId )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    reported-complaint = CORRESPONDING #( BASE ( reported-complaint )
                                           lt_reported-complaint ).

    failed-complaint   = CORRESPONDING #( BASE ( failed-complaint )
                                           lt_failed-complaint ).
  ENDIF.

  " ------------------------------------------------------------------
  " Step 4 : Refresh ONLY modified entities ($self)
  " ------------------------------------------------------------------
  " Optimization: Only refreshes rows that actually changed state
  IF lt_update IS NOT INITIAL.
    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        ALL FIELDS
        WITH CORRESPONDING #( lt_update )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).
  ENDIF.

ENDMETHOD.
"-------METHOD STARTPROCESSING ENDS HERE-------

"-------METHOD GET INSTANCE FEATURE STARTS HERE-------
METHOD get_instance_features.

  " ------------------------------------------------------------------
  " Step 1 : Read current complaint status from RAP transactional buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  " ------------------------------------------------------------------
  " Step 2 : Enable/Disable UI actions based on Complaint State Machine
  " ------------------------------------------------------------------
  result = VALUE #(

    FOR ls_cmp IN lt_complaints (

      %tky = ls_cmp-%tky

      "--------------------------------------------------------------
      " Rule A : Assign Agent
      " Allowed only for NEW complaints
      "--------------------------------------------------------------
      %action-AssignAgent =
        COND #(
          WHEN ls_cmp-StatusId = 'NEW'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      "--------------------------------------------------------------
      " Rule B : Start Processing
      " ASSIGNED  -> INPROGRESS
      " RESOLVED  -> INPROGRESS (Resume Processing)
      "--------------------------------------------------------------
      %action-StartProcessing =
        COND #(
          WHEN ls_cmp-StatusId = 'ASSIGNED'
            OR ls_cmp-StatusId = 'RESOLVED'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      "--------------------------------------------------------------
      " Rule C : Resolve Complaint
      " Allowed only for complaints currently INPROGRESS
      "--------------------------------------------------------------
      %action-ResolveComplaint =
        COND #(
          WHEN ls_cmp-StatusId = 'INPROGRESS'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      "--------------------------------------------------------------
      " Rule D : Close Complaint
      " Allowed only after complaint is RESOLVED
      "--------------------------------------------------------------
      %action-CloseComplaint =
        COND #(
          WHEN ls_cmp-StatusId = 'RESOLVED'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      "--------------------------------------------------------------
      " Rule E : Cancel Complaint
      " Allowed only for NEW complaints
      "--------------------------------------------------------------
      %action-CancelComplaint =
        COND #(
          WHEN ls_cmp-StatusId = 'NEW'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

    )

  ).

ENDMETHOD.
"-------METHOD GET INSTANCE FEATURE ENDS HERE-------

"-------METHOD RESOLVECOMPLAINT STARTS HERE-------
  METHOD ResolveComplaint.

  " ------------------------------------------------------------------
  " Step 1 : Read current complaint state from RAP transactional buffer
  " ------------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_complaints).

  IF lt_complaints IS INITIAL.
    RETURN.
  ENDIF.

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Complaint.

  " ------------------------------------------------------------------
  " Step 2 : Business Validation Loop
  " ------------------------------------------------------------------
  LOOP AT lt_complaints ASSIGNING FIELD-SYMBOL(<ls_complaint>).

    "--------------------------------------------------------------
    " Rule 1 : Complaint must be in progress
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'NEW'
    OR <ls_complaint>-StatusId = 'ASSIGNED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Complaint must be in progress before it can be resolved.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 2 : Closed complaints cannot be resolved
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CLOSED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Closed complaints cannot be resolved.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 3 : Cancelled complaints cannot be resolved
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'CANCELLED'.

      APPEND VALUE #( %tky = <ls_complaint>-%tky ) TO failed-complaint.

      APPEND VALUE #(
        %tky = <ls_complaint>-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Cancelled complaints cannot be resolved.'
               )
      ) TO reported-complaint.

      CONTINUE.

    ENDIF.

    "--------------------------------------------------------------
    " Rule 4 : Already resolved (Backend Idempotency)
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'RESOLVED'.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------------------
    " Rule 5 : INPROGRESS -> RESOLVED
    "--------------------------------------------------------------
    IF <ls_complaint>-StatusId = 'INPROGRESS'.

      APPEND VALUE #(
        %tky     = <ls_complaint>-%tky
        StatusId = 'RESOLVED'
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  " ------------------------------------------------------------------
  " Step 3 : Update RAP Transaction Buffer
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        UPDATE FIELDS ( StatusId )
        WITH lt_update
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    reported-complaint = CORRESPONDING #(
      BASE ( reported-complaint )
      lt_reported-complaint ).

    failed-complaint = CORRESPONDING #(
      BASE ( failed-complaint )
      lt_failed-complaint ).

  ENDIF.

  " ------------------------------------------------------------------
  " Step 4 : Refresh ONLY modified entities ($self)
  " ------------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Complaint
        ALL FIELDS
        WITH CORRESPONDING #( lt_update )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      (
        %tky   = ls_result-%tky
        %param = ls_result
      )
    ).

  ENDIF.

ENDMETHOD.
"-------METHOD RESOLVECOMPLAINT ENDS HERE-------

ENDCLASS.


CLASS lhc_Comment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS SetCommentDetails FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Comment~SetCommentDetails.

    METHODS ValidateComment FOR VALIDATE ON SAVE
      IMPORTING keys FOR Comment~ValidateComment.

ENDCLASS.

CLASS lhc_Comment IMPLEMENTATION.

"-------METHOD SETCOMMENTDETAILS STARTS HERE-------
  METHOD SetCommentDetails.

  "------------------------------------------------------------
  " 1. Bulk Read Newly Created Comments
  "------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Comment
      FIELDS ( ComplaintId CommentById CommentByType )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_comments).

  IF lt_comments IS INITIAL.
    RETURN.
  ENDIF.

  "------------------------------------------------------------
  " 2. Bulk Read Parent Complaints
  "------------------------------------------------------------
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( CustomerId AgentId )
      WITH VALUE #(
        FOR ls_comment IN lt_comments
        ( ComplaintId = ls_comment-ComplaintId )
      )
    RESULT DATA(lt_parent_complaints).

  DATA lt_update TYPE TABLE FOR UPDATE zi_cmp_hdr\\Comment.

  DATA(lv_current_user) =
      cl_abap_context_info=>get_user_technical_name( ).

  "------------------------------------------------------------
  " 3. Determine Comment Details
  "------------------------------------------------------------
  LOOP AT lt_comments ASSIGNING FIELD-SYMBOL(<ls_comment>).

    READ TABLE lt_parent_complaints
      ASSIGNING FIELD-SYMBOL(<ls_parent>)
      WITH KEY entity COMPONENTS
        ComplaintId = <ls_comment>-ComplaintId.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    "----------------------------------------------------------
    " Determine Effective CommentById
    "----------------------------------------------------------
    DATA(lv_effective_user) = COND #(
      WHEN <ls_comment>-CommentById IS NOT INITIAL
        THEN <ls_comment>-CommentById
      ELSE
        lv_current_user
    ).

    "----------------------------------------------------------
    " Determine CommentByType
    "
    " Priority:
    " 1. Exact Customer Match
    " 2. Exact Agent Match
    " 3. Customer ID Prefix
    " 4. Agent ID Prefix
    " 5. Default = AGENT
    "----------------------------------------------------------
    DATA(lv_effective_type) = COND #(

      WHEN lv_effective_user = <ls_parent>-CustomerId
        THEN 'CUSTOMER'

      WHEN lv_effective_user = <ls_parent>-AgentId
        THEN 'AGENT'

      WHEN lv_effective_user CP 'CUST*'
        THEN 'CUSTOMER'

      WHEN lv_effective_user CP 'AGT*'
        THEN 'AGENT'

      ELSE 'AGENT'

    ).

    APPEND VALUE #(
      %tky          = <ls_comment>-%tky
      CommentById   = lv_effective_user
      CommentByType = lv_effective_type
    ) TO lt_update.

  ENDLOOP.

  "------------------------------------------------------------
  " 4. Bulk Update RAP Transaction Buffer
  "------------------------------------------------------------
  IF lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_cmp_hdr IN LOCAL MODE
      ENTITY Comment
        UPDATE FIELDS ( CommentById CommentByType )
        WITH lt_update
      REPORTED DATA(lt_reported).

    reported-comment =
      CORRESPONDING #( lt_reported-comment ).

  ENDIF.

ENDMETHOD.
"-------METHOD SETCOMMENTDETAILS ENDS HERE-------

"-------METHOD VALIDATECOMMENT STARTS HERE-------
  METHOD ValidateComment.
  " 1. Bulk read all comments from RAP transactional buffer
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Comment
      FIELDS ( ComplaintId CommentText )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_comments).

  IF lt_comments IS INITIAL.
    RETURN.
  ENDIF.

  " 2. Bulk read all parent complaints in one single framework operation
  READ ENTITIES OF zi_cmp_hdr IN LOCAL MODE
    ENTITY Complaint
      FIELDS ( StatusId )
      WITH VALUE #( FOR ls_comment IN lt_comments ( ComplaintId = ls_comment-ComplaintId ) )
    RESULT DATA(lt_parent_complaints).

  " 3. Validate each comment
  LOOP AT lt_comments ASSIGNING FIELD-SYMBOL(<ls_comment>).

    " FIX 1: Clears compiler warning by utilizing the secondary 'entity' index
    READ TABLE lt_parent_complaints ASSIGNING FIELD-SYMBOL(<ls_parent>)
      WITH KEY entity COMPONENTS ComplaintId = <ls_comment>-ComplaintId.

    " FIX 2: Check sy-subrc immediately to prevent runtime layout errors
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    " Clean duplicate/trailing whitespace to prevent spacebar bypass tricks
    DATA(lv_clean_text) = condense( <ls_comment>-CommentText ).

    " --------------------------------------------------------------
    " Rule 1 : Comment cannot be empty
    " --------------------------------------------------------------
    IF lv_clean_text IS INITIAL.
      APPEND VALUE #( %tky = <ls_comment>-%tky ) TO failed-comment.

      APPEND VALUE #(
        %tky                 = <ls_comment>-%tky
        %element-CommentText = if_abap_behv=>mk-on
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Comment text cannot be empty. Please provide context.'
               )
      ) TO reported-comment.
      CONTINUE.
    ENDIF.

    " --------------------------------------------------------------
    " Rule 2 : Minimum 5 meaningful characters
    " --------------------------------------------------------------
    IF strlen( lv_clean_text ) < 5.
      APPEND VALUE #( %tky = <ls_comment>-%tky ) TO failed-comment.

      APPEND VALUE #(
        %tky                 = <ls_comment>-%tky
        %element-CommentText = if_abap_behv=>mk-on
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Comment must contain at least 5 meaningful characters.'
               )
      ) TO reported-comment.
      CONTINUE.
    ENDIF.

    " --------------------------------------------------------------
    " Rule 3 : Terminated complaints cannot receive new comments
    " --------------------------------------------------------------
    " FIX 3: Expanded to block both CLOSED and CANCELLED states safely
    IF <ls_parent>-StatusId = 'CLOSED' OR <ls_parent>-StatusId = 'CANCELLED'.
      APPEND VALUE #( %tky = <ls_comment>-%tky ) TO failed-comment.

      APPEND VALUE #(
        %tky                 = <ls_comment>-%tky
        %element-CommentText = if_abap_behv=>mk-on
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Comments cannot be added to a finalized or cancelled complaint.'
               )
      ) TO reported-comment.
    ENDIF.

  ENDLOOP.
ENDMETHOD.
"-------METHOD VALIDATECOMMENT ENDS HERE-------

ENDCLASS.
