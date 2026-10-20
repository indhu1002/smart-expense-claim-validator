CLASS zcl_ind10_demo_reset DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.
CLASS zcl_ind10_demo_reset IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    "The one-time authorized reset completed on 2026-10-20.
    "This retained class is read-only. It cannot reset review decisions.
    DATA(actor) = cl_abap_context_info=>get_user_technical_name( ).
    IF actor <> 'CB0000000000' OR zcl_ind10_exp_access=>is_reviewer( ) = abap_false.
      out->write( 'Authorized project reviewer required.' ).
      RETURN.
    ENDIF.
    out->write( 'Reset completed. This class now only lists the demo claims.' ).
    out->write( 'DEMO_EMP identities are fictional fixtures, not SAP login accounts.' ).
    SELECT claim_id, employee_name, category, amount, status, local_created_by
      FROM zzclaimi10 WHERE description LIKE 'DEMO FIXTURE:%'
      ORDER BY claim_id INTO TABLE @DATA(rows).
    out->write( rows ).
    out->write( |Demo claims: { lines( rows ) }. No data changed.| ).
  ENDMETHOD.
ENDCLASS.
