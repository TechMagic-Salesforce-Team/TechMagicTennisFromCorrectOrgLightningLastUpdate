({
	handleFindPlayers : function(component, event, helper) {        
		var player = event.getParam("player");
        helper.getPlayersByInputFunc(component, event, player);
	},
  	
    doInit: function(component, event, helper){
	    console.log('init');
        helper.getPlayersByInputFunc(component, event, null);
    },
})