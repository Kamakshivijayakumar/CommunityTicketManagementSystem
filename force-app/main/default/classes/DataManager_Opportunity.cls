public class DataManager_Opportunity implements Queueable {
    private map<string, map<string,id>> objectIdbyName;
    private map<string, Account> accountByName;
    
    // List of Opps to importand matching Accounts, initiated in the constructor
    public List<Opportunity> DTC_Opps;
    
    //List of Cases to import linked to Accounts
    public List<Case> DTC_ServiceCases;
    
    
    // The absolute days difference initiated at construction
    private Integer absDaysDiff;
    
    // =========================================================================
    //           Class Functions (constructor and execute)
    // =========================================================================
    
    public DataManager_Opportunity() {
        // Init Object IDs map
        objectIdbyName = DataManager_Utils.getObjectIdbyName();
        absDaysDiff = DataManager_Utils.getAbsDaysDiff();
        
        // Read DTC_Opps CSV
        DTC_Opps = createOpps(DataManager_Utils.getCsv('DTC_Opportunity'));
        
        //Read DTC_Cases CSV
        DTC_ServiceCases = createCases(DataManager_Utils.getCsv('DTC_Case'));
    }
    
    public void execute(QueueableContext context) {
        // Insert Opps
        insert DTC_Opps;
        
        // Insert Cases
        insert DTC_ServiceCases;
        
        // ==============================================
        // 					NEXT JOB!
        // ==============================================
        
        if(!test.isRunningTest()) {
            // 2 - Add DTC Opp Line Items and Histories
            System.enqueueJob(new DataManager_OpportunityRelated());
        }
    }
    
    // =========================================================================
    //           Opp Record Creation
    // =========================================================================
    
    public List<Case> createCases(String[] filelines){
        List<Case> serviceCases = new List<Case>();
        
        if (filelines != null){
            System.debug(filelines.size());
            for(Integer i=1; i<filelines.size(); i++)
            {
                String[] inputValues = filelines[i].split(',');
                
                // Replace classic Admin User by the actual admin name!
                String userName = inputValues[2];
                if (userName == 'Admin User') {
                    userName = UserInfo.getName();
                }
                
                Date ClosedDate = DataManager_Utils.string2Date(inputValues[9]);
                if (ClosedDate != null) {
                    // !!! -428, because the ref date for Case accounts is September 8 2016,
                    // so 428 days after Opps ref date, July 8 2015.
                    ClosedDate = ClosedDate.addDays(absDaysDiff-428);
                }
                
                String violation = '';
                if (inputValues[6] == 'TRUE') {
                    violation = 'Compliant';
                }
                else {
                    violation = 'Open Violation';
                }
                
                // Create Cases
                Case temp = new Case();
                temp.AccountId = objectIdbyName.get('Account').get(inputValues[1]);
                temp.Case_ExternalId__c = inputValues[0];
                temp.OwnerId = objectIdbyName.get('User').get(userName);
                //temp.Product__c = inputValues[4]; //Product_Family is used for product, as product is empty...
                temp.Product_Family_KB__c = inputValues[4];
                temp.Reason = inputValues[5];
                temp.SLAViolation__c = violation;
                temp.CSAT__c = integer.valueOf(inputValues[7]);
                temp.CreatedDate = DataManager_Utils.string2Date(inputValues[8]).addDays(absDaysDiff-428);
                temp.ClosedDate = ClosedDate;
                temp.Origin = inputValues[10];
                //skip Duration__c since its not a writeable field
                //temp.Duration__c = integer.valueOf(inputValues[11]);
                temp.Priority = inputValues[12];
                temp.FCR__c = boolean.valueOf(inputValues[13]);
                temp.Status = inputValues[14];
                temp.IsEscalated = boolean.valueOf(inputValues[15]);
                temp.Subject = inputValues[16];
                temp.SLA_Type__c = inputValues[17];
                //temp.Cost__c
                
                serviceCases.add(temp);
            }
        }
        else {
            System.debug('Error: Empty filelines for Cases!');
        }
        return serviceCases;
    }
    
    public List<Opportunity> createOpps(String[] filelines) {
        // Process CSV lines
        List<Opportunity> Opps = new List<Opportunity>();
        
        if (filelines != null) {
            for (Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = filelines[i].split(',');
                
                // Create Opps
                Opportunity temp = new Opportunity();
                temp.AccountId = objectIdbyName.get('Account').get(inputValues[0]);
                temp.Amount = integer.ValueOf(inputValues[1]);
                temp.CloseDate = DataManager_Utils.string2Date(inputValues[2]).addDays(absDaysDiff);
                temp.LeadSource = inputValues[3];
                temp.Name = inputValues[4];
                temp.OwnerId = objectIdbyName.get('User').get(inputValues[5]);
                temp.StageName = inputValues[6];
                temp.Type = inputValues[7];
                temp.CreatedDate = DataManager_Utils.string2Date(inputValues[8]).addDays(absDaysDiff);
                // !! ForecastCategory --> 9 !!
                temp.Opportunity_Source__c = inputValues[10];
                
                // Add the Opp to the list is it's in the biggest time frame (up to when we pick 1/3 of the opps only)
                if (DataManager_Utils.isInTimeframe(temp, DataManager_Utils.ROLLBACK_DAYS_THIRD)) {
                    Opps.add(temp);
                }
            }
        }
        else {
            System.debug('Error: Empty filelines for Opportunities!');
        }
        return Opps;
    }
}