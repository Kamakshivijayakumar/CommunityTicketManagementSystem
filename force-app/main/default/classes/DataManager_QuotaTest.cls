@isTest
public class DataManager_QuotaTest {
    @isTest static void testQueueable() {
        // Create our Queueable instances
        DataManager_Quota quotaGenerator = new DataManager_Quota('150000');
        System.assertNotEquals(0, quotaGenerator.quotaCsv.length());
        
        Document quotaCsv = quotaGenerator.getQuotaCsv();
        blob tempB = quotaCsv.Body;
        String contentFile = tempB.toString();
        String[] filelines = contentFile.split('\n');
        System.debug(filelines.size());
        System.assertEquals('DTC_Quota_Testing', quotaCsv.Name);
        System.assertEquals(248, filelines.size());
    }

}