@isTest
private class GoogleAuth_Test {
    public static testMethod void showTokenTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpSignInWithGoogle());
        
        GoogleAuthClass googleAuth = new GoogleAuthClass();
        googleAuth.connect();
        HttpResponse response = googleAuth.signInRequest('4/S9AJ9SV7TMPv4nbWq1v_H4rObmh9QvAKVkifnEzzg4A#');
        System.assertNotEquals(response,null);
        
        googleAuth.playerToken = null;
        googleAuth.playerFromGoogleByToken = null;
        
        googleAuth.playerToken = new GoogleAuthClass.PlayerAccessToken();
        googleAuth.playerToken.access_token = 'access_token';
        googleAuth.playerToken.expires_in = 'expires_in';
        googleAuth.playerToken.id_token = 'id_token';
        googleAuth.playerToken.token_type = 'token_type';
        
        
        googleAuth.playerFromGoogleByToken = new GoogleAuthClass.PlayerFromGoogleApiAccessToken();
        googleAuth.playerFromGoogleByToken.id = 'id';
        googleAuth.playerFromGoogleByToken.email = 'email';
        googleAuth.playerFromGoogleByToken.verified_email = true;
        googleAuth.playerFromGoogleByToken.name = 'name';
        googleAuth.playerFromGoogleByToken.given_name = 'givenname';
        googleAuth.playerFromGoogleByToken.family_name = 'fname';
        googleAuth.playerFromGoogleByToken.link = 'link';
        googleAuth.playerFromGoogleByToken.picture = 'picture';
        googleAuth.playerFromGoogleByToken.gender = 'gender';
        googleAuth.playerFromGoogleByToken.locale = 'locale';
        
        googleAuth.authToken = 'authToken';
        googleAuth.refereshtoken = 'refereshtoken';
        googleAuth.bodyprint = 'bodyprint';
        googleAuth.accessToken = 'accessToken';
        
        
        
        System.assertEquals(response.getHeader('Content-Type'),'application/x-www-form-urlencoded');
        System.assertEquals(response.getStatusCode(),200);
        
        googleAuth.showtoken();
        
        GoogleAuthClass.signInGmailPlayer('accessToken');
        System.assertEquals(GoogleAuthClass.CLIENT_SECRET,'SC7TfzRMa7j-thVao7qttwt5');
        
        googleAuth.insertPlayerFromGoogleAccountIfNotExists(null);
        
        Player__c player = new Player__c();
        player.Name = 'Name';
        player.Email__c = 'email1@gmail.com';
        player.Password__c = '12345678';
       
        googleAuth.insertPlayerFromGoogleAccountIfNotExists(googleAuth.playerFromGoogleByToken);
        insert player;
        googleAuth.playerFromGoogleByToken.email = player.Email__c;
        googleAuth.insertPlayerFromGoogleAccountIfNotExists(googleAuth.playerFromGoogleByToken);
        
        googleAuth.playerFromGoogleByToken.email = 'googleAuth@email.com';
        googleAuth.insertPlayerFromGoogleAccountIfNotExists(googleAuth.playerFromGoogleByToken);
    }
}