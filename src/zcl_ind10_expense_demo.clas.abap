CLASS zcl_ind10_expense_demo DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.
CLASS zcl_ind10_expense_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA(owner) = cl_abap_context_info=>get_user_technical_name( ).
    SELECT SINGLE uuid FROM zzclaimi10 WHERE local_created_by = @owner
      AND claim_id LIKE 'DEMO-%' INTO @DATA(existing).
    IF sy-subrc = 0.
      out->write( 'Demo claims already exist. No data changed.' ).
    ELSE.
      MODIFY ENTITIES OF zzr_claimi10 ENTITY Claim
        CREATE FIELDS ( ClaimID EmployeeID EmployeeName ExpenseDate Category Amount Currency Merchant ReceiptReference Description )
        WITH VALUE #(
          ( %cid = 'C1' ClaimID = 'DEMO-001' EmployeeID = 'EMP001' EmployeeName = 'Asha Demo'
            ExpenseDate = today - 2 Category = 'MEALS' Amount = '750.00' Currency = 'INR'
            Merchant = 'Demo Cafe' ReceiptReference = 'DEMO-R001' Description = 'Client meeting lunch - valid claim' )
          ( %cid = 'C2' ClaimID = 'DEMO-002' EmployeeID = 'EMP002' EmployeeName = 'Ravi Demo'
            ExpenseDate = today - 3 Category = 'HOTEL' Amount = '9500.00' Currency = 'INR'
            Merchant = 'Demo Hotel' ReceiptReference = 'DEMO-R002' Description = 'Hotel claim above the INR 8000 policy cap' )
          ( %cid = 'C3' ClaimID = 'DEMO-003' EmployeeID = 'EMP003' EmployeeName = 'Mira Demo'
            ExpenseDate = today - 1 Category = 'TRAVEL' Amount = '450.00' Currency = 'INR'
            Merchant = 'Demo Taxi' ReceiptReference = '' Description = 'Taxi trip with missing receipt reference' )
          ( %cid = 'C4' ClaimID = 'DEMO-004' EmployeeID = 'EMP004' EmployeeName = 'Dev Demo'
            ExpenseDate = today - 4 Category = 'OFFICE' Amount = '600.00' Currency = 'INR'
            Merchant = 'Demo Stationery' ReceiptReference = 'DEMO-DUP' Description = 'First of two claims using the same receipt' )
          ( %cid = 'C5' ClaimID = 'DEMO-005' EmployeeID = 'EMP004' EmployeeName = 'Dev Demo'
            ExpenseDate = today - 4 Category = 'OFFICE' Amount = '600.00' Currency = 'INR'
            Merchant = 'Demo Stationery' ReceiptReference = 'DEMO-DUP' Description = 'Second claim using the same receipt' )
          ( %cid = 'C6' ClaimID = 'DEMO-006' EmployeeID = 'EMP006' EmployeeName = 'Neha Demo'
            ExpenseDate = today + 1 Category = 'MEALS' Amount = '500.00' Currency = 'INR'
            Merchant = 'Demo Bistro' ReceiptReference = 'DEMO-R006' Description = 'Expense date in the future' ) )
        MAPPED DATA(mapped) FAILED DATA(failed) REPORTED DATA(reported).
      IF failed-claim IS NOT INITIAL.
        out->write( 'Create failed; no demo claims committed.' ).
        LOOP AT reported-claim INTO DATA(message).
          IF message-%msg IS BOUND. out->write( message-%msg->if_message~get_text( ) ). ENDIF.
        ENDLOOP.
        ROLLBACK ENTITIES.
        RETURN.
      ENDIF.
      COMMIT ENTITIES RESPONSE OF zzr_claimi10 FAILED DATA(save_failed) REPORTED DATA(save_reported).
      IF sy-subrc <> 0.
        out->write( 'Save failed; inspect reported messages.' ).
        LOOP AT save_reported-claim INTO DATA(save_message).
          IF save_message-%msg IS BOUND. out->write( save_message-%msg->if_message~get_text( ) ). ENDIF.
        ENDLOOP.
        RETURN.
      ENDIF.
      out->write( 'Created six fictional claims through RAP, including policy and duplicate checks.' ).
    ENDIF.
    SELECT claim_id, employee_id, category, amount, currency, status, validation_message
      FROM zzclaimi10 WHERE local_created_by = @owner AND claim_id LIKE 'DEMO-%'
      ORDER BY claim_id INTO TABLE @DATA(claims).
    out->write( claims ).
  ENDMETHOD.
ENDCLASS.
