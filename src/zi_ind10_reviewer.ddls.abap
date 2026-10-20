@EndUserText.label: 'Expense reviewer membership - internal'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_IND10_REVIEWER as select from zind10_reviewer
{
  key user_id as UserID
}
where active = 'X'
