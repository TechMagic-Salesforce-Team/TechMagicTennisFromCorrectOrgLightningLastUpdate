public with sharing class PlayerTeamController extends PlayerCookie{
    
    public Player__c currentPlayer2 { get; set; }
    
    public String invitationTournamentId { get; set; }
    public String invitationTeamId { get; set; }
    public String invitationPlayerId { get; set; }
    
    public List<TeamInvitation> teamInvitations { get {
            if (teamInvitations == null) return getAllTeamInvitations();
            return teamInvitations;
    } set; }
    
    public Tournament__c currentTournament { get; set; }
    public String tournamentId { get; set; }
    
    public Team__c team { get; set; }
    
    public String currentPlayerId { get; set; }
    public List<Player__c> players { get; set; }
    public String selectedPlayer { get; set; }
    
    
    public LIst<SelectOption> playersOptions { get {
            if (playersOptions == null) {
                playersOptions = new List<SelectOption>();
                List<Team__c> teams = [
                    SELECT Name, (SELECT Player__c FROM PlayerTeams__r)
                    FROM Team__c WHERE Tournament__c = :tournamentId AND IsComplete__c = true
                ];
                for (Player__c p: players) {
                    SelectOption selectOption;
                    for (Team__c t: teams) {
                        for (PlayerTeam__c pT: t.PlayerTeams__r) {
                            if (pT.Player__c == p.Id) {
                                selectOption = new SelectOption(p.Id, p.Name + '(' + t.Name + ')');
                                SelectOption.setDisabled(true);
                                break;
                            }
                        }
                        if (selectOption != null) {
                            break;
                        }
                    }
                    if (selectOption == null) {
                        selectOption = new SelectOption(p.Id, p.Name);
                    }
                    playersOptions.add(selectOption);
                }
            }
            return playersOptions;
        } set; }
    
    public PlayerTeamController() {
        try {
            tournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
            currentPlayerId = getCurrentPlayer().Id;
            players = [SELECT Id, Name FROM Player__c WHERE Id != :currentPlayerId AND Status__c = 'Active'];
            team = new Team__c();
        } catch (Exception ex) {
            System.debug('It is lightning');
        }
    }
    
    public PageReference cancel() {
        return Page.Tournaments;
    }
    
    public PageReference create() {
        List<Team__c> teamsToCheck = [SELECT Id FROM Team__c WHERE Tournament__c = :tournamentId AND IsComplete__c = true
            AND Id IN (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerId OR Player__c = :selectedPlayer)];
        
        if (teamsToCheck.size() > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'Either you or your partner is already applied'));
            return null;
        }
        
        // create team;
        team.Tournament__c = tournamentId;
        try {
            insert (team);
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        // create playerTeam objects
        PlayerTeam__c firstPlayerTeam = new PlayerTeam__c();
        firstPlayerTeam.Player__c = currentPlayerId;
        firstPlayerTeam.Team__c = team.Id;
        
        PlayerTeam__c secondPlayerTeam = new PlayerTeam__c();
        secondPlayerTeam.Team__c = team.Id;
        secondPlayerTeam.Player__c = selectedPlayer;
        secondPlayerTeam.IsInvited__c = true;

        try {
            insert(firstPlayerTeam);
            insert(secondPlayerTeam);
            sendInvitationEmail(currentPlayerId, selectedPlayer, team.Id);
            return Page.Tournaments;
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }  catch(Exception e) {
            System.debug(e);
        }
        return Page.Tournaments;
    }
    
    public PageReference validatePageVisitor() {
        System.debug('cookie: ' + currentPlayerId);
        if (isLoggedIn) {
            List<Tournament__c> tournaments = [SELECT Id, Format__c, Status__c, Type__c, StartDate__c, Name FROM Tournament__c WHERE Id =:tournamentId];
            if (tournaments.size() > 0) {
                if (tournaments[0].Format__c == '2 x 2' && tournaments[0].Status__c == 'Upcoming') {
                    List<Team__c> teams = [SELECT Id FROM Team__c WHERE Tournament__c = :tournamentId AND IsComplete__c = true AND
                        Id IN (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerId)];
                    if (teams.size() == 0) {
                        currentTournament = tournaments[0];
                        return null;
                    }
                }
            }
        }
        return Page.Home;
    }
    
    @future(callout=true)
    public static void sendInvitationEmail(String fromPlayerId, String toPlayerId, String teamId) {
        Player__c fromPlayer = [SELECT Id, Name FROM Player__c WHERE Id = :fromPlayerId];
        Player__c toPlayer = [SELECT Id, Name, Email__c FROM Player__c WHERE Id = :toPlayerId];
        Team__c team = [SELECT Id, Name, Tournament__r.Name FROM Team__c WHERE Id = :teamId];
        
        //MailSender.sendEmail(toPlayer.Email__c, 'New team invitation','Dear, ' + toPlayer.Name + '! You have got an invitation from ' + fromPlayer.Name + ' to take part in the tournament ' + team.Tournament__r.Name + ' as a team member of ' + team.Name + '.');
        MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(toPlayer.Email__c, 'New team invitation', 'Dear, ' + toPlayer.Name + '! You have got an invitation from ' + fromPlayer.Name + ' to take part in the tournament ' + team.Tournament__r.Name + ' as a team member of ' + team.Name + '.'));
    }
    
    private List<TeamInvitation> getAllTeamInvitations() {
        if (currentPlayer2 == null) {
            return new List<TeamInvitation>();
        }
        List<Team__c> teams = [SELECT Id, Name, Tournament__r.Id, Tournament__r.Name, 
            (SELECT Player__c FROM PlayerTeams__r WHERE IsInvited__c = false)
            FROM Team__c WHERE IsComplete__c = false AND Tournament__r.Status__c = 'Upcoming'
            AND Id IN (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayer2.Id)];
        System.debug(teams);
        List<String> playersIds = new List<String>();
        List<Team__c> otherTeams = new List<Team__c>();
        for(Team__c t : teams) {
            List<PlayerTeam__c> list1 = t.PlayerTeams__r;
            System.debug(list1);
            if (list1.size() > 0 && list1[0].Player__c != currentPlayer2.Id) {
                otherTeams.add(t);
                playersIds.add(list1[0].Player__c);
            }
        }
        
        List<Player__c> otherPlayers = [SELECT Id, Name FROM Player__c WHERE Id IN :playersIds];
        
        List<TeamInvitation> result = new List<TeamInvitation>();
        for(Team__c t : otherTeams) {
            List<PlayerTeam__c> list1 = t.PlayerTeams__r;
            for(Player__c p : otherPlayers) {
                if (p.Id == list1[0].Player__c) {
                    TeamInvitation tI = new TeamInvitation();
                    tI.tournamentId = t.Tournament__r.Id;
                    tI.tournamentName = t.Tournament__r.Name;
                    tI.teamName = t.Name;
                    tI.teamId = t.Id;
                    tI.playerName = p.Name;
                    tI.playerId = p.Id;
                    
                    result.add(tI);
                    break;
                }
            }
        }
        return result;
    }
    public void acceptInvitation() {
        Team__c team = new Team__c(Id = invitationTeamId, IsComplete__c = true);
        try {
            update (team);
        } catch (System.DmlException e) {
            System.debug(e);
            return;
        }
        List<Team__c> teams = [SELECT Id, (SELECT Id FROM PlayerTeams__r WHERE Player__c = :invitationPlayerId OR Player__c = :currentPlayer2.Id)
            FROM Team__c WHERE Tournament__c = :invitationTournamentId AND IsComplete__c = false];
        List<Team__c> teamsToDelete = new List<Team__c>();
        for (Team__c t : teams) {
            List<PlayerTeam__c> list1 = t.PlayerTeams__r;
            if (list1.size() > 0) {
                teamsToDelete.add(t);
            }
        }
        try {
            delete (teamsToDelete);
        } catch (System.DmlException e) {
            System.debug(e);
        }
    }
    
    public void declineInvitation() {
        Team__c team = new Team__c(Id = invitationTeamId, IsComplete__c = true);
        try {
            delete (team);
        } catch (System.DmlException e) {
            System.debug(e);
        }
    }
    
    public class TeamInvitation {
        public String tournamentId { get; set; }
        public String tournamentName { get; set; }
        public String teamName { get; set; }
        public String teamId { get; set; }
        public String playerName { get; set; }
        public String playerId { get; set; }
    }

}