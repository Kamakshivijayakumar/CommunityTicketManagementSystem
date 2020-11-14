@isTest
public class DataManager_OpportunityTest {
    @isTest static void testQueueable() {
        // SETUP
        DataManager_TestUtils.initAccs();
        
        // Create our Queueable instance
        DataManager_Opportunity oppsCreator = new DataManager_Opportunity();
        
   
        
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        System.enqueueJob(oppsCreator);
        Test.stopTest();
        
        System.assertEquals(934, [SELECT count() FROM Opportunity WHERE Name LIKE 'Opportunity for%']);
        
        
        
    }
}