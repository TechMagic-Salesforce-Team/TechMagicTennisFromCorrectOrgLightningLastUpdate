/**
 * Created by rostyk_haidukevych on 1/23/18.
 */
@RestResource(urlMapping='/api/players/*')
global class PlayersApi {


	@HttpPost
	global static String postPlayers(){
		List<Player__c> players = new List<Player__c>();
		RestRequest request = RestContext.request;
		String headerAppFrom = request.headers.get('From');
		if (headerAppFrom != null && headerAppFrom.equals('3MVG9HxRZv05HarQDQcBkT_chF.RWVZHSA8FLCkfvwl8OYnEHdvQFtc3lBrlRYzmIRPqz5qzTqPMUUJq1q.xz')) {
			if (request.requestURI.contains('/post')) {
				try {
					//expect json in the next format : {"0":{"Id":"812ivsdhsi","Manager":true},"1":{"Id":"dasqw12123","Manager":false}}
					Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
					for (String key : jsonMap.keySet()) {
						Map<String, Object> playerUpdate = (Map<String, Object>)jsonMap.get(key);
						Player__c player = new Player__c(Id=String.valueOf(playerUpdate.get('Id')));
						player.IsManager__c = Boolean.valueOf(playerUpdate.get('Manager'));
						players.add(player);
					}
				} catch (Exception ex) {
					return '{\'success\':false, \'reason\':\''+ex.getMessage()+'\'}';
				}
			}
		}
		update players;
		return '{\'success\':true}';
	}

}