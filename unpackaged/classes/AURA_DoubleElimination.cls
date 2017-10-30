/**
 * Created by rostyk_haidukevych on 10/6/17.
 */
public class AURA_DoubleElimination {


	@AuraEnabled
	public static String getAllGamesJSONS(Id tournamentId, String playerId, String pageName){
		Tournament__c tournament = [select Id, Name, Format__c, Status__c, Type__c from Tournament__c where Id =: tournamentId limit 1];
		DoubleEliminationTournament de = new DoubleEliminationTournament();
		de.oneTournament = tournament;
		de.lightningSync = true;
		try {
			de.playerIdLightning = playerId;
		} catch (StringException ex){
			System.debug('String exception');
			de.playerIdLightning = null;
		}
		de.lightningPageName = pageName;
        System.debug('de:'+de.playerIdLightning);
        System.debug('de:'+de.oneTournament);
		System.debug(JSON.serialize(de.representDoubleEliminationGridJSON));
		return JSON.serialize(de.representDoubleEliminationGridJSON);
	}

}