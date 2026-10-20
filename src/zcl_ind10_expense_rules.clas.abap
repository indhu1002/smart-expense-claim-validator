CLASS zcl_ind10_expense_rules DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_claim,
             claim_id TYPE c LENGTH 12,
             employee_id TYPE c LENGTH 12,
             expense_date TYPE d,
             category TYPE c LENGTH 10,
             amount TYPE p LENGTH 7 DECIMALS 2,
             currency TYPE c LENGTH 5,
             merchant TYPE c LENGTH 60,
             receipt_reference TYPE c LENGTH 40,
           END OF ty_claim,
           BEGIN OF ty_issue,
             code TYPE c LENGTH 20,
             text TYPE string,
           END OF ty_issue,
           tt_issues TYPE STANDARD TABLE OF ty_issue WITH EMPTY KEY,
           BEGIN OF ty_result,
             status TYPE c LENGTH 10,
             criticality TYPE i,
             summary TYPE c LENGTH 255,
             issues TYPE tt_issues,
           END OF ty_result.
    CLASS-METHODS assess
      IMPORTING claim TYPE ty_claim today TYPE d
                duplicate TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(result) TYPE ty_result.
    CLASS-METHODS valid_date
      IMPORTING value TYPE d RETURNING VALUE(valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_ind10_expense_rules IMPLEMENTATION.
  METHOD valid_date.
    IF value IS INITIAL OR value CN '0123456789'.
      RETURN.
    ENDIF.
    DATA(year) = CONV i( value(4) ).
    DATA(month) = CONV i( value+4(2) ).
    DATA(day) = CONV i( value+6(2) ).
    IF year < 1 OR month < 1 OR month > 12 OR day < 1.
      RETURN.
    ENDIF.
    DATA(days) = 31.
    CASE month.
      WHEN 4 OR 6 OR 9 OR 11. days = 30.
      WHEN 2.
        days = 28.
        IF year MOD 400 = 0 OR ( year MOD 4 = 0 AND year MOD 100 <> 0 ).
          days = 29.
        ENDIF.
    ENDCASE.
    valid = xsdbool( day <= days ).
  ENDMETHOD.

  METHOD assess.
    "Illustrative INR policy for a learning project; each call is deterministic.
    IF claim-claim_id IS INITIAL.
      APPEND VALUE #( code = 'CLAIM_ID' text = 'Enter a claim ID' ) TO result-issues.
    ENDIF.
    IF claim-employee_id IS INITIAL.
      APPEND VALUE #( code = 'EMPLOYEE' text = 'Enter an employee ID' ) TO result-issues.
    ENDIF.
    IF valid_date( claim-expense_date ) = abap_false.
      APPEND VALUE #( code = 'DATE' text = 'Enter a valid expense date' ) TO result-issues.
    ELSEIF claim-expense_date > today.
      APPEND VALUE #( code = 'FUTURE_DATE' text = 'Expense date is in the future' ) TO result-issues.
    ELSEIF today - claim-expense_date > 90.
      APPEND VALUE #( code = 'LATE_CLAIM' text = 'Expense is older than 90 days' ) TO result-issues.
    ENDIF.
    IF claim-amount <= 0.
      APPEND VALUE #( code = 'AMOUNT' text = 'Amount must be greater than zero' ) TO result-issues.
    ENDIF.
    IF to_upper( claim-currency ) <> 'INR'.
      APPEND VALUE #( code = 'CURRENCY' text = 'This demo accepts INR only' ) TO result-issues.
    ENDIF.
    DATA cap TYPE p LENGTH 7 DECIMALS 2.
    CASE to_upper( claim-category ).
      WHEN 'MEALS'. cap = 1000.
      WHEN 'TRAVEL'. cap = 5000.
      WHEN 'HOTEL'. cap = 8000.
      WHEN 'OFFICE'. cap = 2000.
      WHEN OTHERS.
        APPEND VALUE #( code = 'CATEGORY' text = 'Use MEALS, TRAVEL, HOTEL or OFFICE' ) TO result-issues.
    ENDCASE.
    IF cap > 0 AND claim-amount > cap AND to_upper( claim-currency ) = 'INR'.
      APPEND VALUE #( code = 'OVER_LIMIT' text = |{ to_upper( claim-category ) } exceeds INR { cap NUMBER = RAW }| ) TO result-issues.
    ENDIF.
    IF claim-merchant IS INITIAL.
      APPEND VALUE #( code = 'MERCHANT' text = 'Enter the merchant name' ) TO result-issues.
    ENDIF.
    IF claim-receipt_reference IS INITIAL.
      APPEND VALUE #( code = 'RECEIPT' text = 'Receipt reference is missing' ) TO result-issues.
    ENDIF.
    IF duplicate = abap_true.
      APPEND VALUE #( code = 'DUPLICATE' text = 'Possible duplicate claim or receipt' ) TO result-issues.
    ENDIF.
    IF result-issues IS INITIAL.
      result-status = 'READY'.
      result-criticality = 3.
      result-summary = 'All policy checks passed'.
    ELSE.
      result-status = 'FLAGGED'.
      result-criticality = 1.
      DATA summary TYPE string.
      LOOP AT result-issues INTO DATA(issue).
        summary = COND #( WHEN summary IS INITIAL THEN issue-text
                          ELSE |{ summary }; { issue-text }| ).
      ENDLOOP.
      result-summary = summary.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
