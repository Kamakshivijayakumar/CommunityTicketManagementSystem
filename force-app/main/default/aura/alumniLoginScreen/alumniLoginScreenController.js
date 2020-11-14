({
	doInit : function(component, event, helper) {
		var url = $A.get('$Resource.background');
        component.set('v.backgroundImageURL',url);
	}
})