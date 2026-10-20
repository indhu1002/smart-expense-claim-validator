@EndUserText.label: 'ZZC_CLAIMI10'
@MappingRole: true
define role ZZC_CLAIMI10 {
  grant select on ZZC_CLAIMI10
  where INHERITING CONDITIONS FROM ENTITY ZZR_CLAIMI10 REPLACING { ROOT WITH _BaseEntity };
}
