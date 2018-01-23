@isTest
public class TestCsv {
    //to load the same data that will be visible inside all testMethods
    @testSetup
    public static void setup(){
        //load from csv accounts and contacts to insert with relations (insert operation will be applied)
        Test.loadData(Account.sObjectType, 'testAccounts');
        Test.loadData(Contact.sObjectType, 'testContacts');
    }
    
    public static testMethod void testCsv() {
        String jsonStr = '[';
        
        //to divide business logic queries and dml statements between test data and outside data
        /*
         * 
		*/
        Test.startTest();
        List<Account> accs = [select Id, Name, (select Id, Name from Contacts) from Account];
        //true, because we performed 1 soql query inside Test.startTest() and Test.stopTest()
        System.assert(Limits.getQueries()==1);
        Test.stopTest();
         /*
          * 
         */
        
        //Test.startTest() and Test.stopTest() block can be declared only 1 time per test method
        
        //true, because no soql query was performed outside start-stop test block
        System.assert(Limits.getQueries()==0);
        
        for (Account a : accs) {
            jsonStr += JSON.serialize(a)+',';
        }
        
        System.debug(jsonStr.removeEnd(',')+']');
        System.assert(accs.size()==3); 
    }
}