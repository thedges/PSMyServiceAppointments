({
   doInit: function(component, event, helper) {
        console.log("doInit called");
      
        component.set('v.columnDefs', [
                {label: 'Start Time', fieldName: 'schedStartTime', type: 'text'},
                {label: 'Work Type', fieldName: 'workType', type: 'text'},
                {label: 'Status', fieldName: 'status', type: 'text'},
                {label: 'Appointment', fieldName: 'saLink', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'saNum' }
                  }},
                {label: 'Work Order', fieldName: 'woLink', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'woNum' }
                }},
                {label: 'Account', fieldName: 'accountLink', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'accountName' }
                }},
                {label: 'Contact', fieldName: 'contactLink', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'contactName' }
                }},
                {label: 'Address', fieldName: 'address', type: 'text'}
            ]);

        helper.retrieveAppointments(component);
    },
    onViewChange : function(component, event, helper) {
      var selected = component.find("view").get("v.value");
      component.set('v.msg', '');
      console.log('view='+selected);
        
      helper.retrieveAppointments(component);
    }
})