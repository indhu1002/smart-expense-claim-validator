@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: 'Smart Expense Claims'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZZExpenseI10', 
  Semantickey: [ 'ClaimID' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZZC_CLAIMI10
  provider contract TRANSACTIONAL_QUERY
  as projection on ZZR_CLAIMI10
  association [1..1] to ZZR_CLAIMI10 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ClaimID,
  EmployeeID,
  EmployeeName,
  ExpenseDate,
  Category,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  Amount,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  Currency,
  Merchant,
  ReceiptReference,
  Description,
  Status,
  ValidationMessage,
  Criticality,
  @Semantics: {
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}
