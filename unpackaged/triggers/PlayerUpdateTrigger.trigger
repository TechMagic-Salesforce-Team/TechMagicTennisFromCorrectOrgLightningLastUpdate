trigger PlayerUpdateTrigger on Player__c (after update) {
    List<Player__c> oldPlayers = new List<Player__c>(Trigger.old);
    List<Player__c> newPlayers = new List<Player__c>(Trigger.new);
    
    
    
    List<String> docsMustBeDeletedIds = new List<String>();
    for (Integer i = 0; i < newPlayers.size(); i++){
        if (oldPlayers[i].Image__c!=null && oldPlayers[i].Image__c != newPlayers[i].Image__c){
            System.debug('found such player (updated document image)');
            String fileName = new Url(oldPlayers[i].Image__c).getFile();
            System.debug('fileName: '+fileName);
            System.debug('File name split: '+fileName.split('\\?')[1]);
            String idDocumentFromFileName = fileName.split('\\?')[1];
            System.debug('Id doc file name: '+idDocumentFromFileName);
            docsMustBeDeletedIds.add(idDocumentFromFileName);
        }
    }
    
    List<Document> docsMustBeDeleted = [select Id from Document where Id in: docsMustBeDeletedIds];
    delete docsMustBeDeleted;
}