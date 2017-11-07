/**
 * Created by rostyk_haidukevych on 11/7/17.
 */
public class AURA_TeamController {

	@AuraEnabled
	public static String getAllInvitations(String playerId){
		Player__c player = [select Id, Name, Status__c, Rating__c, Image__c from Player__c where Id =: playerId];
		PlayerTeamController ptc = new PlayerTeamController();
		ptc.currentPlayer2 = player;
		return JSON.serialize(ptc.teamInvitations);
	}


	@AuraEnabled
	public static String acceptTeamInvitation(String teamId, String playerFromCookieId, String playerId) {
		Team__c team = [select Id, Tournament__c from Team__c where Id=:teamId];
		PlayerTeamController ptc = new PlayerTeamController();
		ptc.invitationTeamId = team.Id;
		ptc.invitationPlayerId = [select Id from Player__c where Id =: playerId].Id;
		ptc.currentPlayer2 = [select Id from Player__c where Id=:playerFromCookieId];
		ptc.acceptInvitation();
		Tournament__c tournament = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
				FROM Tournament__c
				WHERE Id = :team.Tournament__c];
		TournamentController.TournamentWrapper tw = new TournamentController.TournamentWrapper();
		tw.tournament = tournament;
		tw.isApplied = true;
		tw.isShowed = true;
		return JSON.serialize(tw);
	}


	@AuraEnabled
	public static void declineTeamInvitation(String teamId) {
		Team__c team = [select Id, Tournament__c from Team__c where Id=:teamId];
		delete team;
	}

}