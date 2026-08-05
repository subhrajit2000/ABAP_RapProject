CLASS zcl_clean_drafts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_clean_drafts IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DELETE FROM zsn_cmp_com_d.
    DELETE FROM zsn_cmp_hdr_d.

    out->write( 'Draft tables cleared successfully!' ).

  ENDMETHOD.

ENDCLASS.
