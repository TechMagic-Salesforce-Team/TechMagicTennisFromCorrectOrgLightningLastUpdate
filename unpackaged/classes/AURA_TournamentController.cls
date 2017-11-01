/**
 * Created by rostyk_haidukevych on 10/9/17.
 */
public class AURA_TournamentController {

	@AuraEnabled
	public static String findAll(Tournament__c searchTournament, Boolean home, String currentPlayerId){
		String tName = String.isBlank(searchTournament.Name) ? '%' : '%' + searchTournament.Name + '%';
		String tType = String.isBlank(searchTournament.Type__c) ? '%' : searchTournament.Type__c;
		String tFormat = String.isBlank(searchTournament.Format__c) ? '%' : searchTournament.Format__c;
		String tStatus = !home ? String.isBlank(searchTournament.Status__c) ? '%' : searchTournament.Status__c : 'Current';



		Map<Id,Tournament__c> tournaments =  new Map<Id, Tournament__c>([SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat AND Status__c LIKE :tStatus]);


		List<Id> idsOfAppliedTournaments = new List<Id>();

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
					if (currentPlayerId.contains(t.PlayerTeams__r.get(0).Player__c) ||
							currentPlayerId.contains(t.PlayerTeams__r.get(1).Player__c)) {
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
				return tournament;
			}
		}
		return null;
	}

	@AuraEnabled
	public static String create(Tournament__c tournament) {
		TournamentWrap tw = new TournamentWrap();
		tw.tournament = new Tournament__c();
		try {
			tournament.Status__c = 'Upcoming';
			insert tournament;
			tw.message = 'SUCCESS';
			tw.tournament = tournament;
		} catch (Exception ex){
			tw.message = 'FAIL';
		}
		return JSON.serialize(tw);
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
			}
		}
		return 'success';
	}


}