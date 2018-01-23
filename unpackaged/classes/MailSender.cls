public with sharing class MailSender {
    public static void sendEmail(String to, String subject , String text){
        string sBody = '';
        System.debug('Send email from send email');
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setEndPoint('http://env-4569822.jelastic.saveincloud.net/sendEmail');
        request.setMethod('POST');
        sBody = '&emailTo='+to +'&subject='+subject+'&body='+text;
        System.debug('REQUEST: '+request);
        request.setBody(sBody);
        response = http.send(request);
        system.debug(response.getBody());
        //request.setHeader('Accept-Language', string.valueOf(sBody.length()));
        system.debug(response.getStatusCode());
    }


    public static void sendEmailJSON(String to, String subject, String text){
        string sBody = '';
        System.debug('Send email from send email');
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setEndPoint('http://tomcat-techmagic-servletmail.1d35.starter-us-east-1.openshiftapps.com/email/send');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        Emails emailsSend = new Emails();
        List<EmailJSON> emailJSONS = new List<EmailJSON>();
        EmailJSON emailToSend = new EmailJSON();
        emailToSend.to = to;
        emailToSend.subject = subject;
        emailToSend.html = text;
        emailJSONS.add(emailToSend);
        emailsSend.token = 'ASDYQW127BFYWEBCAQWUQWNCE38ASDNCNUEO12';
        emailsSend.emails = emailJSONS;
        request.setBody(JSON.serialize(emailsSend));
        System.debug(JSON.serialize(emailsSend));
        System.debug('REQUEST: '+request.getBody());
        response = http.send(request);
        system.debug(response.getBody());
    }


    public static void sendEmailJSON(String emailsJSON){
        System.debug('Send email from send email');
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setEndPoint('http://tomcat-techmagic-servletmail.1d35.starter-us-east-1.openshiftapps.com/email/send');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody(emailsJSON);
        System.debug(emailsJSON);
        System.debug('REQUEST: '+request.getBody());
        response = http.send(request);
        system.debug(response.getBody());
    }


    class Emails {
            List<EmailJSON> emails;
            String token;
    }
    
    class EmailJSON {
        private String to;
        private String subject;
        private String html;
    }
}