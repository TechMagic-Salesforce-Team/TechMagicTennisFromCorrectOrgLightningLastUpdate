/**
 * Created by rostyk_haidukevych on 10/20/17.
 */
public class HerokuToken {
    public static final String tokenHeroku = 'ASDYQW127BFYWEBCAQWUQWNCE38ASDNCNUEO12';

    public static String JSONFormatEmails(Set<String>emails, String subject, String htmlText){
        Emails emailsMainClass = new Emails();
        List<EmailJSON> emailsJson = new List<EmailJSON>();
        for (String email:emails){
            emailsJson.add(new EmailJSON(email, subject, htmlText));
        }
        emailsMainClass.emails = emailsJson;
        emailsMainClass.token = HerokuToken.tokenHeroku;
        return JSON.serialize(emailsMainClass);
    }


    public static String JSONFormatEmails(String currentEmail, String subject, String htmlText){
        Emails emailsMainClass = new Emails();
        List<EmailJSON> emailsJson = new List<EmailJSON>();
        emailsJson.add(new EmailJSON(currentEmail, subject, htmlText));
        emailsMainClass.emails = emailsJson;
        emailsMainClass.token = HerokuToken.tokenHeroku;
        return JSON.serialize(emailsMainClass);
    }


    class Emails {
        List<EmailJSON> emails;
        String token;
    }

    class EmailJSON {
        private String to;
        private String subject;
        private String html;
        private EmailJSON(String to, String subject, String html){
            this.to = to; this.subject = subject; this.html = html;
        }
    }
}