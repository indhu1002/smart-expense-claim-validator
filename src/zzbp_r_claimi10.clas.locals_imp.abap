CLASS lhc_claim DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES tt_claims TYPE STANDARD TABLE OF zzr_claimi10 WITH EMPTY KEY.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Claim RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Claim RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Claim RESULT result.
    METHODS permissions IMPORTING claim TYPE zzr_claimi10 is_draft TYPE abap_bool
      RETURNING VALUE(allowed) TYPE zcl_ind10_exp_access=>ty_permissions.
    METHODS ResetReview FOR DETERMINE ON MODIFY IMPORTING keys FOR Claim~ResetReview.
    METHODS AssessOnSave FOR DETERMINE ON SAVE IMPORTING keys FOR Claim~AssessOnSave.
    METHODS Validate FOR MODIFY IMPORTING keys FOR ACTION Claim~Validate RESULT result.
    METHODS Approve FOR MODIFY IMPORTING keys FOR ACTION Claim~Approve RESULT result.
    METHODS Reject FOR MODIFY IMPORTING keys FOR ACTION Claim~Reject RESULT result.
    METHODS assess IMPORTING claim TYPE zzr_claimi10 peers TYPE tt_claims
      RETURNING VALUE(outcome) TYPE zcl_ind10_expense_rules=>ty_result.
ENDCLASS.

