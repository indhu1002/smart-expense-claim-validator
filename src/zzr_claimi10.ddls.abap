@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZZExpenseI10'
@EndUserText.label: 'Smart Expense Claims'
@ObjectModel.semanticKey: [ 'ClaimID' ]
define root view entity ZZR_CLAIMI10
  as select from ZZCLAIMI10 as Claim
  association [0..1] to ZI_IND10_REVIEWER as _Reviewer
    on _Reviewer.UserID = $session.user
{
  key uuid as UUID,
  claim_id as ClaimID,
  employee_id as EmployeeID,
  employee_name as EmployeeName,
  expense_date as ExpenseDate,
  category as Category,
  @Semantics.amount.currencyCode: 'Currency'
  amount as Amount,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  merchant as Merchant,
  receipt_reference as ReceiptReference,
  description as Description,
  status as Status,
  validation_message as ValidationMessage,
  criticality as Criticality,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  _Reviewer
}
