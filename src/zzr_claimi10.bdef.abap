managed implementation in class ZZBP_R_CLAIMI10 unique;
strict ( 2 );
with draft;
extensible;
define behavior for ZZR_CLAIMI10 alias Claim
persistent table ZZCLAIMI10
extensible
draft table ZZCLAIM_DI10
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master ( global, instance )
{
  field ( readonly )
   UUID,
   LocalCreatedBy,
   LocalCreatedAt,
   LocalLastChangedBy,
   LocalLastChangedAt,
   LastChangedAt,
   Status, ValidationMessage, Criticality;

  field ( numbering : managed )
   UUID;


  create;
  update ( features : instance );
  delete ( features : instance );

  draft action Activate optimized;
  draft action Discard;
  draft action ( features : instance ) Edit;
  draft action Resume;
  draft determine action Prepare { determination AssessOnSave; }

  determination ResetReview on modify { create; field ClaimID, EmployeeID, EmployeeName, ExpenseDate, Category, Amount, Currency, Merchant, ReceiptReference, Description; }
  determination AssessOnSave on save { create; field ClaimID, EmployeeID, ExpenseDate, Category, Amount, Currency, Merchant, ReceiptReference; }
  action ( features : instance ) Validate result [1] $self;
  action ( features : instance ) Approve result [1] $self;
  action ( features : instance ) Reject result [1] $self;
  side effects {
    action Validate affects $self;
    action Approve affects $self;
    action Reject affects $self;
  }

  mapping for ZZCLAIMI10 corresponding extensible
  {
    UUID = UUID;
    ClaimID = CLAIM_ID;
    EmployeeID = EMPLOYEE_ID;
    EmployeeName = EMPLOYEE_NAME;
    ExpenseDate = EXPENSE_DATE;
    Category = CATEGORY;
    Amount = AMOUNT;
    Currency = CURRENCY;
    Merchant = MERCHANT;
    ReceiptReference = RECEIPT_REFERENCE;
    Description = DESCRIPTION;
    Status = STATUS;
    ValidationMessage = VALIDATION_MESSAGE;
    Criticality = CRITICALITY;
    LocalCreatedBy = LOCAL_CREATED_BY;
    LocalCreatedAt = LOCAL_CREATED_AT;
    LocalLastChangedBy = LOCAL_LAST_CHANGED_BY;
    LocalLastChangedAt = LOCAL_LAST_CHANGED_AT;
    LastChangedAt = LAST_CHANGED_AT;
  }

}
