/**
 * Created by rostyk_haidukevych on 10/9/17.
 */
public class AURA_TournamentController {

	@AuraEnabled
	public static String findAll(Tournament__c searchTournament, Boolean home, String currentPlayerId, String playerId){

		String tName = String.isBlank(searchTournament.Name) ? '%' : '%' + searchTournament.Name + '%';
		String tType = String.isBlank(searchTournament.Type__c) ? '%' : searchTournament.Type__c;
		String tFormat = String.isBlank(searchTournament.Format__c) ? '%' : searchTournament.Format__c;
		String tStatus = !home ? String.isBlank(searchTournament.Status__c) ? '%' : searchTournament.Status__c : 'Current';



		Map<Id,Tournament__c> tournaments =  new Map<Id, Tournament__c>([SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat AND Status__c LIKE :tStatus]);



		List<Id> idsOfAppliedTournaments = new List<Id>();
		if (!String.isBlank(playerId)) {
			currentPlayerId = playerId;
		}


		if (!String.isBlank(currentPlayerId)) {
			if (tFormat == '1 x 1' || tFormat == '%') {
				List<PlayerTournament__c> playerTournaments =
				[select Tournament__c from PlayerTournament__c where Player__c =: currentPlayerId and Tournament__c in: tournaments.keySet()];
				for (PlayerTournament__c pt: playerTournaments) {
					idsOfAppliedTournaments.add(pt.Tournament__c);
				}
			}

			if (tFormat == '2 x 2' || tFormat == '%') {
				List<Team__c> teams =
				[select Id, Tournament__c, (select Player__c from PlayerTeams__r) from Team__c where Tournament__c in: tournaments.keySet() and IsComplete__c = true];
				for (Team__c t: teams) {
					if ((''+t.PlayerTeams__r.get(0).Player__c).contains(currentPlayerId) ||
							(''+t.PlayerTeams__r.get(1).Player__c).contains(currentPlayerId)) {
						idsOfAppliedTournaments.add(t.Tournament__c);
					}
				}
			}
		}



		List<TournamentController.TournamentWrapper> twrapperList = new List<TournamentController.TournamentWrapper>();
		Boolean found = false;
		for (Id tournamentAllId: tournaments.keySet()) {
			found = false;
			TournamentController.TournamentWrapper tw = new TournamentController.TournamentWrapper();
			tw.isApplied = false;
			tw.isShowed = false;
			tw.tournament = tournaments.get(tournamentAllId);
			for (Id idOfAppliedTournament: idsOfAppliedTournaments) {
				if (idOfAppliedTournament==tournamentAllId) {
					tw.isApplied = true;
					found = true;
					if (tournaments.get(tournamentAllId).Status__c == 'Upcoming') {
						tw.isShowed = true;
						break;
					}
				}
			}
			if (!found && !String.isBlank(currentPlayerId)) {
				//because in this case we are on the player page and only applied tournaments must be shown =>
				//without a possibility to apply for them
				if (playerId != null) continue;
				if (tournaments.get(tournamentAllId).Status__c == 'Upcoming') {
					tw.isShowed = true;
				}
				tw.isApplied = false;
			}
			twrapperList.add(tw);
		}
		return JSON.serialize(twrapperList);
	}


	@AuraEnabled
	public static Tournament__c getFirstCurrent(Boolean home){
		if (home)
		return [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c WHERE Status__c='Current' order by CreatedDate limit 1];
		else return [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c order by CreatedDate limit 1];
	}

	@AuraEnabled
	public static Player__c loadPlayer(String playerId){
		//if (!String.isBlank(playerId)) {
			try {
				return [select Id, Name, Email__c, IsManager__c from Player__c where Id=:playerId];
			} catch (Exception ex){
				return null;
			}
		//}

	}

	@AuraEnabled
	public static Tournament__c start(Id tournamentId) {
		if (tournamentId != null) {
			Tournament__c tournament = [select Id, Name, Status__c, Format__c, StartDate__c, Type__c from Tournament__c where Id=:tournamentId];
			if (tournament.Status__c == 'Upcoming') {
				TournamentStarter tStarter = new TournamentStarter();
				tStarter.start(tournament);
				sendNotificationsAboutStartedTournament(tournament);
				try{
					System.schedule('Notify players about games to play', '0 0 10 * * ?', new GamesToPLayNotifier());
				} catch(Exception ex) {
					System.debug('An exception occured while creating new schedule(if it exists)');
				}
				return tournament;
			}
		}
		return null;
	}

	@AuraEnabled
	public static String create(Tournament__c tournament) {
		TournamentController.TournamentWrapper tw = new TournamentController.TournamentWrapper();
		tw.tournament = new Tournament__c();
		try {
			tournament.Status__c = 'Upcoming';
			insert tournament;
			tw.message = 'SUCCESS';
			tw.tournament = tournament;
			tw.isShowed = true;
			tw.isApplied = false;
			sendNotificationsAboutNewTournament(tournament);
		} catch (Exception ex){
			tw.message = 'FAIL';
		}
		return JSON.serialize(tw);
	}


	public static void sendNotificationsAboutNewTournament(Tournament__c tournament){
		//List<Player__c> playersForEmails = [SELECT Id, Email__c FROM Player__c WHERE Status__c = 'Active' and Id='a000Y00000FJJzA'];
		List<Player__c> playersForEmails = [SELECT Id, Email__c FROM Player__c WHERE Status__c = 'Active'];
		List<String> ids = new List<String>();
		List<String> emails = new List<String>();
		for (Player__c p : playersForEmails) {
			ids.add(p.Id);
			emails.add(p.Email__c);
		}
		System.debug('Tournament created '+tournament.Id);
		TournamentController.sendNotification(ids, emails, tournament.Id, tournament.Name, tournament.Type__c, tournament.Format__c);
	}

