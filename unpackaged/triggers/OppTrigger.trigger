trigger OppTrigger on Opportunity (before insert, after insert, before update, after update) {
    List<Opportunity> opps = Trigger.new;
    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            System.debug('I am here');
            for (Opportunity opp : opps) {
                System.debug(opp.Amount);
                opp.Amount+=2;
                System.debug(opp.Amount);
            }
        }
    } else {
        
    }
}