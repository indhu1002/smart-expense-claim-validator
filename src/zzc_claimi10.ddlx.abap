@Metadata.layer: #CORE
@UI.headerInfo: {
  typeName: 'Expense Claim', typeNamePlural: 'Smart Expense Claims',
  title: { type: #STANDARD, value: 'ClaimID' },
  description: { type: #STANDARD, value: 'EmployeeName' }
}
annotate view ZZC_CLAIMI10 with
{
  @UI.hidden: true
  UUID;

  @UI.facet: [
    { id: 'Claim', label: 'Expense details', type: #FIELDGROUP_REFERENCE, targetQualifier: 'Claim', position: 10 },
    { id: 'Receipt', label: 'Receipt and purpose', type: #FIELDGROUP_REFERENCE, targetQualifier: 'Receipt', position: 20 },
    { id: 'Checks', label: 'Policy checks', type: #FIELDGROUP_REFERENCE, targetQualifier: 'Checks', position: 30 },
    { id: 'Audit', label: 'Audit information', type: #FIELDGROUP_REFERENCE, targetQualifier: 'Audit', position: 40 }
  ]
  @EndUserText.label: 'Claim ID'
  @UI.lineItem: [{ position: 10 }]
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 10 }]
  @UI.selectionField: [{ position: 10 }]
  ClaimID;

  @EndUserText.label: 'Employee ID'
  @UI.lineItem: [{ position: 20 }]
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 20 }]
  @UI.selectionField: [{ position: 20 }]
  EmployeeID;

  @EndUserText.label: 'Employee name'
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 30 }]
  EmployeeName;

  @EndUserText.label: 'Expense date'
  @UI.lineItem: [{ position: 30 }]
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 40 }]
  @UI.selectionField: [{ position: 30 }]
  ExpenseDate;

  @EndUserText.label: 'Category: MEALS/TRAVEL/HOTEL/OFFICE'
  @UI.lineItem: [{ position: 40, label: 'Category' }]
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 50 }]
  @UI.selectionField: [{ position: 40 }]
  Category;

  @EndUserText.label: 'Amount'
  @UI.lineItem: [{ position: 50 }]
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 60 }]
  Amount;

  @EndUserText.label: 'Currency (INR)'
  @UI.fieldGroup: [{ qualifier: 'Claim', position: 70 }]
  Currency;

  @EndUserText.label: 'Merchant'
  @UI.lineItem: [{ position: 60 }]
  @UI.fieldGroup: [{ qualifier: 'Receipt', position: 10 }]
  Merchant;

  @EndUserText.label: 'Receipt reference'
  @UI.fieldGroup: [{ qualifier: 'Receipt', position: 20 }]
  ReceiptReference;

  @EndUserText.label: 'Business purpose'
  @UI.multiLineText: true
  @UI.fieldGroup: [{ qualifier: 'Receipt', position: 30 }]
  Description;

  @EndUserText.label: 'Review status'
  @UI.lineItem: [
    { position: 70, criticality: 'Criticality' },
    { type: #FOR_ACTION, dataAction: 'Validate', label: 'Validate claim', position: 100 },
    { type: #FOR_ACTION, dataAction: 'Approve', label: 'Approve', position: 110 },
    { type: #FOR_ACTION, dataAction: 'Reject', label: 'Reject', position: 120 }
  ]
  @UI.identification: [
    { type: #FOR_ACTION, dataAction: 'Validate', label: 'Validate claim', position: 10 },
    { type: #FOR_ACTION, dataAction: 'Approve', label: 'Approve', position: 20 },
    { type: #FOR_ACTION, dataAction: 'Reject', label: 'Reject', position: 30 }
  ]
  @UI.fieldGroup: [{ qualifier: 'Checks', position: 10, criticality: 'Criticality' }]
  @UI.selectionField: [{ position: 50 }]
  Status;

  @EndUserText.label: 'Validation explanation'
  @UI.lineItem: [{ position: 80 }]
  @UI.multiLineText: true
  @UI.fieldGroup: [{ qualifier: 'Checks', position: 20 }]
  ValidationMessage;

  @UI.hidden: true
  Criticality;
  @EndUserText.label: 'Created by'
  @UI.fieldGroup: [{ qualifier: 'Audit', position: 10 }]
  LocalCreatedBy;
  @EndUserText.label: 'Created at'
  @UI.fieldGroup: [{ qualifier: 'Audit', position: 20 }]
  LocalCreatedAt;
  @EndUserText.label: 'Last changed by'
  @UI.fieldGroup: [{ qualifier: 'Audit', position: 30 }]
  LocalLastChangedBy;
  @EndUserText.label: 'Last changed at'
  @UI.fieldGroup: [{ qualifier: 'Audit', position: 40 }]
  LocalLastChangedAt;
  @UI.hidden: true
  LastChangedAt;
}
