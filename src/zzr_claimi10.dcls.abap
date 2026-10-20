@EndUserText.label: 'ZZR_CLAIMI10'
@MappingRole: true
define role ZZR_CLAIMI10 {
  grant select on ZZR_CLAIMI10
  where LocalCreatedBy = $session.user OR _Reviewer.UserID = $session.user;
}
