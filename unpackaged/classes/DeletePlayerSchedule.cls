global class DeletePlayerSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        DateTime nowDateTime = DateTime.now();
        List<Player__c> players = [select Id,Name,CreatedDate from Player__c where Status__c = 'Not Active' and 
            CreatedDate <: nowDateTime.addHours(-24)
        ];
        delete players;
    }
}