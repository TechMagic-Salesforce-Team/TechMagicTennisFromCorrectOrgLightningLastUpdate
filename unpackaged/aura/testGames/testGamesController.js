({
    myAction: function (component, event, helper) {
        var x = document.getElementById("snackbar")
        x.className = "show";
        setTimeout(function(){
            x.className = x.className.replace("show", "");
            location.reload();},
            2000);
    }
});