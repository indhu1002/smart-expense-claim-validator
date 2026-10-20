# Setup guide

## 1. Prepare the ABAP system

Use an SAP BTP ABAP environment with an authorized development user and ABAP Development Tools. The original project was developed using SAP's ABAP extension for VS Code.

The snapshots use package `ZIND10_EXPENSE` and custom object names containing `IND10` / `I10`. Reuse them only where they do not conflict with existing objects. Renaming requires updating the related source references and UI manifest.

## 2. Create the data and policy objects

Create the matching object types in ADT and apply their source:

1. `ZZCLAIMI10`: persistent expense table.
2. `ZZCLAIM_DI10`: draft table.
3. `ZIND10_REVIEWER`: project reviewer membership table.
4. `ZI_IND10_REVIEWER`: internal membership view.
5. `ZCL_IND10_EXPENSE_RULES`: policy engine.
6. `ZCL_IND10_EXP_ACCESS`: role and ownership decisions.

Activate dependent objects together where necessary.

## 3. Create the RAP service

Create the root view `ZZR_CLAIMI10` and projection `ZZC_CLAIMI10`, their behavior definitions, corresponding behavior pools, CDS access controls, and metadata extension.

The behavior implementation belongs in `ZZBP_R_CLAIMI10` and its local implementation include. Do not omit the DCL sources or authorization handlers.

Create service definition `ZZUI_EXPENSE_O4I10`. Create an **OData V4 UI** service binding with the same name, activate and publish it, then verify its preview.

The exported `.srvb.xml` and IAM XML files document the original configuration. Recreate the objects through supported SAP tools; tenant-generated service identifiers and catalog assignment identifiers must be regenerated in the target system.

## 4. Configure claimant and reviewer access

Provision users in the hosting ABAP system and grant the required service/application access through the available SAP administration tools. Trial systems may restrict user administration.

Create/configure the IAM app and business catalog represented by `ZIND10_EXP_IAM_EXT`, `ZIND10_EXP_BC`, and the catalog assignment snapshot. Assign appropriate business access to the intended users.

Project-level review membership is additionally checked in `ZIND10_REVIEWER`. It does not replace SAP tenant/service authorization.

The internal setup class `ZCL_IND10_REVIEW_SETUP` contains a placeholder technical user ID, `CB0000000000`. An authorized administrator must verify the intended SAP technical user ID and replace the placeholder before using this class. Never derive reviewer privileges from a submitted claim, employee name, email input, or UI flag.

`ZCL_IND10_DEMO_RESET` also contains a placeholder identity guard and is only a read-only listing utility.

## 5. Build and deploy the frontend

Run `npm install` and `npm run build` from `fiori-ui/`.

Deploy the contents of `dist/` into UI5 repository `ZIND10_EXP_UI`, using the supported SAP UI5 deployment tooling available in your environment.

Check `fiori-ui/webapp/manifest.json`: its relative OData path must match the service binding in your target system. The original application path is:

```text
/sap/bc/ui5_ui5/sap/zind10_exp_ui/index.html?sap-client=100&sap-ui-language=EN
```

The UI bootstrap uses the hosting SAP system's UI5 resources. The logout link uses `/sap/public/bc/icf/logoff`; identity-provider session behavior depends on the hosting system.

## 6. Verify before demonstrating

Run the policy tests located in the local implementation include of `ZCL_IND10_EXPENSE_DEMO`, and the access tests in `ZCL_IND10_EXP_ACCESS`.

Check claim creation, owner visibility, assigned reviewer visibility, self-review rejection, policy failures, approval locking, and rejection/resubmission using provisioned accounts where available.

The older `ZCL_IND10_EXPENSE_DEMO` loader creates six claims owned by its executing user; that same user cannot review them under the current self-review rule. The twelve scenarios in `docs/demo-scenarios.json` describe the separately prepared development fixtures. No destructive reset script or personal claim backup is included in this repository.
