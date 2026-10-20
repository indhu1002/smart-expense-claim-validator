@EndUserText: {
  label: 'Service Definition for ZZC_CLAIMI10'
}
@ObjectModel: {
  leadingEntity: {
    name: 'ZZC_CLAIMI10'
  }
}
define service ZZUI_EXPENSE_O4I10 provider contracts odata_v4_ui {
  expose ZZC_CLAIMI10 as Claim;
}
