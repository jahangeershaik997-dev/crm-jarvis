var ISFFormNamespace = ISFFormNamespace || {};
ISFFormNamespace.DealDirectorFilter = {
    onFormLoad: function() {
        console.log("ISF Form Load: Initializing Deal Director filter");
        ISFFormNamespace.DealDirectorFilter.applyDealDirectorFilter();
    },
    applyDealDirectorFilter: function() {
        try {
            var dealLookup = Xrm.Page.getAttribute("trial_deal").getValue();
            if (!dealLookup || dealLookup.length === 0) {
                console.warn("No deal selected. Cannot filter Deal Director.");
                return;
            }
            var dealId = dealLookup[0].id;
            var fetchXml = "<fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'><entity name='trial_dealteammember'><attribute name='trial_dealteammemberid'/><attribute name='trial_dtmname'/><attribute name='trial_membername'/><order attribute='trial_dtmname' descending='false'/><filter type='and'><condition attribute='trial_deal' operator='eq' value='" + dealId + "'/><condition attribute='trial_status' operator='eq' value='100000000'/></filter></entity></fetch>";
            var dealDirectorControl = Xrm.Page.getControl("trial_dealdirector");
            if (dealDirectorControl) {
                dealDirectorControl.addPreSearch(function() {
                    dealDirectorControl.addCustomFilter(fetchXml, "trial_dealteammember");
                });
                console.log("Deal Director filter applied successfully");
            }
        } catch (error) {
            console.error("Error in applyDealDirectorFilter: " + error.message);
        }
    },
    onDealChange: function() {
        console.log("Deal field changed: Refreshing Deal Director filter");
        ISFFormNamespace.DealDirectorFilter.applyDealDirectorFilter();
    }
};
function ISFForm_OnLoad(executionContext) {
    var formContext = executionContext.getFormContext();
    ISFFormNamespace.DealDirectorFilter.onFormLoad();
    formContext.getAttribute("trial_deal").addOnChange(function() {
        ISFFormNamespace.DealDirectorFilter.onDealChange();
    });
}
