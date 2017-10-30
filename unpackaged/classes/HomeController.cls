public with sharing class HomeController extends PlayerCookie{


    public List<Tournament__c> tournamentsInProgress{get;set;}
    public Integer tournamentsInProgressSize{get;set;}
    public String selectedTournamentType{get;set;}
    public String selectedTournamentFormat{get;set;}
    public String showTournamentId {get;set;}
    
    
    public Tournament__c tournamentBySelectOption{
        get{
            if(tournamentBySelectOption == null) tournamentBySelectOption = new Tournament__c();
            return tournamentBySelectOption;
        }
        set;
    }
    
    public String selectedTournament{
        get{
            if (selectedTournament == null) selectedTournament = '';
            return selectedTournament;
        }
        set;
    }
    public List<SelectOption> tournamentOptions{
        get{
            if (tournamentOptions == null) {
                tournamentOptions = new List<SelectOption>();
            }
            Set<Tournament__c> thisTournaments = new Set<Tournament__c>();
            thisTournaments.addAll(getAllTournamentsInProgress());
            for(Tournament__c thisTournament : thisTournaments){
                SelectOption SO = new SelectOption(thisTournament.Id, thisTournament.Name);
                tournamentOptions.add(SO);
            }
            return tournamentOptions;
        }
        set;
    }
    public List<SelectOption> tournamentTypeOptions{
        get{
            if (tournamentTypeOptions== null) {
                tournamentTypeOptions= new List<SelectOption>();
            }
            Schema.DescribeFieldResult fieldTypeResult = Tournament__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> pleType = fieldTypeResult.getPicklistValues();
            tournamentTypeOptions.add(new SelectOption('AnyType', 'All Types'));
            for( Schema.PicklistEntry pickListVal : pleType){
                tournamentTypeOptions.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
            }    
            return tournamentTypeOptions;
        }
        set;
    }
    public List<SelectOption> tournamentFormatOptions{
        get{
            if (tournamentFormatOptions== null) {
                tournamentFormatOptions= new List<SelectOption>();
            }
            tournamentFormatOptions.add(new SelectOption('AnyFormat','All Formats'));
            tournamentFormatOptions.add(new SelectOption('1 x 1','1 x 1'));
            tournamentFormatOptions.add(new SelectOption('2 x 2','2 x 2'));
            return tournamentFormatOptions;
        }
        set;
    }
    public HomeController(){
        System.debug('home ctrl');
         tournamentsInProgress = getAllTournamentsInProgress();
         if (tournamentsInProgress.size()>0) tournamentBySelectOption = tournamentsInProgress.get(0);
         tournamentsInProgressSize = tournamentsInProgress.size();
         showTournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
    }
    
    
    private List<Tournament__c> getAllTournamentsInProgress(){
        List<Tournament__c> tournaments = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                           FROM Tournament__c Where Status__c = 'Current'];
        return tournaments;
    }
    
    public void rerenderPageBlockForSelectedTournament(){
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Id = :selectedTournament];
        if(thisTournament.size()>0){
            tournamentBySelectOption = thisTournament.get(0);
        }    
    }    
    public void rerenderPageBlockForSelectedTournamentsType(){
        List<String> myType = new List<String>();
        List<String> myFormat = new List<String>();
        if(selectedTournamentType == 'AnyType'){
            myType.add('Round Robin');
            myType.add('Single Elimination');
            myType.add('Double Elimination');
        } 
        else{myType.add(selectedTournamentType);}
        if(selectedTournamentFormat == 'AnyFormat'){
            myFormat.add('1 x 1');
            myFormat.add('2 x 2');
        } 
        else{myFormat.add(selectedTournamentFormat);}
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Type__c = :myType AND Format__c = :myFormat];
        
        if(thisTournament.size() !=null && thisTournament.size()>0){
            tournamentsInProgress = thisTournament;
        }else{
              tournamentsInProgress  = new List<Tournament__c>();
             }    
    }   
}