	public static void sendNotificationsAboutStartedTournament(Tournament__c tournament) {
		Set<String> emails = new Set<String>();
		Map<String, String> competitors = Helper.getIdAndNameMap(tournament);
		if (tournament.Format__c=='1 x 1') {
			List<Player__c> players = [select Id, Email__c from Player__c where Id in: competitors.keySet()];
			for (Player__c player : players){
				emails.add(player.Email__c);
			}
		} else {
			List<Team__c> teams = [select Id, (select Id, Player__r.Email__c from PlayerTeams__r) from Team__c where Id in : competitors.keySet()];
			for (Team__c team : teams) {
				for (PlayerTeam__c pt : team.PlayerTeams__r) {
					emails.add(pt.Player__r.Email__c);
				}
			}
		}
		System.debug('Addresses, which will get an email about starting new tournament: '+emails);
		TournamentController.sendNotificationAboutTournamentThatStarted(tournament.Name,emails);
	}


	public class TournamentWrap {
		Tournament__c tournament;
		String message;
	}

	@AuraEnabled
	public static String deleteTournament(Id tournamentId){
		System.debug('tournamentId: '+tournamentId);
		try {
			delete [select Id from Tournament__c where Id=:tournamentId];
		} catch (Exception ex){
			System.debug(ex);
		}
		return 'Hello';
	}


	@AuraEnabled
	public static String applyForTournament(Id tournamentId, Id playerId) {
		Tournament__c tournament = [select Id, Name, Format__c, Status__c from Tournament__c where Id=:tournamentId];
		Player__c player = [select Id from Player__c where Id=:playerId];
		if (tournament.Status__c == 'Upcoming') {
			if (tournament.Format__c == '1 x 1') {
				List<PlayerTournament__c> playerTournamentList =
						[select Id from PlayerTournament__c where Tournament__c =: tournament.Id and Player__c =: player.Id];

				if (playerTournamentList.size() > 0) {
					delete playerTournamentList.get(0);
					return '';
				}
				PlayerTournament__c playerTournament = new PlayerTournament__c();
				playerTournament.Tournament__c = tournament.Id;
				playerTournament.Player__c = player.Id;
				insert playerTournament;
			} else {


			}
		}
		return 'success';
	}

	@AuraEnabled
	public static String playersToInviteForTeam(Id tournamentId) {
		Tournament__c tournament = [select Id, Name, Format__c, Status__c from Tournament__c where Id=:tournamentId];
		List<PlayerWrapper> playerWrapperList = new List<PlayerWrapper>();
		List<Id> playersInvitedIds = new List<Id>();
		if (tournament.Status__c=='Upcoming' && tournament.Format__c == '2 x 2') {
			List<Team__c> teams = [select Id, Name, (select Player__c, Player__r.Name from PlayerTeams__r) from Team__c where Tournament__c =: tournament.Id and IsComplete__c = true];
			for (Team__c team: teams) {
				for (PlayerTeam__c pt: team.PlayerTeams__r) {
					PlayerWrapper pw = new PlayerWrapper();
					pw.playerId =  pt.Player__c;
					pw.playerName = pt.Player__r.Name;
					pw.enabled = false;
					pw.teamName = team.Name;
					playersInvitedIds.add(pt.Player__c);
					playerWrapperList.add(pw);
				}
			}
			List<Player__c> players = [select Id, Name from Player__c where Status__c = 'Active' and Id not in: playersInvitedIds];
			for (Player__c player: players) {
				PlayerWrapper pw = new PlayerWrapper();
				pw.playerId =  player.Id;
				pw.playerName = player.Name;
				pw.enabled = true;
				playerWrapperList.add(pw);
			}
		}
		return JSON.serialize(playerWrapperList);
	}

	@AuraEnabled
	public static String createTeam(String playerCookieId, String teamName, String idPlayerSelected, String tournamentId){

		Team__c team = new Team__c();
		team.Tournament__c = tournamentId;
		team.Name = teamName;
		insert team;

		PlayerTeam__c playerTeam1 = new PlayerTeam__c();
		playerTeam1.Team__c = team.Id;
		playerTeam1.Player__c = playerCookieId;
		insert playerTeam1;

		PlayerTeam__c playerTeam2 = new PlayerTeam__c();
		playerTeam2.Team__c = team.Id;
		playerTeam2.Player__c = idPlayerSelected;
		playerTeam2.IsInvited__c = true;
		insert playerTeam2;

		try {
			PlayerTeamController.sendInvitationEmail(playerCookieId, idPlayerSelected, team.Id);
		} catch(Exception e) {
			System.debug(e);
		}

		return 'message';
	}


	@AuraEnabled
	public static Team__c deleteTeamDialog(String playerCookieId, String tournamentId){
		List<Team__c> teams = [select Id, Name, (select Player__r.Name, Player__c from PlayerTeams__r) from Team__c where Tournament__c=:tournamentId and IsComplete__c=true];
		for (Team__c t: teams){
			List<PlayerTeam__c> pt = t.PlayerTeams__r;
			if (String.valueOf(pt.get(0).Player__c).contains(playerCookieId) ||
				String.valueOf(pt.get(1).Player__c).contains(playerCookieId)
			) {
				return t;
			}
		}
		return null;
	}

	@AuraEnabled
	public static String deleteTeam(String teamId) {
		try {
			delete [select Id from Team__c where Id=: teamId];
			return 'Deleted';
		} catch (Exception ex) {
			return 'Exception occured while team deleting process';
		}
	}


	public class PlayerWrapper {
		String playerId;
		String playerName;
		Boolean enabled;
		String teamName;
	}

}