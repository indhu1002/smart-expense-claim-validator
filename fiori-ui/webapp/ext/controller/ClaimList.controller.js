sap.ui.define(["sap/ui/core/mvc/ControllerExtension"], function (ControllerExtension) {
  "use strict";

  return ControllerExtension.extend("zind10.expense.ext.controller.ClaimList", {
    override: {
      onAfterRendering: function () {
        // Fiori Elements sets this button to true in its list-report template.
        // Use the filter control's public setter, without DOM or ID manipulation.
        this.base.getView().findAggregatedObjects(true, function (control) {
          return control.isA("sap.ui.mdc.FilterBar");
        }).forEach(function (filterBar) {
          if (filterBar.getShowAdaptFiltersButton()) {
            filterBar.setShowAdaptFiltersButton(false);
          }
        });
      }
    }
  });
});
