CLASS zcl_cmp_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.

    "-------------------------------------------------------------
    " Database Maintenance
    "-------------------------------------------------------------
    METHODS clear_database .

    "-------------------------------------------------------------
    " Master Data Loaders
    "-------------------------------------------------------------
    METHODS load_status
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    METHODS load_priority
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    METHODS load_category
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    METHODS load_customer
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    METHODS load_agent
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    "-------------------------------------------------------------
    " Transaction Data Loaders
    "-------------------------------------------------------------
    METHODS load_complaint
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

    METHODS load_comment
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out .

ENDCLASS.



CLASS zcl_cmp_data_generator IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    clear_database( ).

    load_status( out ).
    load_priority( out ).
    load_category( out ).
    load_customer( out ).
    load_agent( out ).

    load_complaint( out ).
    load_comment( out ).

    out->write( 'Complaint Management Sample Data Generated Successfully.' ).

  ENDMETHOD.


  METHOD clear_database.

    "------------------------------------------------------------
    " Delete Transaction Data
    "------------------------------------------------------------
    DELETE FROM zsn_cmp_comment.
    DELETE FROM zsn_cmp_hdr.

    "------------------------------------------------------------
    " Delete Master Data
    "------------------------------------------------------------
    DELETE FROM zsn_agent.
    DELETE FROM zsn_customer.
    DELETE FROM zsn_category.
    DELETE FROM zsn_priority.
    DELETE FROM zsn_status.

  ENDMETHOD.


  METHOD load_status.

    DATA lt_status TYPE STANDARD TABLE OF zsn_status.
    DATA ls_status TYPE zsn_status.

    ls_status-status_id   = 'NEW'.
    ls_status-status_desc = 'New Complaint'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-status_id   = 'ASSIGNED'.
    ls_status-status_desc = 'Assigned to Agent'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-status_id   = 'INPROGRESS'.
    ls_status-status_desc = 'Work in Progress'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-status_id   = 'RESOLVED'.
    ls_status-status_desc = 'Complaint Resolved'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-status_id   = 'CLOSED'.
    ls_status-status_desc = 'Complaint Closed'.
    APPEND ls_status TO lt_status.

    CLEAR ls_status.
    ls_status-status_id   = 'CANCELLED'.
    ls_status-status_desc = 'Complaint Cancelled'.
    APPEND ls_status TO lt_status.

    INSERT zsn_status FROM TABLE @lt_status.

    out->write(
      |Status Master Data Loaded Successfully. ({ lines( lt_status ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_priority.

    DATA lt_priority TYPE STANDARD TABLE OF zsn_priority.
    DATA ls_priority TYPE zsn_priority.

    ls_priority-priority_id   = 'LOW'.
    ls_priority-priority_desc = 'Low Priority'.
    APPEND ls_priority TO lt_priority.

    CLEAR ls_priority.
    ls_priority-priority_id   = 'MEDIUM'.
    ls_priority-priority_desc = 'Medium Priority'.
    APPEND ls_priority TO lt_priority.

    CLEAR ls_priority.
    ls_priority-priority_id   = 'HIGH'.
    ls_priority-priority_desc = 'High Priority'.
    APPEND ls_priority TO lt_priority.

    CLEAR ls_priority.
    ls_priority-priority_id   = 'CRITICAL'.
    ls_priority-priority_desc = 'Critical Priority'.
    APPEND ls_priority TO lt_priority.

    INSERT zsn_priority FROM TABLE @lt_priority.

    out->write(
      |Priority Master Data Loaded Successfully. ({ lines( lt_priority ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_category.

    DATA lt_category TYPE STANDARD TABLE OF zsn_category.
    DATA ls_category TYPE zsn_category.

    ls_category-category_id   = 'CAT001'.
    ls_category-category_desc = 'Internet Connectivity'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT002'.
    ls_category-category_desc = 'Slow Internet Speed'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT003'.
    ls_category-category_desc = 'Billing & Payment'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT004'.
    ls_category-category_desc = 'Router Configuration'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT005'.
    ls_category-category_desc = 'Fiber Installation'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT006'.
    ls_category-category_desc = 'Service Outage'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT007'.
    ls_category-category_desc = 'Account Login'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT008'.
    ls_category-category_desc = 'Password Reset'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT009'.
    ls_category-category_desc = 'Email Configuration'.
    APPEND ls_category TO lt_category.

    CLEAR ls_category.
    ls_category-category_id   = 'CAT010'.
    ls_category-category_desc = 'Other Technical Issue'.
    APPEND ls_category TO lt_category.

    INSERT zsn_category FROM TABLE @lt_category.

    out->write(
      |Category Master Data Loaded Successfully. ({ lines( lt_category ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_customer.

    DATA lt_customer  TYPE STANDARD TABLE OF zsn_customer.
    DATA lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    lt_customer = VALUE #(

      ( customer_id   = 'CUST001'
        customer_name = 'Rahul Sharma'
        email         = 'rahul.sharma@email.com'
        phone         = '9876543210'
        city          = 'Mumbai'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST002'
        customer_name = 'Priya Verma'
        email         = 'priya.verma@email.com'
        phone         = '9876543211'
        city          = 'Bengaluru'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST003'
        customer_name = 'Amit Das'
        email         = 'amit.das@email.com'
        phone         = '9876543212'
        city          = 'Kolkata'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST004'
        customer_name = 'Sneha Iyer'
        email         = 'sneha.iyer@email.com'
        phone         = '9876543213'
        city          = 'Chennai'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST005'
        customer_name = 'Arjun Mehta'
        email         = 'arjun.mehta@email.com'
        phone         = '9876543214'
        city          = 'Ahmedabad'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST006'
        customer_name = 'Neha Kapoor'
        email         = 'neha.kapoor@email.com'
        phone         = '9876543215'
        city          = 'Delhi'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST007'
        customer_name = 'Vikram Singh'
        email         = 'vikram.singh@email.com'
        phone         = '9876543216'
        city          = 'Jaipur'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST008'
        customer_name = 'Ananya Sen'
        email         = 'ananya.sen@email.com'
        phone         = '9876543217'
        city          = 'Kolkata'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST009'
        customer_name = 'Rohit Patil'
        email         = 'rohit.patil@email.com'
        phone         = '9876543218'
        city          = 'Pune'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST010'
        customer_name = 'Pooja Nair'
        email         = 'pooja.nair@email.com'
        phone         = '9876543219'
        city          = 'Kochi'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST011'
        customer_name = 'Karan Malhotra'
        email         = 'karan.malhotra@email.com'
        phone         = '9876543220'
        city          = 'Chandigarh'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST012'
        customer_name = 'Meera Joshi'
        email         = 'meera.joshi@email.com'
        phone         = '9876543221'
        city          = 'Hyderabad'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST013'
        customer_name = 'Sandeep Rao'
        email         = 'sandeep.rao@email.com'
        phone         = '9876543222'
        city          = 'Visakhapatnam'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST014'
        customer_name = 'Divya Reddy'
        email         = 'divya.reddy@email.com'
        phone         = '9876543223'
        city          = 'Hyderabad'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

      ( customer_id   = 'CUST015'
        customer_name = 'Abhishek Mishra'
        email         = 'abhishek.mishra@email.com'
        phone         = '9876543224'
        city          = 'Lucknow'
        country       = 'India'
        created_by    = cl_abap_context_info=>get_user_technical_name( )
        created_at    = lv_timestamp )

    ).

    INSERT zsn_customer FROM TABLE @lt_customer.

    out->write(
      |Customer Master Data Loaded Successfully. ({ lines( lt_customer ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_agent.

    DATA lt_agent TYPE STANDARD TABLE OF zsn_agent.

    lt_agent = VALUE #(

      ( agent_id    = 'AGT001'
        agent_name  = 'Rajesh Kumar'
        email       = 'rajesh.kumar@email.com'
        department  = 'Network Support' )

      ( agent_id    = 'AGT002'
        agent_name  = 'Anjali Gupta'
        email       = 'anjali.gupta@email.com'
        department  = 'Billing Support' )

      ( agent_id    = 'AGT003'
        agent_name  = 'Vivek Sharma'
        email       = 'vivek.sharma@email.com'
        department  = 'Technical Support' )

      ( agent_id    = 'AGT004'
        agent_name  = 'Priyanka Singh'
        email       = 'priyanka.singh@email.com'
        department  = 'Customer Service' )

      ( agent_id    = 'AGT005'
        agent_name  = 'Rohan Das'
        email       = 'rohan.das@email.com'
        department  = 'Infrastructure Support' )

      ( agent_id    = 'AGT006'
        agent_name  = 'Sneha Patel'
        email       = 'sneha.patel@email.com'
        department  = 'Network Support' )

      ( agent_id    = 'AGT007'
        agent_name  = 'Kunal Mehra'
        email       = 'kunal.mehra@email.com'
        department  = 'Technical Support' )

      ( agent_id    = 'AGT008'
        agent_name  = 'Aditi Roy'
        email       = 'aditi.roy@email.com'
        department  = 'Billing Support' )

      ( agent_id    = 'AGT009'
        agent_name  = 'Nikhil Verma'
        email       = 'nikhil.verma@email.com'
        department  = 'Customer Service' )

      ( agent_id    = 'AGT010'
        agent_name  = 'Megha Nair'
        email       = 'megha.nair@email.com'
        department  = 'Infrastructure Support' )

    ).

    INSERT zsn_agent FROM TABLE @lt_agent.

    out->write(
      |Agent Master Data Loaded Successfully. ({ lines( lt_agent ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_complaint.

    DATA:
      lt_complaints TYPE STANDARD TABLE OF zsn_cmp_hdr,
      lv_timestamp  TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    lt_complaints = VALUE #(

      ( complaint_id    = 'CMP001'
        customer_id     = 'CUST001'
        priority_id     = 'HIGH'
        status_id       = 'NEW'
        category_id     = 'CAT001'
        title           = 'Internet not working since morning'
        description     = 'Internet connectivity has been unavailable since 8:00 AM. Restarting the router multiple times did not restore the connection.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP002'
        customer_id     = 'CUST002'
        priority_id     = 'MEDIUM'
        status_id       = 'NEW'
        category_id     = 'CAT003'
        title           = 'Incorrect monthly bill amount'
        description     = 'The latest monthly bill contains unexpected additional charges. Requesting a detailed verification of the invoice.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP003'
        customer_id     = 'CUST003'
        priority_id     = 'HIGH'
        status_id       = 'ASSIGNED'
        category_id     = 'CAT004'
        agent_id        = 'AGT001'
        title           = 'Unable to configure Wi-Fi router'
        description     = 'Unable to complete the initial Wi-Fi router configuration. The router setup wizard stops responding during installation.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP004'
        customer_id     = 'CUST004'
        priority_id     = 'LOW'
        status_id       = 'ASSIGNED'
        category_id     = 'CAT008'
        agent_id        = 'AGT003'
        title           = 'Password reset email not received'
        description     = 'Password reset was requested multiple times but no reset email has been received. Spam folder has already been checked.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP005'
        customer_id     = 'CUST005'
        priority_id     = 'CRITICAL'
        status_id       = 'INPROGRESS'
        category_id     = 'CAT006'
        agent_id        = 'AGT005'
        title           = 'Complete internet outage in locality'
        description     = 'A complete internet outage is affecting the entire locality. Multiple neighboring users are experiencing the same issue.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP006'
        customer_id     = 'CUST006'
        priority_id     = 'HIGH'
        status_id       = 'INPROGRESS'
        category_id     = 'CAT002'
        agent_id        = 'AGT006'
        title           = 'Internet speed below subscribed plan'
        description     = 'Internet speed consistently remains far below the subscribed bandwidth, especially during evening hours.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP007'
        customer_id     = 'CUST007'
        priority_id     = 'MEDIUM'
        status_id       = 'RESOLVED'
        category_id     = 'CAT007'
        agent_id        = 'AGT004'
        title           = 'Unable to login to customer portal'
        description     = 'Customer cannot access the self-service portal despite entering the correct credentials. Login page displays an authentication error.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP008'
        customer_id     = 'CUST008'
        priority_id     = 'LOW'
        status_id       = 'RESOLVED'
        category_id     = 'CAT009'
        agent_id        = 'AGT007'
        title           = 'Outlook email configuration issue'
        description     = 'Unable to configure Outlook with the provided email account settings. Incoming and outgoing servers cannot be reached.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP009'
        customer_id     = 'CUST009'
        priority_id     = 'HIGH'
        status_id       = 'CLOSED'
        category_id     = 'CAT005'
        agent_id        = 'AGT005'
        title           = 'Delay in fiber installation'
        description     = 'Fiber installation appointment has been postponed twice. Requesting an updated installation schedule.'
        closed_by       = 'AGT005'
        closed_on       = lv_timestamp
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP010'
        customer_id     = 'CUST010'
        priority_id     = 'MEDIUM'
        status_id       = 'CLOSED'
        category_id     = 'CAT003'
        agent_id        = 'AGT002'
        title           = 'Refund not processed'
        description     = 'A refund promised after service cancellation has not yet been credited to the registered bank account.'
        closed_by       = 'AGT002'
        closed_on       = lv_timestamp
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP011'
        customer_id     = 'CUST011'
        priority_id     = 'LOW'
        status_id       = 'CANCELLED'
        category_id     = 'CAT010'
        title           = 'Issue resolved before support'
        description     = 'The customer resolved the technical issue independently before support intervention and requested cancellation.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP012'
        customer_id     = 'CUST012'
        priority_id     = 'MEDIUM'
        status_id       = 'CANCELLED'
        category_id     = 'CAT001'
        title           = 'Temporary connection issue'
        description     = 'Internet connectivity was temporarily unavailable but service resumed automatically before troubleshooting began.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP013'
        customer_id     = 'CUST013'
        priority_id     = 'CRITICAL'
        status_id       = 'NEW'
        category_id     = 'CAT006'
        title           = 'Frequent disconnections in office'
        description     = 'Internet disconnects repeatedly during office working hours, causing disruption to business operations.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP014'
        customer_id     = 'CUST014'
        priority_id     = 'HIGH'
        status_id       = 'ASSIGNED'
        category_id     = 'CAT004'
        agent_id        = 'AGT001'
        title           = 'Router keeps restarting automatically'
        description     = 'The router restarts automatically every few hours even after performing a factory reset.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

      ( complaint_id    = 'CMP015'
        customer_id     = 'CUST015'
        priority_id     = 'MEDIUM'
        status_id       = 'INPROGRESS'
        category_id     = 'CAT002'
        agent_id        = 'AGT006'
        title           = 'Slow speed during peak hours'
        description     = 'Internet speed drops significantly during peak evening hours, making video conferencing difficult.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp
        last_changed_at = lv_timestamp )

    ).

    INSERT zsn_cmp_hdr FROM TABLE @lt_complaints.

    out->write(
      |Complaint Master Data Loaded Successfully. ({ lines( lt_complaints ) } Records)|
    ).

  ENDMETHOD.


  METHOD load_comment.

    DATA:
      lt_comments  TYPE STANDARD TABLE OF zsn_cmp_comment,
      lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    lt_comments = VALUE #(

      ( comment_id      = 'COM001'
        complaint_id    = 'CMP001'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST001'
        comment_text    = 'Internet has been unavailable since this morning. Kindly resolve the issue as soon as possible.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM002'
        complaint_id    = 'CMP002'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST002'
        comment_text    = 'The monthly bill includes unexpected charges. Please verify the invoice.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM003'
        complaint_id    = 'CMP003'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST003'
        comment_text    = 'Router setup keeps failing during configuration.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM004'
        complaint_id    = 'CMP003'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT001'
        comment_text    = 'Complaint assigned. Please share the router model and firmware version.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM005'
        complaint_id    = 'CMP004'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST004'
        comment_text    = 'Password reset email has not been received after multiple attempts.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM006'
        complaint_id    = 'CMP004'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT003'
        comment_text    = 'The issue has been assigned. Email delivery logs are being verified.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM007'
        complaint_id    = 'CMP005'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST005'
        comment_text    = 'The entire locality is experiencing an internet outage.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM008'
        complaint_id    = 'CMP005'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT005'
        comment_text    = 'Remote diagnostics have been initiated for the affected area.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM009'
        complaint_id    = 'CMP005'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT005'
        comment_text    = 'Issue escalated to the infrastructure team for immediate resolution.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM010'
        complaint_id    = 'CMP006'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST006'
        comment_text    = 'Internet speed is much lower than the subscribed bandwidth.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM011'
        complaint_id    = 'CMP006'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT006'
        comment_text    = 'Line quality has been checked. Further investigation is in progress.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM012'
        complaint_id    = 'CMP006'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT006'
        comment_text    = 'Network optimization has been scheduled for this connection.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM013'
        complaint_id    = 'CMP007'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST007'
        comment_text    = 'Unable to access the customer portal using valid credentials.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM014'
        complaint_id    = 'CMP007'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT004'
        comment_text    = 'Account credentials have been reset. Please try logging in again.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM015'
        complaint_id    = 'CMP007'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST007'
        comment_text    = 'The issue has been resolved successfully. Thank you for the support.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM016'
        complaint_id    = 'CMP008'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST008'
        comment_text    = 'Unable to configure Outlook using the provided email settings.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM017'
        complaint_id    = 'CMP008'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT007'
        comment_text    = 'Email configuration has been corrected. The issue is now resolved.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM018'
        complaint_id    = 'CMP013'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST013'
        comment_text    = 'Internet disconnects repeatedly during office working hours.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM019'
        complaint_id    = 'CMP014'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST014'
        comment_text    = 'The router restarts automatically every few hours.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM020'
        complaint_id    = 'CMP014'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT001'
        comment_text    = 'Complaint assigned. Hardware diagnostics have been initiated.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM021'
        complaint_id    = 'CMP015'
        comment_by_type = 'CUSTOMER'
        comment_by_id   = 'CUST015'
        comment_text    = 'Internet speed drops significantly during evening hours.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM022'
        complaint_id    = 'CMP015'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT006'
        comment_text    = 'Bandwidth utilization has been analyzed. Optimization is in progress.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

      ( comment_id      = 'COM023'
        complaint_id    = 'CMP015'
        comment_by_type = 'AGENT'
        comment_by_id   = 'AGT006'
        comment_text    = 'Network optimization completed. Service quality is being monitored.'
        created_by      = cl_abap_context_info=>get_user_technical_name( )
        created_at      = lv_timestamp )

    ).

    INSERT zsn_cmp_comment FROM TABLE @lt_comments.

    out->write(
      |Complaint Comment Data Loaded Successfully. ({ lines( lt_comments ) } Records)|
    ).

  ENDMETHOD.

ENDCLASS.
