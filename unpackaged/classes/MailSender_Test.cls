@isTest
public with sharing class MailSender_Test {
@isTest static void sendEmailTest(){
       Test.startTest();
       Test.setMock(HttpCalloutMock.class,new MailSenderMock_Test());
       MailSender.sendEmail('','','');
       Test.stopTest();
  } 
}