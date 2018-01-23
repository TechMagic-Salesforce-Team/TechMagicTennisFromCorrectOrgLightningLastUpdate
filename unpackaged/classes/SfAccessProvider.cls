@RestResource(urlMapping='/sf_acess/*')
global class SfAccessProvider{

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String value =  (UserInfo.getUserId()+UserInfo.getSessionId());
        String access_token_fs = value.SubString(15,value.length());
        return '{ "access_token" : "'+access_token_fs+'"}';
    }

}