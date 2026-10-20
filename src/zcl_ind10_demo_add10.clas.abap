CLASS zcl_ind10_demo_add10 DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.
CLASS zcl_ind10_demo_add10 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(actor) = cl_abap_context_info=>get_user_technical_name( ).
    IF actor <> 'CB0000000000' OR zcl_ind10_exp_access=>is_reviewer( ) = abap_false.
      out->write( 'STOP: authorized project reviewer required. No changes.' ).
      RETURN.
    ENDIF.
    SELECT * FROM zzclaimi10 ORDER BY uuid INTO TABLE @DATA(before_claims).
    SELECT * FROM zzclaim_di10 ORDER BY uuid INTO TABLE @DATA(before_drafts).
    LOOP AT before_claims INTO DATA(existing).
      IF existing-claim_id >= 'DEMO-013' AND existing-claim_id <= 'DEMO-022'.
        out->write( 'STOP: additional demo IDs already exist. No changes.' ).
        RETURN.
      ENDIF.
    ENDLOOP.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA stamp TYPE timestampl.
    GET TIME STAMP FIELD stamp.
    DATA demo TYPE STANDARD TABLE OF zzclaimi10 WITH EMPTY KEY.
    demo = VALUE #(
      ( claim_id = 'DEMO-013' employee_id = 'DEMOEMP13' employee_name = 'Leela Demo'
        expense_date = today - 1 category = 'MEALS' amount = '650.00' currency = 'INR'
        merchant = 'Demo Lunch Room' receipt_reference = 'ADD013'
        description = 'DEMO FIXTURE: Valid team lunch' local_created_by = 'DEMO_EMP13' )
      ( claim_id = 'DEMO-014' employee_id = 'DEMOEMP14' employee_name = 'Omar Demo'
        expense_date = today - 2 category = 'TRAVEL' amount = '2400.00' currency = 'INR'
        merchant = 'Demo Railways' receipt_reference = 'ADD014'
        description = 'DEMO FIXTURE: Valid business travel' local_created_by = 'DEMO_EMP14' )
      ( claim_id = 'DEMO-015' employee_id = 'DEMOEMP15' employee_name = 'Tara Demo'
        expense_date = today - 3 category = 'HOTEL' amount = '8000.00' currency = 'INR'
        merchant = 'Demo City Hotel' receipt_reference = 'ADD015'
        description = 'DEMO FIXTURE: Hotel at policy limit' local_created_by = 'DEMO_EMP15' )
      ( claim_id = 'DEMO-016' employee_id = 'DEMOEMP16' employee_name = 'Nikhil Demo'
        expense_date = today - 4 category = 'OFFICE' amount = '2000.00' currency = 'INR'
        merchant = 'Demo Office Store' receipt_reference = 'ADD016'
        description = 'DEMO FIXTURE: Office supplies at policy limit' local_created_by = 'DEMO_EMP16' )
      ( claim_id = 'DEMO-017' employee_id = 'DEMOEMP17' employee_name = 'Zoya Demo'
        expense_date = today - 1 category = 'MEALS' amount = '1350.00' currency = 'INR'
        merchant = 'Demo Restaurant' receipt_reference = 'ADD017'
        description = 'DEMO FIXTURE: Meal exceeds INR 1000 limit' local_created_by = 'DEMO_EMP17' )
      ( claim_id = 'DEMO-018' employee_id = 'DEMOEMP18' employee_name = 'Aman Demo'
        expense_date = today - 2 category = 'TRAVEL' amount = '6100.00' currency = 'INR'
        merchant = 'Demo Flights' receipt_reference = 'ADD018'
        description = 'DEMO FIXTURE: Travel exceeds INR 5000 limit' local_created_by = 'DEMO_EMP18' )
      ( claim_id = 'DEMO-019' employee_id = 'DEMOEMP19' employee_name = 'Rhea Demo'
        expense_date = today - 3 category = 'OFFICE' amount = '750.00' currency = 'INR'
        merchant = 'Demo Stationery' receipt_reference = ''
        description = 'DEMO FIXTURE: Missing receipt reference' local_created_by = 'DEMO_EMP19' )
      ( claim_id = 'DEMO-020' employee_id = 'DEMOEMP20' employee_name = 'Kabir Demo'
        expense_date = today + 2 category = 'HOTEL' amount = '4500.00' currency = 'INR'
        merchant = 'Demo Inn' receipt_reference = 'ADD020'
        description = 'DEMO FIXTURE: Future expense date' local_created_by = 'DEMO_EMP20' )
      ( claim_id = 'DEMO-021' employee_id = 'DEMOEMP21' employee_name = 'Anaya Demo'
        expense_date = today - 2 category = 'OFFICE' amount = '450.00' currency = 'INR'
        merchant = 'Demo Supplies' receipt_reference = 'ADD-DUP021'
        description = 'DEMO FIXTURE: Duplicate receipt first copy' local_created_by = 'DEMO_EMP21' )
      ( claim_id = 'DEMO-022' employee_id = 'DEMOEMP21' employee_name = 'Anaya Demo'
        expense_date = today - 2 category = 'OFFICE' amount = '450.00' currency = 'INR'
        merchant = 'Demo Supplies' receipt_reference = 'ADD-DUP021'
        description = 'DEMO FIXTURE: Duplicate receipt second copy' local_created_by = 'DEMO_EMP21' )
    ).
    TRY.
        LOOP AT demo ASSIGNING FIELD-SYMBOL(<row>).
          <row>-client = sy-mandt.
          <row>-uuid = cl_system_uuid=>create_uuid_x16_static( ).
          <row>-status = 'NEW'.
          <row>-criticality = 2.
          <row>-validation_message = 'Fictional demo claim. Awaiting reviewer validation.'.
          <row>-local_created_at = stamp.
          <row>-local_last_changed_by = actor.
          <row>-local_last_changed_at = stamp.
          <row>-last_changed_at = stamp.
        ENDLOOP.
        INSERT zzclaimi10 FROM TABLE @demo.
        IF sy-dbcnt <> 10.
          ROLLBACK WORK.
          out->write( 'STOP: incomplete insert rolled back.' ).
          RETURN.
        ENDIF.
        SELECT * FROM zzclaimi10 ORDER BY uuid INTO TABLE @DATA(after_claims).
        SELECT * FROM zzclaim_di10 ORDER BY uuid INTO TABLE @DATA(after_drafts).
        LOOP AT demo INTO DATA(added).
          DELETE after_claims WHERE uuid = added-uuid.
        ENDLOOP.
        IF before_claims <> after_claims OR before_drafts <> after_drafts.
          ROLLBACK WORK.
          out->write( 'STOP: concurrent change detected. Demo insert rolled back.' ).
          RETURN.
        ENDIF.
        COMMIT WORK AND WAIT.
      CATCH cx_root INTO DATA(error).
        ROLLBACK WORK.
        out->write( error->get_text( ) ).
        RETURN.
    ENDTRY.
    out->write( |ADDED: 10 NEW claims. Preserved { lines( before_claims ) } existing claims and { lines( before_drafts ) } drafts.| ).
    MODIFY ENTITIES OF zzr_claimi10 ENTITY Claim EXECUTE Validate
      FROM VALUE #( FOR entry IN demo ( UUID = entry-uuid %is_draft = if_abap_behv=>mk-off ) )
      RESULT DATA(validated) FAILED DATA(validation_failed) REPORTED DATA(validation_reported).
    DATA ready_count TYPE i.
    DATA flagged_count TYPE i.
    LOOP AT validated INTO DATA(validation).
      CASE validation-%param-Status.
        WHEN 'READY'. ready_count += 1.
        WHEN 'FLAGGED'. flagged_count += 1.
      ENDCASE.
    ENDLOOP.
    out->write( |Validation: READY={ ready_count }, FLAGGED={ flagged_count }, failed={ lines( validation_failed-claim ) }. Expected 4 READY and 6 FLAGGED.| ).
    ROLLBACK ENTITIES.
    SELECT claim_id, employee_name, category, amount, status
      FROM zzclaimi10 WHERE claim_id >= 'DEMO-013' AND claim_id <= 'DEMO-022'
      ORDER BY claim_id INTO TABLE @DATA(final_rows).
    out->write( final_rows ).
    out->write( 'Validation test rolled back. New claims remain NEW for your review.' ).
  ENDMETHOD.
ENDCLASS.
