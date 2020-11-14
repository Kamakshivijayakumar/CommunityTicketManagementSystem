public class DataManager_TestUtils {
    static public void initAccs() {
        // Init Object IDs map
        map<string, map<string,id>> objectIdbyName = DataManager_Utils.getObjectIdbyName();
        
        // ------------------------- Add Accounts
        String[] filelines = DataManager_Utils.getCsv('DTC_Account');
        List<Account> DTC_Accs = new List<Account>();
        for (Integer i=1;i<filelines.size();i++)
        {
            Account temp = new Account();
            String[] inputvalues = filelines[i].split(',');
            
            // Replace classic Admin User by the actual admin name!
            String userName = inputValues[5];
            if (userName == 'Admin User') {
                userName = UserInfo.getName();
            }
            
            temp.Industry = inputValues[0];
            temp.Name = inputValues[1];
            temp.AccountSource = inputValues[2];
            temp.BillingCountry = inputValues[3];
            temp.BillingState = inputValues[4];
            temp.OwnerId = objectIdbyName.get('User').get(userName);
            temp.Type = inputValues[6];
            DTC_Accs.add(temp);  
        }
        
        insert DTC_Accs;
    }
    
    static public void initProduct() {
        // ------------------------- Add Products AND PricebookEntry
        String[] productFilelines = DataManager_Utils.getCsv('DTC_Product2');
        List<Product2> DTC_Products = new List<Product2>();
        for (Integer i=1;i<productFilelines.size();i++)
        {
            String[] productValues = productFilelines[i].split(',');
            Product2 temp = new Product2(
                Family = productValues[0],
            	Name = productValues[1]);
            DTC_Products.add(temp);  
        }
        insert DTC_Products;
        
        // ------------------------- Add PricebookEntry 
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('pricebookId');
        System.debug(pricebookId);
        String[] pbeFilelines = DataManager_Utils.getCsv('DTC_PriceBookEntry');
        List<PricebookEntry> Default_PricebookEntry = new List<PricebookEntry>();
        for (Integer i=0;i<DTC_Products.size();i++)
        {
            String[] pbeValues = pbeFilelines[i+1].split(',');
            PricebookEntry temp = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = DTC_Products[i].Id,
                UnitPrice = (Decimal) Integer.ValueOf(pbeValues[1]), IsActive = true);
            Default_PricebookEntry.add(temp);
        }
        insert Default_PricebookEntry;
    }
    
    static public void initOpps() {
        // Create our Queueable instance
        Integer absDaysDiff = DataManager_Utils.calculateDaysDifference(DataManager_Utils.string2Date('2015-07-08'));
        DataManager_Opportunity oppsCreator = new DataManager_Opportunity();
        insert oppsCreator.DTC_Opps;
        insert oppsCreator.DTC_ServiceCases;
    }
}