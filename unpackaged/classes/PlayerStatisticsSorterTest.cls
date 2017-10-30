/**
 * Created by rostyk_haidukevych on 9/22/17.
 */
@IsTest
public class PlayerStatisticsSorterTest {

	static testmethod void singleEliminationTournamentStart(){
		List<Player__c> players = new List<Player__c>();
		Datetime dt = Datetime.now();
		Tournament__c setTournament = new Tournament__c(Name = 'setTournament', Format__c = '1 x 1', Status__c = 'Upcoming', Type__c = 'Single Elimination', StartDate__c = dt);
		insert setTournament;

		Player__c player = new Player__c(Name = 'Name1', Email__c = 'name1@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 0);
		players.add(player);

		player = new Player__c(Name = 'Name2', Email__c = 'name2@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 1);
		players.add(player);

		player = new Player__c(Name = 'Name3', Email__c = 'name3@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 5);
		players.add(player);

		player = new Player__c(Name = 'Name4', Email__c = 'name4@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 3);
		players.add(player);

		player = new Player__c(Name = 'Name5', Email__c = 'name5@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 2);
		players.add(player);


		player = new Player__c(Name = 'Name6', Email__c = 'name6@gmail.com', Status__c = 'Active', Password__c = '12345678', Rating__c = 4);
		players.add(player);


		insert players;

		System.assertEquals(players.size(), 6);


		List<PlayerTournament__c> playerTournaments = new List<PlayerTournament__c>();
		for (Player__c currentPlayer: players){
			playerTournaments.add(new PlayerTournament__c(Player__c = currentPlayer.Id, Tournament__c = setTournament.Id));
		}

		insert playerTournaments;

		System.assertEquals(playerTournaments.size(), 6);

		TournamentStarter ts = new TournamentStarter();
		ts.start(setTournament);


		System.assertEquals([select Id from Game__c].size(), 6);

	}

}