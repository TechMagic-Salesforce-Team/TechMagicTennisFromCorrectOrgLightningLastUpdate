/**
 * Created by rostyk_haidukevych on 11/7/17.
 */
public class AURA_GameController {

	public Boolean currentPlayerInsertedScore {get;set;}
	public Boolean competitorInsertedScore {get;set;}

	@AuraEnabled
	public static String insertScore(String tournamentId, String currentPlayer, Game__c game) {
		Tournament__c tournament = [select Id, Name, Type__c, Format__c from Tournament__c where Id=:tournamentId];
		CallBackMessage callBackMessage = new CallBackMessage();
		Integer firstCompScore = (Integer)game.FirstCompetitorScore__c;
		Integer secondCompScore = (Integer)game.SecondCompetitorScore__c;
		if ((firstCompScore>=0 && secondCompScore >=0) && (firstCompScore != secondCompScore)) {
			game.FirstCompetitorScore__c = firstCompScore;
			game.SecondCompetitorScore__c = secondCompScore;
		} else {
			callBackMessage.type = 'Error';
			callBackMessage.message = 'Values must be different and at least >=0';
			return JSON.serialize(callBackMessage);
		}
		PlayerCookiePositionInGame positionInGame = playerPositionInCurrentGame(tournament, currentPlayer, game);
		if (positionInGame==PlayerCookiePositionInGame.FIRST_COMPETITOR) {
			game.FirstCompetitorAccept__c = true;
			game.SecondCompetitorAccept__c = false;
			update game;
			GameController.sendNotifications(game.FirstCompetitor__c, game.Id);
		} else if (positionInGame == PlayerCookiePositionInGame.SECOND_COMPETITOR) {
			game.FirstCompetitorAccept__c = false;
			game.SecondCompetitorAccept__c = true;
			update game;
			GameController.sendNotifications(game.SecondCompetitor__c, game.Id);
		} else {
			callBackMessage.type = 'ERROR';
			callBackMessage.message = 'Player from cookie is not present in current game';
		}
		callBackMessage.type = 'SUCCESS';
		callBackMessage.message = 'Game was successfully updated';
		return JSON.serialize(callBackMessage);
	}


	@AuraEnabled
	public static Boolean defineIfPlayerCanSubmitCurrentGame(Id tournamentId,  String currentPlayer, String gameId){
		Tournament__c tournament = [select Id, Name, Type__c, Format__c from Tournament__c where Id=:tournamentId];
		Game__c game = findGame(gameId);
		PlayerCookiePositionInGame positionInGame = playerPositionInCurrentGame(tournament, currentPlayer, game);
		if (positionInGame==PlayerCookiePositionInGame.FIRST_COMPETITOR) {
			if (game.SecondCompetitorAccept__c) {
				return true;
			}
		} else if (positionInGame==PlayerCookiePositionInGame.SECOND_COMPETITOR){
			if (game.FirstCompetitorAccept__c) {
				return true;
			}
		} else {
			return false;
		}
		return false;
	}


	@AuraEnabled
	public static Game__c findGame(String gameId) {
		return [select Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c from Game__c where Id=:gameId];
	}


	@AuraEnabled
	public static String submitScore(Tournament__c tournament, String currentPlayer, Game__c game) {
		CallBackMessage callBackMessage = new CallBackMessage();
		PlayerCookiePositionInGame positionInGame = playerPositionInCurrentGame(tournament, currentPlayer, game);
		if (positionInGame==PlayerCookiePositionInGame.FIRST_COMPETITOR) {
			if (game.SecondCompetitorAccept__c) {
				game.FirstCompetitorAccept__c = true;
				update game;
			} else {
				callBackMessage.type = 'ERROR';
				callBackMessage.message = 'You can not sumbit score of the game, that was inserted by you';
				return JSON.serialize(callBackMessage);
			}
		} else if (positionInGame==PlayerCookiePositionInGame.SECOND_COMPETITOR){
			if (game.FirstCompetitorAccept__c) {
				game.SecondCompetitorAccept__c = true;
				update game;
			} else {
				callBackMessage.type = 'ERROR';
				callBackMessage.message = 'You can not sumbit score of the game, that was inserted by you';
				return JSON.serialize(callBackMessage);
			}
		} else {
			callBackMessage.type = 'ERROR';
			callBackMessage.message = 'Player from cookie is not present in current game';
			return JSON.serialize(callBackMessage);
		}


		callBackMessage.type = 'SUCCESS';
		callBackMessage.message = 'Game was successfully updated';
		return JSON.serialize(callBackMessage);
	}


	private static PlayerCookiePositionInGame playerPositionInCurrentGame(Tournament__c tournament, String currentPlayer, Game__c game) {
		String firstCompetitorStr = ''+game.FirstCompetitor__c;
		String secondCompetitorStr = ''+game.SecondCompetitor__c;
		if (tournament.Format__c == '1 x 1') {
			if (firstCompetitorStr.contains(currentPlayer)) {
				return PlayerCookiePositionInGame.FIRST_COMPETITOR;
			} else if (secondCompetitorStr.contains(currentPlayer)){
				return PlayerCookiePositionInGame.SECOND_COMPETITOR;
			}
		} else {
			String playerLikeCurrent = '%'+currentPlayer+'%';
			PlayerTeam__c idOfTeamWhereCurrentPlayerIsPresent = [select Team__c from PlayerTeam__c where Player__c =: playerLikeCurrent
					and Team__c =: game.FirstCompetitor__c and Team__r.IsComplete__c = true];

			if (firstCompetitorStr.contains(idOfTeamWhereCurrentPlayerIsPresent.Team__c)) {
				return PlayerCookiePositionInGame.FIRST_COMPETITOR;
			} else if (secondCompetitorStr.contains(idOfTeamWhereCurrentPlayerIsPresent.Team__c)){
				return PlayerCookiePositionInGame.SECOND_COMPETITOR;
			}
		}

		return PlayerCookiePositionInGame.NOT_PRESENT;
	}


	public class CallBackMessage {
		String type;
		String message;
	}

}