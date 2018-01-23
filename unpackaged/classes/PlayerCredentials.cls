@RestResource(urlMapping='/players/credentials/*')
global class PlayerCredentials {

    @HttpGet
    global static String doGet(){
        RestRequest req = RestContext.request;
        
        String email = req.params.get('email');
        String password = req.params.get('password');
        
        String userId = req.headers.get('From');
       
        
        List<User> users = [select Id from User where Id =: userId];
        
        if (users.size() > 0) {
            List<Player__c> players = [select Id, Name, IsManager__c, Password__c, Image__c from Player__c where Email__c =:email];
            if (players.size() > 0) {
                if (players.get(0).Password__c.equals(password)) {
                    return JSON.serialize(players.get(0)).replaceAll('"','\'');
                } else {
                    return '{\'message\':\'wrong password\'}';
                }
            }
        }
        return '{\'message\':\'wrong email\'}';
    }

}