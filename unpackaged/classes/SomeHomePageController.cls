public with sharing class SomeHomePageController extends PlayerCookie{
    public String accessToken = 'ya29.GluKBHllg-lggwIADtjbFrWHlTmvgyUBzAK1s8wcQYegmvQWMaj69rblwLmyi8LI81EwAlKrwoc29bURP30x25x2FDxOapxb514Q8ubgt8u34qElYfWfUK38yi2y';
    public Url siteUrl {get;set;}
    public SomeHomePageController(){
       siteUrl = URL.getSalesforceBaseUrl();
    }
    
   public void httpGetGmailPlayerByAccessToken(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndpoint('https://www.googleapis.com/oauth2/v1/userinfo?access_token='+accessToken);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        request.setHeader('Host', 'www.googleapis.com');
        request.setMethod('GET');
        response = http.send(request);
        System.debug('My response: '+response);
    }
    
}