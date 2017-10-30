public class PlayerStatisticsSorter {
    private static Map<Id, List<Player__c>> teamIdAndPlayersOfTeam = new Map<Id, List<Player__c>>();

    public static List<String> sortPlayersByStatistics(List<String> competitorIds, Tournament__c tournament){
        List<sObject> competitors;
        if (tournament.Format__c == '1 x 1') {
            System.debug('1 x 1');
            competitors = (List<Player__c>) [select Id, Rating__c from Player__c where Id in: competitorIds order by Rating__c desc];
        } else {
            System.debug('2 x 2');
            competitors = (List<Team__c>) [select Id, (select Player__c from PlayerTeams__r) from Team__c where Id in: competitorIds];
            Map<Id, Team__c> teams = new Map<Id, Team__c>([select Id, (select Player__c from PlayerTeams__r) from Team__c where Id in: competitorIds]);
            Map<Id, Player__c> playersMap = new Map<Id, Player__c>(
                    [select Id, Rating__c from Player__c where Id in
                    (select Player__c from PlayerTeam__c where Team__c in: teams.keySet())]
            );
            System.debug('teams'+teams);
            for (Team__c team: (List<Team__c>)competitors){
                List<Player__c> players = new List<Player__c>();
                for (PlayerTeam__c playerTeam: team.PlayerTeams__r){
                    players.add(playersMap.get(playerTeam.Player__c));
                }
                teamIdAndPlayersOfTeam.put(team.Id, players);
            }

            System.debug('teamIdAndPlayersOfTeam:'+teamIdAndPlayersOfTeam+',competitors'+competitors);
            for (Integer i = 0; i < competitors.size(); i++){
                for (Integer j = 0; j < competitors.size(); j++){
                    if (comparePlayers((Team__c)competitors.get(i), (Team__c)competitors.get(j))==1){
                        sObject competitor = competitors.get(i);
                        competitors.set(i, competitors.get(j));
                        competitors.set(j, competitor);
                    }
                }
            }
        }

        System.debug('competitors:'+competitors);
        List<String> ids = new List<String>();
        for (sObject comp: competitors) {
            ids.add(comp.Id);
        }
        System.debug(ids);
        return ids;
    }


    public static Integer comparePlayers(Team__c team1, Team__c team2){
        System.debug('compare');

        Double ratingOfFirstCompetitor = 0;
        Double ratingOfSecondCompetitor = 0;

        ratingOfFirstCompetitor  = (teamIdAndPlayersOfTeam.get(team1.Id).get(0).Rating__c + teamIdAndPlayersOfTeam.get(team1.Id).get(1).Rating__c) / 2.0;
        ratingOfSecondCompetitor  = (teamIdAndPlayersOfTeam.get(team2.Id).get(0).Rating__c + teamIdAndPlayersOfTeam.get(team2.Id).get(1).Rating__c) / 2.0;
        if (ratingOfFirstCompetitor > ratingOfSecondCompetitor) return 1;
        else if (ratingOfFirstCompetitor < ratingOfSecondCompetitor) return -1;
        else return 0;
    }
}