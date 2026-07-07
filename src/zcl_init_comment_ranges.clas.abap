CLASS zcl_init_comment_ranges DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_init_comment_ranges IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

    " Set up intervals matching the 10-character domain length restriction for comments
    lt_intervals = VALUE #( ( nrrangenr  = '01'
                              fromnumber = '0000000001'
                              tonumber   = '0000999999'
                              toyear     = '0000'
                              procind    = 'I' ) ).
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = lt_intervals
            object    = 'ZSN_COM_NR' " 🚀 Targets ONLY your new comment object
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error_inf)
        ).

        IF lv_error IS INITIAL.
          out->write( 'Comment interval initialized successfully!' ).
        ELSE.
          out->write( 'Interval initialization completed with warnings/errors.' ).
        ENDIF.

      CATCH cx_number_ranges INTO DATA(lx_error).
        out->write( 'Error occurred: ' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
