@EndUserText.label : 'Expense project reviewer assignments'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #C
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zind10_reviewer {
  key client : abap.clnt not null;
  key user_id : abp_creation_user not null;
  active : abap.char(1);
}
