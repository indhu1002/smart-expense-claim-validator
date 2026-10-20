CLASS zcl_ind10_review_setup DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.
CLASS zcl_ind10_review_setup IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    "Explicit assignment requested for reviewer@example.invalid.
    "The verified ABAP identity is fixed; never derive grants from claim input.
    DATA(actor) = cl_abap_context_info=>get_user_technical_name( ).
    IF actor <> 'CB0000000000'.
      out->write( 'Assignment denied: unexpected setup identity' ).
      RETURN.
    ENDIF.
    MODIFY zind10_reviewer FROM @( VALUE #( user_id = 'CB0000000000' active = 'X' ) ).
    COMMIT WORK AND WAIT.
    IF zcl_ind10_exp_access=>is_reviewer( ) = abap_true.
      out->write( 'Project reviewer active: CB0000000000 (reviewer@example.invalid)' ).
      out->write( 'Self-review remains prohibited.' ).
    ELSE.
      out->write( 'Assignment verification failed' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
