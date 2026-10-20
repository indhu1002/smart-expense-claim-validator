@EndUserText.label : 'Database Table for ZZCLAIMI10'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zzclaimi10 {

  key client            : abap.clnt not null;
  key uuid              : sysuuid_x16 not null;
  claim_id              : abap.char(12);
  employee_id           : abap.char(12);
  employee_name         : abap.char(60);
  expense_date          : abap.datn;
  category              : abap.char(10);
  @Semantics.amount.currencyCode : 'zzclaimi10.currency'
  amount                : abap.curr(13,2);
  currency              : abap.cuky;
  merchant              : abap.char(60);
  receipt_reference     : abap.char(40);
  description           : abap.char(120);
  status                : abap.char(10);
  validation_message    : abap.char(255);
  criticality           : abap.int1;
  local_created_by      : abp_creation_user;
  local_created_at      : abp_creation_tstmpl;
  local_last_changed_by : abp_locinst_lastchange_user;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
  last_changed_at       : abp_lastchange_tstmpl;

}
