({
	retrieveAppointments : function(component) {
		console.log('helper retrieveAppointments started...');
        var action = component.get("c.getAppointments");
        action.setParams({
            "view": component.get("v.view")
        });
        
        //Set up the callback
        var self = this;
        action.setCallback(this, function(a) {
            console.log('query callback!');
            console.log(a.getReturnValue());
            component.set("v.data", JSON.parse(a.getReturnValue()));
            
            var recs = component.get("v.data");
            if (recs == null || recs.length <= 0) {
                if (component.get("v.view") == 'Today')
                {
                    component.set('v.msg', 'There are no appointments for today');
                }
                else
                {
                    component.set('v.msg', 'There are no upcoming appointments');
                }
                /*
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "message": "Search returned zero results.",
                    "duration": 2000,
                    "type": "warning"
                });
                toastEvent.fire();
                */
            } else {
                
            }
            
        });
        $A.enqueueAction(action);
	}
})