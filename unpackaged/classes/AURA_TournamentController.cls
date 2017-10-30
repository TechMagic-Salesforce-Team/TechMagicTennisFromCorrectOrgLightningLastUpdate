/**
 * Created by rostyk_haidukevych on 10/9/17.
 */
public class AURA_TournamentController {

	@AuraEnabled
	public static List<Tournament__c> findAll(Tournament__c searchTournament, Boolean home){
		String tName = String.isBlank(searchTournament.Name) ? '%' : '%' + searchTournament.Name + '%';
		String tType = String.isBlank(searchTournament.Type__c) ? '%' : searchTournament.Type__c;
		String tFormat = String.isBlank(searchTournament.Format__c) ? '%' : searchTournament.Format__c;
		String tStatus = !home ? String.isBlank(searchTournament.Status__c) ? '%' : searchTournament.Status__c : 'Current';

		return [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat AND Status__c LIKE :tStatus];
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

}