CLASS lhc_claim IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
    result-%action-Edit = if_abap_behv=>auth-allowed.
    DATA(review) = COND #( WHEN zcl_ind10_exp_access=>is_reviewer( ) = abap_true
      THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
    result-%action-Validate = review.
    result-%action-Approve = review.
    result-%action-Reject = review.
  ENDMETHOD.

  METHOD permissions.
    allowed = zcl_ind10_exp_access=>decide(
      actor = cl_abap_context_info=>get_user_technical_name( )
      owner = CONV #( claim-LocalCreatedBy ) reviewer = zcl_ind10_exp_access=>is_reviewer( )
      status = CONV #( claim-Status ) is_draft = is_draft ).
    "A draft opened before an approval must not overwrite that approved record.
    SELECT SINGLE status FROM zzclaimi10 WHERE uuid = @claim-UUID INTO @DATA(persisted_status).
    IF sy-subrc = 0 AND persisted_status = 'APPROVED'.
      CLEAR allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(access) = permissions( claim = CORRESPONDING #( row )
        is_draft = xsdbool( row-%is_draft = if_abap_behv=>mk-on ) ).
      DATA(edit) = COND #( WHEN access-edit = abap_true THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized ).
      DATA(review) = COND #( WHEN access-review = abap_true THEN if_abap_behv=>auth-allowed
        ELSE if_abap_behv=>auth-unauthorized ).
      APPEND VALUE #( %tky = row-%tky %update = edit %delete = edit
        %action-Edit = edit %action-Validate = review
        %action-Approve = review %action-Reject = review ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(access) = permissions( claim = CORRESPONDING #( row )
        is_draft = xsdbool( row-%is_draft = if_abap_behv=>mk-on ) ).
      DATA(edit) = COND #( WHEN access-edit = abap_true THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled ).
      DATA(review) = COND #( WHEN access-review = abap_true THEN if_abap_behv=>fc-o-enabled
        ELSE if_abap_behv=>fc-o-disabled ).
      APPEND VALUE #( %tky = row-%tky %update = edit %delete = edit
        %action-Edit = edit %action-Validate = review
        %action-Approve = review %action-Reject = review ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD ResetReview.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(currency) = COND zzr_claimi10-Currency( WHEN row-Currency IS INITIAL THEN 'INR' ELSE to_upper( row-Currency ) ).
      IF row-Status = 'NEW' AND row-Currency = currency
        AND row-Category = to_upper( row-Category )
        AND row-ClaimID = to_upper( condense( row-ClaimID ) )
        AND row-EmployeeID = to_upper( condense( row-EmployeeID ) )
        AND row-Merchant = condense( row-Merchant )
        AND row-ReceiptReference = to_upper( condense( row-ReceiptReference ) ).
        CONTINUE.
      ENDIF.
      MODIFY ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
        UPDATE FIELDS ( Status ValidationMessage Criticality Currency Category ClaimID EmployeeID Merchant ReceiptReference )
        WITH VALUE #( ( %tky = row-%tky Status = 'NEW'
          ValidationMessage = 'Save to run policy checks and submit for reviewer approval' Criticality = 0
          Currency = currency Category = to_upper( row-Category )
          ClaimID = to_upper( condense( row-ClaimID ) ) EmployeeID = to_upper( condense( row-EmployeeID ) )
          Merchant = condense( row-Merchant ) ReceiptReference = to_upper( condense( row-ReceiptReference ) ) ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD assess.
    DATA duplicate TYPE abap_bool.
    DATA(owner) = COND #( WHEN claim-LocalCreatedBy IS NOT INITIAL THEN CONV string( claim-LocalCreatedBy )
      ELSE cl_abap_context_info=>get_user_technical_name( ) ).
    SELECT SINGLE uuid FROM zzclaimi10
      WHERE uuid <> @claim-UUID AND local_created_by = @owner AND status <> 'REJECTED'
      AND ( ( claim_id = @claim-ClaimID AND claim_id <> '' )
        OR ( employee_id = @claim-EmployeeID AND employee_id <> ''
          AND ( ( receipt_reference = @claim-ReceiptReference AND receipt_reference <> '' )
            OR ( expense_date = @claim-ExpenseDate AND amount = @claim-Amount
              AND upper( merchant ) = @( to_upper( claim-Merchant ) ) AND merchant <> '' ) ) ) )
      INTO @DATA(other_uuid).
    duplicate = xsdbool( sy-subrc = 0 ).
    LOOP AT peers INTO DATA(peer) WHERE UUID <> claim-UUID AND Status <> 'REJECTED'.
      IF peer-LocalCreatedBy <> claim-LocalCreatedBy. CONTINUE. ENDIF.
      IF ( claim-ClaimID IS NOT INITIAL AND peer-ClaimID = claim-ClaimID )
        OR ( claim-EmployeeID IS NOT INITIAL AND peer-EmployeeID = claim-EmployeeID
          AND ( ( claim-ReceiptReference IS NOT INITIAL AND peer-ReceiptReference = claim-ReceiptReference )
            OR ( claim-Merchant IS NOT INITIAL AND peer-ExpenseDate = claim-ExpenseDate
              AND peer-Amount = claim-Amount AND to_upper( peer-Merchant ) = to_upper( claim-Merchant ) ) ) ).
        duplicate = abap_true.
      ENDIF.
    ENDLOOP.
    outcome = zcl_ind10_expense_rules=>assess(
      claim = VALUE #( claim_id = claim-ClaimID employee_id = claim-EmployeeID
        expense_date = claim-ExpenseDate category = claim-Category amount = claim-Amount
        currency = claim-Currency merchant = claim-Merchant receipt_reference = claim-ReceiptReference )
      today = cl_abap_context_info=>get_system_date( ) duplicate = duplicate ).
  ENDMETHOD.

  METHOD AssessOnSave.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row) WHERE Status <> 'APPROVED' AND Status <> 'REJECTED'.
      DATA(outcome) = assess( claim = CORRESPONDING #( row ) peers = CORRESPONDING #( claims ) ).
      MODIFY ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
        UPDATE FIELDS ( Status ValidationMessage Criticality )
        WITH VALUE #( ( %tky = row-%tky Status = outcome-status
          ValidationMessage = outcome-summary Criticality = outcome-criticality ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD Validate.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(access) = permissions( claim = CORRESPONDING #( row )
        is_draft = xsdbool( row-%is_draft = if_abap_behv=>mk-on ) ).
      IF access-review = abap_false.
        APPEND VALUE #( %tky = row-%tky ) TO failed-claim.
        APPEND VALUE #( %tky = row-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Only an authorized reviewer can review another user''s saved, open claim' ) ) TO reported-claim.
        CONTINUE.
      ENDIF.
      DATA(outcome) = assess( claim = CORRESPONDING #( row ) peers = CORRESPONDING #( claims ) ).
      MODIFY ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
        UPDATE FIELDS ( Status ValidationMessage Criticality )
        WITH VALUE #( ( %tky = row-%tky Status = outcome-status
          ValidationMessage = outcome-summary Criticality = outcome-criticality ) ).
      LOOP AT outcome-issues INTO DATA(issue).
        APPEND VALUE #( %tky = row-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-information text = issue-text ) ) TO reported-claim.
      ENDLOOP.
    ENDLOOP.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT claims.
    result = VALUE #( FOR updated IN claims ( %tky = updated-%tky %param = updated ) ).
  ENDMETHOD.

  METHOD Approve.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(access) = permissions( claim = CORRESPONDING #( row )
        is_draft = xsdbool( row-%is_draft = if_abap_behv=>mk-on ) ).
      IF access-review = abap_false.
        APPEND VALUE #( %tky = row-%tky ) TO failed-claim.
        APPEND VALUE #( %tky = row-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Only an authorized reviewer can review another user''s saved, open claim' ) ) TO reported-claim.
        CONTINUE.
      ENDIF.
      DATA(outcome) = assess( claim = CORRESPONDING #( row ) peers = CORRESPONDING #( claims ) ).
      IF outcome-issues IS NOT INITIAL.
        APPEND VALUE #( %tky = row-%tky ) TO failed-claim.
        LOOP AT outcome-issues INTO DATA(issue).
          APPEND VALUE #( %tky = row-%tky %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error text = issue-text ) ) TO reported-claim.
        ENDLOOP.
        CONTINUE.
      ENDIF.
      MODIFY ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
        UPDATE FIELDS ( Status ValidationMessage Criticality )
        WITH VALUE #( ( %tky = row-%tky Status = 'APPROVED'
          ValidationMessage = 'Approved after all policy checks passed' Criticality = 3 ) ).
    ENDLOOP.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT claims.
    result = VALUE #( FOR updated IN claims ( %tky = updated-%tky %param = updated ) ).
  ENDMETHOD.

  METHOD Reject.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(claims).
    LOOP AT claims INTO DATA(row).
      DATA(access) = permissions( claim = CORRESPONDING #( row )
        is_draft = xsdbool( row-%is_draft = if_abap_behv=>mk-on ) ).
      IF access-review = abap_false.
        APPEND VALUE #( %tky = row-%tky ) TO failed-claim.
        APPEND VALUE #( %tky = row-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Only an authorized reviewer can review another user''s saved, open claim' ) ) TO reported-claim.
        CONTINUE.
      ENDIF.
      MODIFY ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
        UPDATE FIELDS ( Status ValidationMessage Criticality )
        WITH VALUE #( ( %tky = row-%tky Status = 'REJECTED'
          ValidationMessage = 'Rejected by authorized reviewer; edit to correct and resubmit' Criticality = 1 ) ).
    ENDLOOP.
    READ ENTITIES OF zzr_claimi10 IN LOCAL MODE ENTITY Claim
      ALL FIELDS WITH CORRESPONDING #( keys ) RESULT claims.
    result = VALUE #( FOR updated IN claims ( %tky = updated-%tky %param = updated ) ).
  ENDMETHOD.
ENDCLASS.
