public with sharing virtual class TournamentController extends PlayerCookie{
    public String currentTournamentId {get; set;}
    public Tournament__c currentTournament {get; set;}
    
    public String isHome {get; set;}
    
    public Player__c currentPlayer2 {get; set;}
    public Player__c currentPlayerTmp {get; set;}
    
    public Tournament__c searchTournament {get; set;}
    public List<TournamentWrapper> allTournaments {get; private set;}
    public List<String> competitorsNames {get;set;}
    public String idTournamentToShow {get;set;}
	public String tournamentToShow {get;set;}
    public Player__c currentPlayerJSON {
        get;
        set;
    }

    public TournamentController() {
        searchTournament = new Tournament__c();
        currentTournament = new Tournament__c();
		tournamentToShow = ApexPages.currentPage().getParameters().get('tournamentId');
        currentPlayerJSON = [select ID from Player__c limit 1];
    }
    
    public PageReference create() {
        Pagereference pageRef = Page.CreateTournament;
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference save() {
        try {
            boolean isNewTournament = currentTournament.Id == null;
            currentTournament.Status__c = 'Upcoming';
            upsert(currentTournament);
            if (isNewTournament) {
                List<Player__c> playersForEmails = [SELECT Id, Email__c FROM Player__c WHERE Status__c = 'Active'];
                List<String> ids = new List<String>();
                List<String> emails = new List<String>();
                for (Player__c p : playersForEmails) {
                    ids.add(p.Id);
                    emails.add(p.Email__c);
                }
                sendNotification(ids, emails, currentTournament.Id, currentTournament.Name, currentTournament.Type__c, currentTournament.Format__c);
            }
            try{
        	   //System.schedule('Start tournament', '0 07 * * * ?', new TournamentStarter());
            } catch(Exception ex) {
                System.debug('An exception occured while creating new schedule(if it exists)');  
            }
            try{
        	   System.schedule('Notify players about games to play', '0 10 * * * ?', new GamesToPLayNotifier());
            } catch(Exception ex) {
                System.debug('An exception occured while creating new schedule(if it exists)');  
            }
            return Page.Tournaments;
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference checkPageAccessForInsert() {
        if (isManager) {
            return null;
        }
        return Page.Tournaments;
    }
    
    @future(callout=true)
    public static void sendNotification(List<String> ids, List<String> emails, String currentTournamentId, String currentTournamentName, String currentTournamentType, String currentTournamentFormat) {
        String text = 'You can apply for a new tournament ' + currentTournamentName + '! The type of the tournament is '+ currentTournamentType
        + ', and the format is ' + currentTournamentFormat + '.\n';
        for (Integer i = 0; i < ids.size(); i++){
//            MailSender.sendEmail(emails[i], 'New Tournament',
//                currentTournamentFormat == '1 x 1' ?
//                    (text + 'Follow the link to apply: https://techmagic-table-tennis-developer-edition.eu11.force.com/PlayerTournamentCreate?tp='
//                        + currentTournamentId + ids[i]): text);

        MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emails[i],'New Tournament', currentTournamentFormat == '1 x 1' ?
                 (text + 'Follow the link to apply: https://techmagic-table-tennis-developer-edition.eu11.force.com/PlayerTournamentCreate?tp='
                      + currentTournamentId + ids[i]): text));
        }
    }
    
    public PageReference cancel() {
        return Page.Tournaments;
    }
    
    public void view() {
        for (TournamentWrapper tW : allTournaments) {
            if (tW.tournament.Id == currentTournamentId) {
                tW.isShowed = tW.isShowed ? false : true;
            }
        }
		//competitorsOfTournament();
    }
    
    public PageReference apply() {
        Tournament__c thisTournament = findById();
        if (thisTournament != null && thisTournament.Status__c == 'Upcoming') {
            if (thisTournament.Format__c == '2 x 2') {
                Pagereference pageRef = Page.PlayerTeamCreate;
                pageRef.getParameters().put('tournamentId', currentTournamentId);
                return pageRef;
            } else {
                String pId = getCurrentPlayer().Id;
                List<PlayerTournament__c> playerTournaments = [SELECT Id FROM PlayerTournament__c 
                        WHERE Player__c = :pId AND Tournament__c = :currentTournamentId];
                if (playerTournaments.size() == 0) {
                    PlayerTournament__c pT = new PlayerTournament__c(Player__c = pId, Tournament__c = currentTournamentId);
                    try {
                        insert (pT);
                        for (TournamentWrapper tW : allTournaments) {
                            if (tW.tournament.Id == currentTournamentId) {
                                tW.isApplied = true;
                                break;
                            }
                        }
                    } catch (System.DmlException e) {
                        System.debug(e);
                        ApexPages.addMessages(e);
                    }
                }
                search();
            }
        }
        return null;
    }
    
    public void disapply() {
        Tournament__c thisTournament = findById();
        if (thisTournament != null && thisTournament.Status__c == 'Upcoming') {
            if (thisTournament.Format__c == '2 x 2') {
                List<Team__c> teamsToDelete = [SELECT Id, Name, (SELECT Player__c FROM PlayerTeams__r WHERE Player__c != :getCurrentPlayer().Id)
                    FROM Team__c WHERE Tournament__c = :currentTournamentId AND IsComplete__c = true AND
                    Id IN (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :getCurrentPlayer().Id)];
                try {
                    delete (teamsToDelete);
                    for (TournamentWrapper tW : allTournaments) {
                        if (tW.tournament.Id == currentTournamentId) {
                            tW.isApplied = false;
                            break;
                        }
                    }
                    if (teamsToDelete.size() > 0) {
                        List<PlayerTeam__c> playerTeams = teamsToDelete[0].PlayerTeams__r;
                        Player__c player = [SELECT Email__c FROM Player__c WHERE Id = :playerTeams[0].Player__c];
                        sendDissapplyNotification(player.Email__c, thisTournament.Name, teamsToDelete[0].Name);
                    }
                } catch (System.DmlException e) {
                    System.debug(e);
                    ApexPages.addMessages(e);
                }
            } else {
                PlayerTournament__c pT = [SELECT Id FROM PlayerTournament__c WHERE Player__c = :getCurrentPlayer().Id AND Tournament__c = :currentTournamentId];
                try {
                    delete (pT);
                    for (TournamentWrapper tW : allTournaments) {
                        if (tW.tournament.Id == currentTournamentId) {
                            tW.isApplied = false;
                            break;
                        }
                    }
                } catch (System.DmlException e) {
                    System.debug(e);
                    ApexPages.addMessages(e);
                }
            }
        }
    }
    
    @future(callout=true)
    private static void sendDissapplyNotification(String email, String currentTournamentName, String currentTeamName) {
        String text = 'The team ' + currentTeamName + ' taking part in the tournament ' + currentTournamentName + ' has been deleted by your team partner.';
//        MailSender.sendEmail(email, 'Team deletion', text);
         MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(email, 'Team deletion', text));
    }
    
    public void start() {
        Tournament__c tournamentToStart = findById();
        if (tournamentToStart != null && tournamentToStart.Status__c == 'Upcoming') {
            TournamentStarter tStarter = new TournamentStarter();
            tStarter.start(tournamentToStart);
            search();
        }
    }
    
    public static void finish(Tournament__c t) {
        if (t.Status__c != 'Completed') {
            t.Status__c = 'Completed';
            try {
                update (t);
            } catch (System.DmlException e) {
                System.debug(e);
            }
        }
    }
    
    public PageReference editUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                Pagereference pageRef = Page.EditTournament;
                pageRef.getParameters().put('tournamentId', currentTournament.Id);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'You can not edit this tournament as it is ' + currentTournament.Status__c));
            }
        }
        return null;
    }
    
    public void deleteUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                try {
                    delete(currentTournament);
                    allTournaments = findAll();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                        'You have just deleted the tournament!'));
                } catch(System.DmlException e) {
                    ApexPages.addMessages(e);
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'You can not delete this tournament as it is ' + currentTournament.Status__c));
            }
        }
    }


    public PageReference getTournament(){
            currentTournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
            if (currentTournamentId != null) {
                currentTournament = findById();
                getCompetitorNames();
                if (currentTournament != null) {
                    return null;
                }
            }
        return Page.Tournaments;
    }
    
    public PageReference checkTournamentExistance() {
        System.debug(isManager);
        if (isManager) {
            currentTournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
            if (currentTournamentId != null) {
                currentTournament = findById();
                if (currentTournament != null) {
                    return null;
                }
            }
        }
        return Page.Tournaments;
    }
    
    private Tournament__c findById() {
        List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
            FROM Tournament__c
            WHERE Id = :currentTournamentId];
        if (tournaments.size() > 0) {
            return tournaments[0];
        }
        return null;
    }
    
    public void search() {
        if (isHome == 'true') {
            searchTournament.Status__c = 'Current';
            searchTournament.Name = '';
        }
        allTournaments = findAll();
    }
    
    public List<TournamentWrapper> findAll() {
        String tName = searchTournament.Name == null ? '%' : '%' + searchTournament.Name + '%';
        String tType = searchTournament.Type__c == null ? '%' : searchTournament.Type__c;
        String tFormat = searchTournament.Format__c == null ? '%' : searchTournament.Format__c;
        String tStatus = searchTournament.Status__c == null ? '%' : searchTournament.Status__c;

        List<TournamentWrapper> result = new List<TournamentWrapper>();
        
        List<Tournament__c> tournaments;
        List<String> tournamentIds;

        if (currentPlayer2 == null) {
            currentPlayerTmp = getCurrentPlayer();
            tournamentIds = getAllAppliedTournamentIds();
            tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
                FROM Tournament__c
                WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
                AND Status__c LIKE :tStatus];
        } else {
            currentPlayerTmp = currentPlayer2;
            tournamentIds = getAllAppliedTournamentIds();
            tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
                FROM Tournament__c
                WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
                AND Status__c LIKE :tStatus AND Id IN :tournamentIds];
        }
        
        System.debug(currentPlayer2);
        System.debug(tournaments.size());
        
        for (Tournament__c t : tournaments) {
            TournamentWrapper tW = new TournamentWrapper();
            tW.tournament = t;
            if (idTournamentToShow!=null && idTournamentToShow==''+t.Id) tW.isShowed = true;
            else tW.isShowed = false;
            tW.isApplied = false;
            for (String id : tournamentIds) {
                if (t.Id == id) {
                    tW.isApplied = true;
                    break;
                }
            }
            result.add(tW);
        }
        return result;
    }
    
    private List<String> getAllAppliedTournamentIds() {
        List<PlayerTournament__c> playerTournamnets = [SELECT Tournament__c 
                FROM PlayerTournament__c WHERE Player__c = :currentPlayerTmp.Id];
        List<Team__c> teams = [SELECT Tournament__c 
            FROM Team__c 
            WHERE IsComplete__c = true AND Id IN 
            (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerTmp.Id)];
        
        List<String> tournamentIds = new List<String>();
        
        for (PlayerTournament__c pt : playerTournamnets) {
            tournamentIds.add(pt.Tournament__c);
        }
        for (Team__c t : teams) {
            tournamentIds.add(t.Tournament__c);
        }
        return tournamentIds;
    }
    
    public class TournamentWrapper {
        public Tournament__c tournament {get; set;}
        public Boolean isShowed {get; set;}
        public Boolean isApplied {get; set;}
        public String message {get;set;}
    }

	public void competitorsOfTournament(){
		currentTournament = getFromTournamentWrapper();
		competitorsNames = new List<String>();
        getCompetitorNames();
	}

	public Tournament__c getFromTournamentWrapper(){
		for (TournamentWrapper tw: allTournaments){
			if (tw.tournament.Id == currentTournamentId) {
				return tw.tournament;
			}
		}
		return null;
	}

    public void getCompetitorNames(){
        competitorsNames = new List<String>();
        if (currentTournament.Format__c == '1 x 1'){
            List<Player__c> players =  [select Name from Player__c where Id in (Select Player__c from PlayerTournament__c where Tournament__c=:currentTournament.Id)];
            for (Player__c player: players){
                competitorsNames.add(player.Name);
            }
        } else {
            List<Team__c> teams = [select Name, (select Player__r.Name from PlayerTeams__r) from Team__c where Tournament__c =: currentTournament.Id and IsComplete__c = true];
            for (Team__c team: teams){
                String teamAllData = team.Name+'(';
                for (PlayerTeam__c pl: team.PlayerTeams__r){
                    teamAllData += pl.Player__r.Name;
                }
                teamAllData+=')';
                competitorsNames.add(teamAllData);
            }
        }

    }
    
}