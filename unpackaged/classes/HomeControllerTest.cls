@isTest
public with sharing class HomeControllerTest{

    
    public static testMethod void getAllTournamentsInProgressTest(){
        HomeController firstController = new HomeController();
        Tournament__c thisTournament1 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament2 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament3 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament4 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Upcoming');
        Tournament__c thisTournament5 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 2', Type__c = 'Round Robin', Status__c = 'Upcoming');
        List<Tournament__c> thisTournamentList = new List<Tournament__c>(); 
        thisTournamentList.add(thisTournament1);
        thisTournamentList.add(thisTournament2);
        thisTournamentList.add(thisTournament3);
        thisTournamentList.add(thisTournament4);
        insert(thisTournamentList);
        HomeController thisHome = new HomeController();
        System.assertEquals(thisHome.tournamentsInProgress.size(),3);
        System.assertEquals(thisHome.tournamentBySelectOption, thisHome.tournamentsInProgress.get(0));
        System.assertEquals(thisHome.tournamentsInProgressSize , 3);
    }
    
    public static testMethod void propertiesTest(){
        Tournament__c thisTournament1 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament2 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament3 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament4 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Upcoming');
        List<Tournament__c> thisTournamentList = new List<Tournament__c>();
        thisTournamentList.add(thisTournament1);
        thisTournamentList.add(thisTournament2);
        thisTournamentList.add(thisTournament3);
        thisTournamentList.add(thisTournament4);
        insert(thisTournamentList);
        HomeController thisHome = new HomeController();
        System.assertEquals(null,thisHome.selectedTournamentType);
        System.assertEquals(null,thisHome.selectedTournamentFormat);
        System.assertEquals('',thisHome.selectedTournament);
        System.assertEquals(thisHome.tournamentTypeOptions.size(), 4);
        System.assertEquals(thisHome.tournamentFormatOptions.size(), 3);
        System.assertEquals(thisHome.tournamentOptions.size(), 3);
        thisHome.selectedTournament = thisTournament2.Id;
        thisHome.rerenderPageBlockForSelectedTournament();
        System.assertEquals(thisHome.tournamentBySelectOption.Id, thisTournament2.Id);
        thisHome.selectedTournament = thisTournament4.Id;
        thisHome.rerenderPageBlockForSelectedTournament();
        System.assertEquals(thisTournament2.Id, thisHome.tournamentBySelectOption.Id);
    }

    public static testMethod void rerenderPageBlockForSelectedTournamentsTypeTest(){
    
        Tournament__c thisTournament1 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament2 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current');
        Tournament__c thisTournament3 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Double Elimination', Status__c = 'Current');
        Tournament__c thisTournament4 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='2 x 2', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament5 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='2 x 2', Type__c = 'Single Elimination', Status__c = 'Current');
        Tournament__c thisTournament6 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='2 x 2', Type__c = 'Double Elimination', Status__c = 'Current');
        Tournament__c thisTournament7 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='2 x 2', Type__c = 'Double Elimination', Status__c = 'Upcoming');
        Tournament__c thisTournament8 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current');
        Tournament__c thisTournament9 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='2 x 2', Type__c = 'Round Robin', Status__c = 'Current');
        List<Tournament__c> thisTournamentList = new List<Tournament__c>();
        thisTournamentList.add(thisTournament1); 
        thisTournamentList.add(thisTournament2); 
        thisTournamentList.add(thisTournament3); 
        thisTournamentList.add(thisTournament4); 
        thisTournamentList.add(thisTournament5); 
        thisTournamentList.add(thisTournament6);
        thisTournamentList.add(thisTournament7);
        thisTournamentList.add(thisTournament8);
        thisTournamentList.add(thisTournament9);
        insert thisTournamentList;
        Set<Tournament__c> thisSetTournament = new Set<Tournament__c>();
        thisSetTournament.addAll(thisTournamentList); 
        HomeController thisHome = new HomeController();
                
        List<String> pickListTypeValuesList= new List<String>();
        List<String> pickListFormatValuesList= new List<String>();
        Schema.DescribeFieldResult fieldTypeResult = Tournament__c.Type__c.getDescribe();
        Schema.DescribeFieldResult fieldFormatResult = Tournament__c.Format__c.getDescribe();
        pickListTypeValuesList.add('AnyType');
        pickListFormatValuesList.add('AnyFormat');
        List<Schema.PicklistEntry> pleType = fieldTypeResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleType){
            pickListTypeValuesList.add(pickListVal.getLabel());
        }    
        List<Schema.PicklistEntry> pleFormat = fieldTypeResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleFormat ){
            pickListFormatValuesList.add(pickListVal.getLabel());
        }
        Integer count = 0;
        for(String type : pickListTypeValuesList ){
            thisHome.selectedTournamentType = type;
            for(String format : pickListFormatValuesList){
                thisHome.selectedTournamentFormat = format; 
                thisHome.rerenderPageBlockForSelectedTournamentsType();
                for(Integer i = 0; i < thisTournamentList.size(); i++){
                    for(Integer j = 0; j <thisHome.tournamentsInProgress.size(); j++){
                        if(thisTournamentList.get(i).Id == thisHome.tournamentsInProgress.get(j).Id) count++;
                    }
                }
            }
        }
        System.assertEquals(8, count/2);
    }

}