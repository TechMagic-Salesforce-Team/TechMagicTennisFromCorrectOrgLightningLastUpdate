/**
 * Created by rostyk_haidukevych on 10/10/17.
 */
public class AURA_RoundRobin {

	@AuraEnabled
	public static String getAllGamesJSONS(Id tournamentId, String playerId, String pageName){
		Tournament__c tournament = [select Id, Name, Format__c, Status__c, Type__c from Tournament__c where Id =: tournamentId limit 1];
		System.debug('tournament: '+tournament);
		RoundRobin rr = new RoundRobin();
		//if (playerId == null) playerId = [select Id from Player__c limit 1].Id;
		rr.lightningSync = true;
		try {
			rr.playerIdLightning = playerId;
			//rr.playerIdLightning = 'a000Y00000DqYt4QAF';
		} catch (StringException se){
			System.debug('String exception');
			rr.playerIdLightning = null;
		}
		rr.lightningPageName = pageName;
		System.debug('playerLightning:' + rr.playerIdLightning);
		//System.debug(JSON.serialize(se.representSingleEliminationGrid));
		return JSON.serialize(rr.RoundRobinGrid(tournament));
	}

}