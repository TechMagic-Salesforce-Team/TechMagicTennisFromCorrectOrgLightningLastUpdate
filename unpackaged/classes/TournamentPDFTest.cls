@isTest
public with sharing class TournamentPDFTest{

    public static testMethod void propertieTest(){
        Tournament__c myPDFTournament = new Tournament__c(Name ='PDF', Type__c='Single Elimination', Format__c = '1 x 1', StartDate__c = Datetime.now(), Status__c = 'Upcoming');
        insert myPDFTournament;
        ApexPages.currentPage().getHeaders().put('id', myPDFTournament.Id);
        
        TournamentPDF testPDFwrong = new TournamentPDF();
        Test.setCurrentPageReference(new PageReference('Page.TournamentPDF')); 
        System.currentPageReference().getParameters().put('id', myPDFTournament.Id);
        TournamentPDF testPDFright = new TournamentPDF();
        Map<String, String> competitorsMap = new Map<String, String>();
        competitorsMap = Helper.getIdAndNameMap(myPDFTournament);
    }
    
}