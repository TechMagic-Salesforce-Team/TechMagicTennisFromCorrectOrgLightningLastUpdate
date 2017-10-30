global class GamesToPLayNotifier implements Schedulable{
//, Database.AllowsCallouts {
	public static integer emailsCnt {
		get; set;
	}
	//@future
	global void execute(SchedulableContext ctx) {
		//MailSender.sendEmail('rgaidukevich9@gmail.com','Uncompleted games','You have not played some games, please play them and submit results');
		Set<String> emails = new Set<String>();
		List<Tournament__c> tournaments = [SELECT Id, Format__c FROM Tournament__c WHERE Status__c = 'Current'];
		for (Tournament__c t : tournaments) {
			if (t.Format__c == '1 x 1') {
				emails.addAll(getPlayersEmails(t));
			} else {
				emails.addAll(getTeamMembersEmails(t));
			}
		}
		sendNotification(emails);
	}

	private Set<String> getPlayersEmails(Tournament__c tournament) {
		Set<String> resultEmails = new Set<String>();
		List<Player__c> players = [SELECT Email__c FROM Player__c WHERE Id IN
		(SELECT Player__c FROM PlayerTournament__c WHERE Tournament__c = :tournament.Id)];
		List<Game__c> games = [SELECT firstCompetitor__c, secondCompetitor__c FROM Game__c
				WHERE Tournament__c = :tournament.Id AND firstCompetitorScore__c = 0
		AND secondCompetitorScore__c = 0];
		for (Player__c p : players) {
			for (Game__c g : games) {
				if (g.firstCompetitor__c == p.Id || g.secondCompetitor__c == p.Id) {
					resultEmails.add(p.Email__c);
					break;
				}
			}
		}
		return resultEmails;
	}

	private Set<String> getTeamMembersEmails(Tournament__c tournament) {
		Set<String> resultEmails = new Set<String>();
		List<Game__c> games = [SELECT firstCompetitor__c, secondCompetitor__c FROM Game__c
				WHERE Tournament__c = :tournament.Id AND firstCompetitorScore__c = 0
		AND secondCompetitorScore__c = 0];
		Set<String> teamIds = new Set<String>();
		for (Game__c g : games) {
			teamIds.add(g.firstCompetitor__c);
			teamIds.add(g.secondCompetitor__c);
		}
		List<Player__c> players = [SELECT Email__c FROM Player__c WHERE Id IN
		(SELECT Player__c FROM PlayerTeam__c WHERE Team__c IN :teamIds)];
		for (Player__c p : players) {
			resultEmails.add(p.Email__c);

		}
		return resultEmails;


	}

	@future(callout = true)
	public static void sendNotification(Set<String> emails) {
//        for (String email:emails){
//            MailSender.sendEmail(email,'Uncompleted games','You have not played some games, please play them and submit results');
//        }
		String href = 'https://techmagic-table-tennis-developer-edition.eu11.force.com/Tournaments';
			//('' + URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0] + '/Tournaments';
		MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emails, 'Uncompleted games', HtmlBodies.htmlBodyForGamesToPlayNotifier(href)));
	}


}