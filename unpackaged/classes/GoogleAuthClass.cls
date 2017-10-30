public with sharing class GoogleAuthClass extends PlayerCookie{
public string authtoken{get;set;}
public string refereshtoken{get;set;}
public string bodyprint{get;set;}
public String accessToken {get;set;}

//Settings needed on the google cloud console.One can store this securely in custom settings or an object.

public static final String CLIENT_SECRET='SC7TfzRMa7j-thVao7qttwt5';//Fill as per your registered app settings in google console
public static final String CLIENT_ID='60522812757-lkbn4amj4epn71vnimk09hs6lh7lp7fs.apps.googleusercontent.com';//Fill as per your registered app settings in google console
//public static string REDIRECT_URL='https://ap1.salesforce.com/apex/GoogleAuthPage';
//public static final string REDIRECT_URL =  'https://techmagic-table-tennis-developer-edition.eu11.force.com/GoogleAuthPage';

          
public static String REDIRECT_URL {get{
        REDIRECT_URL = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/GoogleAuthPage';
        return REDIRECT_URL;
    }
set;}

           

public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';

public static final string GRANT_TYPE='grant_type=authorization_code';

//Scope URL as per oauth 2.0 guide of the google 
public static final string SCOPE='https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile';
public static final string STATE='/profile';

//Approval Prompt Constant
public static final string APPROVAL_PROMPT='force';
public PlayerFromGoogleApiAccessToken playerFromGoogleByToken {get;set;}
public PlayerAccessToken playerToken {get;set;}    

public class PlayerFromGoogleApiAccessToken {
     public String id {get;set;}
     public String email {get;set;}
     public Boolean verified_email {get;set;}
     public String name {get;set;}
     public String given_name {get;set;}
     public String family_name {get;set;}
     public String link {get;set;}
     public String picture {get;set;}  
     public String gender {get;set;}  
     public String locale {get;set;}  
}
    
public class PlayerAccessToken {
    public String access_token {get;set;}
    public String expires_in {get;set;}
    public String id_token {get;set;}
    public String token_type {get;set;}
}
    
    public GoogleAuthClass(){}
    
    

   public pagereference connect(){
     String x=OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(SCOPE,'UTF-8')+'&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+'&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;
     pagereference p=new pagereference(x);
     return p;
   }
   
        
   public pagereference showtoken(){
   string codeparam=apexpages.currentpage().getparameters().get('code');
   if (codeparam==null) return null;
    System.debug('codeparam: '+codeparam);     
    
    HttpResponse res = signInRequest(codeparam);
    system.debug('body'+res.getbody());
    playerToken = (PlayerAccessToken)JSON.deserialize(res.getbody(), PlayerAccessToken.class);
    accessToken = playerToken.access_token;
    bodyprint=res.getbody()+'\r\naccessToken: '+accessToken;
    
    playerFromGoogleByToken = 
        (PlayerFromGoogleApiAccessToken) JSON.deserialize(signInGmailPlayer(accessToken),PlayerFromGoogleApiAccessToken.class);
        
    insertPlayerFromGoogleAccountIfNotExists(playerFromGoogleByToken);    
    return Page.Home;
   }
    
   public HttpResponse signInRequest(String codeparam){
        // Instantiate a new http object
    Http h = new Http();
    
    String body='code='+codeparam+'&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&redirect_uri='+REDIRECT_URL+'&'+GRANT_TYPE;
    System.debug('CODEPARAM: '+codeparam);     
    
    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(OAUTH_TOKEN_URL);
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setMethod('POST');
    req.setBody(body);
    
    system.debug('REQUEST BODY'+body);

    // Send the request, and return a response
    HttpResponse res = h.send(req);
    return res;    
   }
   
   
   public static String signInGmailPlayer(String accessToken){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndpoint('https://www.googleapis.com/oauth2/v1/userinfo?access_token='+accessToken);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        request.setHeader('Host', 'www.googleapis.com');
        request.setMethod('GET');
        response = http.send(request);
        //System.debug('My response: '+response.getBody());
        return response.getBody();
    }
    
    public void insertPlayerFromGoogleAccountIfNotExists(PlayerFromGoogleApiAccessToken playerFromGoogleApiJSON){
        System.debug('PAGE LARGE LOOKUP: '+URL.getSalesforceBaseUrl());
        try {
             Player__c player = [select Id from Player__c where Email__c =: playerFromGoogleApiJSON.email];
             Cookie playerFromCookie = new Cookie('PlayerFromCookie', player.Id, null, 7*86000, false);
             ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
        } catch(QueryException queryException){
            Player__c player = new Player__c();
            player.Name = playerFromGoogleApiJSON.name;
            player.Email__c = playerFromGoogleApiJSON.email;
            player.Password__c = '12345678';
            player.Status__c = 'Active';
            try {
                insert player;
                Cookie playerFromCookie = new Cookie('PlayerFromCookie', player.Id, null, 7*86000, false);
                ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
            } catch (DmlException dmlException){
                System.debug('En error occured while inserting player');
            }
        } catch (NullPointerException nullPointerException){
            System.debug('NullPointerException occurred');
        }
    }
}