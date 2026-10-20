CLASS ltc_access DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creator_can_edit FOR TESTING.
    METHODS outsider_denied FOR TESTING.
    METHODS reviewer_other_claim FOR TESTING.
    METHODS no_self_review FOR TESTING.
    METHODS approved_is_final FOR TESTING.
    METHODS no_repeat_approval FOR TESTING.
    METHODS draft_not_reviewable FOR TESTING.
    METHODS missing_owner_denied FOR TESTING.
    METHODS anonymous_denied FOR TESTING.
    METHODS rejected_can_resubmit FOR TESTING.
    METHODS no_review_rejected FOR TESTING.
    METHODS unknown_state_denied FOR TESTING.
ENDCLASS.
CLASS ltc_access IMPLEMENTATION.
  METHOD creator_can_edit.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'CREATOR' owner = 'CREATOR'
      reviewer = abap_false status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD outsider_denied.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'OTHER' owner = 'CREATOR'
      reviewer = abap_false status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD reviewer_other_claim.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'CREATOR'
      reviewer = abap_true status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_true ).
  ENDMETHOD.
  METHOD no_self_review.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'REVIEWER'
      reviewer = abap_true status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD approved_is_final.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'CREATOR' owner = 'CREATOR'
      reviewer = abap_true status = 'APPROVED' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD no_repeat_approval.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'CREATOR'
      reviewer = abap_true status = 'APPROVED' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD draft_not_reviewable.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'CREATOR'
      reviewer = abap_true status = 'READY' is_draft = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD missing_owner_denied.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = ''
      reviewer = abap_true status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD anonymous_denied.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = '' owner = 'CREATOR'
      reviewer = abap_true status = 'READY' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD rejected_can_resubmit.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'CREATOR' owner = 'CREATOR'
      reviewer = abap_false status = 'REJECTED' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD no_review_rejected.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'CREATOR'
      reviewer = abap_true status = 'REJECTED' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
  METHOD unknown_state_denied.
    DATA(p) = zcl_ind10_exp_access=>decide( actor = 'REVIEWER' owner = 'CREATOR'
      reviewer = abap_true status = 'UNKNOWN' is_draft = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-edit exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = p-review exp = abap_false ).
  ENDMETHOD.
ENDCLASS.
