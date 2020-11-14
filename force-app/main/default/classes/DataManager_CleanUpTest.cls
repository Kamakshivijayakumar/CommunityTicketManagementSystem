@isTest
public class DataManager_CleanUpTest {
    @isTest static void testQueueable() {
        // SETUP
        DataManager_TestUtils.initAccs();
        DataManager_TestUtils.initOpps();
		
        // Create our Queueable instances
        DataManager_CleanUp cleanUp = new DataManager_CleanUp();
        
        // startTest/stopTest block to force async processes to run
        Test.startTest();
        System.enqueueJob(cleanUp);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM Opportunity]);
        System.assertEquals(1001, [SELECT count() FROM Account WHERE Type != '']);
    }
}