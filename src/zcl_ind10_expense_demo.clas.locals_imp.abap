CLASS ltc_policy DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA claim TYPE zcl_ind10_expense_rules=>ty_claim.
    METHODS setup.
    METHODS valid_claim FOR TESTING.
    METHODS cap_boundary FOR TESTING.
    METHODS negative_amount FOR TESTING.
    METHODS future_date FOR TESTING.
    METHODS age_boundary FOR TESTING.
    METHODS missing_receipt FOR TESTING.
    METHODS duplicate_claim FOR TESTING.
    METHODS unsupported_currency FOR TESTING.
    METHODS category_caps FOR TESTING.
    METHODS invalid_dates FOR TESTING.
    METHODS mandatory_fields FOR TESTING.
    METHODS multiple_reasons FOR TESTING.
ENDCLASS.
CLASS ltc_policy IMPLEMENTATION.
  METHOD setup.
    claim = VALUE #( claim_id = 'TST001' employee_id = 'EMP001'
      expense_date = '20261015' category = 'MEALS' amount = '750.00'
      currency = 'INR' merchant = 'Demo Cafe' receipt_reference = 'RCPT-001' ).
  ENDMETHOD.
  METHOD valid_claim.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = r-status exp = 'READY' ).
    cl_abap_unit_assert=>assert_initial( r-issues ).
  ENDMETHOD.
  METHOD cap_boundary.
    claim-amount = '1000.00'.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = r-status exp = 'READY' ).
    claim-amount = '1000.01'.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'OVER_LIMIT' ] ) ) ).
  ENDMETHOD.
  METHOD negative_amount.
    claim-amount = '-0.01'.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'AMOUNT' ] ) ) ).
    claim-amount = 0.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = r-status exp = 'FLAGGED' ).
  ENDMETHOD.
  METHOD future_date.
    claim-expense_date = '20261016'.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'FUTURE_DATE' ] ) ) ).
  ENDMETHOD.
  METHOD age_boundary.
    claim-expense_date = CONV d( '20261015' ) - 90.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = r-status exp = 'READY' ).
    claim-expense_date = claim-expense_date - 1.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'LATE_CLAIM' ] ) ) ).
  ENDMETHOD.
  METHOD missing_receipt.
    CLEAR claim-receipt_reference.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'RECEIPT' ] ) ) ).
  ENDMETHOD.
  METHOD duplicate_claim.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' duplicate = abap_true ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'DUPLICATE' ] ) ) ).
  ENDMETHOD.
  METHOD unsupported_currency.
    claim-currency = 'USD'.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'CURRENCY' ] ) ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( r-issues[ code = 'OVER_LIMIT' ] ) ) ).
  ENDMETHOD.
  METHOD category_caps.
    claim-category = 'TRAVEL'. claim-amount = 5000.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = r-status exp = 'READY' ).
    claim-category = 'HOTEL'. claim-amount = '8000.01'.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'OVER_LIMIT' ] ) ) ).
    claim-category = 'OFFICE'. claim-amount = '2000.01'.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'OVER_LIMIT' ] ) ) ).
    claim-category = 'OTHER'.
    r = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( r-issues[ code = 'CATEGORY' ] ) ) ).
  ENDMETHOD.
  METHOD invalid_dates.
    cl_abap_unit_assert=>assert_false( zcl_ind10_expense_rules=>valid_date( '20260229' ) ).
    cl_abap_unit_assert=>assert_true( zcl_ind10_expense_rules=>valid_date( '20240229' ) ).
    cl_abap_unit_assert=>assert_false( zcl_ind10_expense_rules=>valid_date( '19000229' ) ).
    cl_abap_unit_assert=>assert_true( zcl_ind10_expense_rules=>valid_date( '20000229' ) ).
    cl_abap_unit_assert=>assert_false( zcl_ind10_expense_rules=>valid_date( '20260431' ) ).
    cl_abap_unit_assert=>assert_false( zcl_ind10_expense_rules=>valid_date( '00000000' ) ).
    cl_abap_unit_assert=>assert_false( zcl_ind10_expense_rules=>valid_date( '20261301' ) ).
  ENDMETHOD.
  METHOD mandatory_fields.
    CLEAR: claim-claim_id, claim-employee_id, claim-merchant, claim-expense_date.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' ).
    cl_abap_unit_assert=>assert_equals( act = lines( r-issues ) exp = 4 ).
  ENDMETHOD.
  METHOD multiple_reasons.
    claim-amount = 1200. CLEAR claim-receipt_reference.
    DATA(r) = zcl_ind10_expense_rules=>assess( claim = claim today = '20261015' duplicate = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lines( r-issues ) exp = 3 ).
    cl_abap_unit_assert=>assert_true( xsdbool( r-summary CS 'exceeds' AND r-summary CS 'missing' AND r-summary CS 'duplicate' ) ).
  ENDMETHOD.
ENDCLASS.
