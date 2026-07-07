CLASS zcl_init_number_ranges DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_init_number_ranges IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

    " Set up intervals matching the 10-character domain length restriction
    lt_intervals = VALUE #( ( nrrangenr  = '01'
                              fromnumber = '0000000001'
                              tonumber   = '0000999999'
                              toyear     = '0000'
                              procind    = 'I' ) ).
    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = lt_intervals
            object    = 'ZSN_CMP_NR'
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error_inf)
        ).

        out->write( 'Interval initialized successfully!' ).

      CATCH cx_number_ranges INTO DATA(lx_error).
        out->write( 'Error occurred: ' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
