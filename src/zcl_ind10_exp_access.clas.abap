CLASS zcl_ind10_exp_access DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_permissions,
             edit TYPE abap_bool,
             review TYPE abap_bool,
           END OF ty_permissions.
    CLASS-METHODS is_reviewer RETURNING VALUE(allowed) TYPE abap_bool.
    CLASS-METHODS decide IMPORTING actor TYPE string owner TYPE string
      reviewer TYPE abap_bool status TYPE string is_draft TYPE abap_bool
      RETURNING VALUE(permissions) TYPE ty_permissions.
ENDCLASS.
CLASS zcl_ind10_exp_access IMPLEMENTATION.
  METHOD is_reviewer.
    DATA(actor) = cl_abap_context_info=>get_user_technical_name( ).
    IF actor IS INITIAL. RETURN. ENDIF.
    SELECT SINGLE user_id FROM zind10_reviewer
      WHERE user_id = @actor AND active = 'X' INTO @DATA(reviewer).
    allowed = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
  METHOD decide.
    IF actor IS INITIAL. RETURN. ENDIF.
    permissions-edit = xsdbool( status <> 'APPROVED'
      AND ( actor = owner OR ( owner IS INITIAL AND is_draft = abap_true ) ) ).
    permissions-review = xsdbool( reviewer = abap_true AND owner IS NOT INITIAL
      AND owner <> actor AND is_draft = abap_false
      AND ( status = 'NEW' OR status = 'READY' OR status = 'FLAGGED' ) ).
  ENDMETHOD.
ENDCLASS.
