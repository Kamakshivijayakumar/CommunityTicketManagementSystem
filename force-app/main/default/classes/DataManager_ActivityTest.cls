@isTest
public class DataManager_ActivityTest {
    @isTest static void testQueueable() {
        // SETUP
        DataManager_TestUtils.initAccs();
        DataManager_TestUtils.initOpps();
		
        // Create our Queueable instances
        DataManager_Activity activityCreator = new DataManager_Activity();
        
        // startTest/stopTest block to force async processes to run
        Test.startTest();
        System.enqueueJob(activityCreator);
        Test.stopTest();
        
        System.assertEquals(241, [SELECT count() FROM Event WHERE What.Name LIKE 'Opportunity for%']);
        System.assertEquals(241, [SELECT count() FROM Task WHERE What.Name LIKE 'Opportunity for%']); 
    }
}