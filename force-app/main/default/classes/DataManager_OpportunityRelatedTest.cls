@isTest
public class DataManager_OpportunityRelatedTest {
    @isTest static void testQueueable() {
        // SETUP
        DataManager_TestUtils.initProduct();
        DataManager_TestUtils.initAccs();
        DataManager_TestUtils.initOpps();
        
        // Create our Queueable instances
        DataManager_OpportunityRelated oppRelatedCreator = new DataManager_OpportunityRelated();
        
        // startTest/stopTest block to force async processes to run
        Test.startTest();
        System.enqueueJob(oppRelatedCreator);
        Test.stopTest();
        
        System.assertEquals(706, [SELECT count() FROM Opportunity WHERE Name LIKE 'Opportunity for%']);
        System.assertEquals(387, [SELECT count() FROM OpportunityHistory__c]);
        System.assertEquals(true, [SELECT count() FROM OpportunityLineItem WHERE Opportunity.Name LIKE 'Opportunity for%'] > 1380);
    }
}