/**
 * Created by rostyk_haidukevych on 10/10/17.
 */
public class AURA_SingleElimination {

	@AuraEnabled
	public static String getAllGamesJSONS(Id tournamentId, String playerId, String pageName){
		Tournament__c tournament = [select Id, Name, Format__c, Status__c, Type__c from Tournament__c where Id =: tournamentId limit 1];
		System.debug('tournament: '+tournament);
		SingleEliminationTournament se = new SingleEliminationTournament();
		se.oneTournament = tournament;
		se.lightningSync = true;
		se.lightningPageName = pageName;
		try {
			se.playerIdLightning = playerId;
		} catch (StringException ex){
			System.debug('String exception');
			se.playerIdLightning = null;
		}
		System.debug(JSON.serialize(se.representSingleEliminationGrid));
		return JSON.serialize(se.representSingleEliminationGrid);
	}

}