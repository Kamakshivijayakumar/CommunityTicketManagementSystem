@isTest
public class DataManager_controllerTest {
    @isTest static void controllerTest() {
        // SETUP
        DataManager_TestUtils.initOpps();
        
        DataManager_controller dm = new DataManager_controller();
        
        // UI Functions coverage
        dm.setStep2();
        dm.setStep3();
        dm.updateDTCRefs();
        dm.updateRefDates();
        
        dm.updateDataflowNames();
        List<SelectOption> dataflowNames = dm.getDataflowNames();
        System.assertEquals(1, dataflowNames.size());
        
        dm.updateDataflow();
        Document dataflowJson = dm.getDataflow();
        System.assertEquals(null, dataflowJson.Name);
        
        dm.updateQuota();
        Document quotaCsv = dm.getQuota();
        System.assertEquals('DTC_Quota_Testing', quotaCsv.Name);
    }
}