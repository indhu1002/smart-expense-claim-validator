@EndUserText.label : 'Draft Database Table for ZZCLAIM_DI10'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zzclaim_di10 {

  key mandt          : mandt not null;
  key uuid           : sysuuid_x16 not null;
  claimid            : abap.char(12);
  employeeid         : abap.char(12);
  employeename       : abap.char(60);
  expensedate        : abap.datn;
  category           : abap.char(10);
  @Semantics.amount.currencyCode : 'zzclaim_di10.currency'
  amount             : abap.curr(13,2);
  currency           : abap.cuky;
  merchant           : abap.char(60);
  receiptreference   : abap.char(40);
  description        : abap.char(120);
  status             : abap.char(10);
  validationmessage  : abap.char(255);
  criticality        : abap.int1;
  localcreatedby     : abp_creation_user;
  localcreatedat     : abp_creation_tstmpl;
  locallastchangedby : abp_locinst_lastchange_user;
  locallastchangedat : abp_locinst_lastchange_tstmpl;
  lastchangedat      : abp_lastchange_tstmpl;
  "%admin"           : include sych_bdl_draft_admin_inc;

}
