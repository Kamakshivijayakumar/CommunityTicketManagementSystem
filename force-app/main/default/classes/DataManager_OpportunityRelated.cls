public class DataManager_OpportunityRelated implements Queueable {
    private map<string, map<string,id>> objectIdbyName;
    map<string, Opportunity> oppsByName;
	    
    // List of Opps to delete
    private List<Opportunity> DTC_Opp_toDel;
	    
    // List of OppLI to import, initiated in the constructor
    private List<OpportunityLineItem> DTC_OppLI;
	
    // List of OppHist to import, initiated in the constructor
    private List<OpportunityHistory__c> DTC_OppHists;
	
    // List of OppHist to import, initiated in the constructor
    // private List<CaseHistory__c> DTC_CaseHists;
    
    // The absolute days difference initiated at construction
    private Integer absDaysDiff;
    
    // =========================================================================
    //           Class Functions (constructor and execute)
    // =========================================================================
    
    public DataManager_OpportunityRelated() {
        // Init Object IDs map
        objectIdbyName = DataManager_Utils.getObjectIdbyName();
        oppsByName = DataManager_Utils.getOppsByName();
        absDaysDiff = DataManager_Utils.getAbsDaysDiff();
        
        // Init DTC_Opps to be deleted
        DTC_Opp_toDel = toDelOpps();
        
        // Read DTC_OppsLI CSV
        DTC_OppLI = createOLI(DataManager_Utils.getCsv('DTC_OpportunityLineItem'));
        
        // Read DTC_OppsHist CSV
        DTC_OppHists = createOH(DataManager_Utils.getCsv('DTC_OpportunityHistory'));
        
        // Read DTC_CaseHistory  CSV
        // DTC_CaseHists = createCH(DataManager_Utils.getCsv('DTC_CaseHistory'));
    }
    
    public void execute(QueueableContext context) {
        delete DTC_Opp_toDel;
        insert DTC_OppLI;
        insert DTC_OppHists;
        // insert DTC_CaseHists;
        
        // ==============================================
        // 					NEXT JOB!
        // ==============================================
        
        if(!test.isRunningTest()) {
            // 4 - Add DTC Events and Taks
            System.enqueueJob(new DataManager_Activity());
        }
    }
    
    // =========================================================================
    //           Opps Deletion
    // =========================================================================
    
    public List<Opportunity> toDelOpps() {
        List<Opportunity> opps = [SELECT Id, Name, CloseDate FROM Opportunity ORDER BY CloseDate DESC];
        List<Opportunity> opps_toDel = new List<Opportunity>();
		objectIdbyName.put('Opportunity', new map<string, id>());
        
        Integer i = 0;
        while(i < opps.size()-2) {
            Opportunity o = opps[i];
            
            objectIdbyName.get('Opportunity').put(o.Name,o.Id);
            
            // Add the Opp to the list is it's in the biggest time frame (up to when we pick 1/3 of the opps only)
            if (DataManager_Utils.isInTimeframe(o, DataManager_Utils.ROLLBACK_DAYS_ALL)) {
                i++;
            }
            else if (DataManager_Utils.isInTimeframe(o, DataManager_Utils.ROLLBACK_DAYS_HALF)) {
                opps_toDel.add(opps[i+1]);
                i+=2;
            }
            else if (DataManager_Utils.isInTimeframe(o, DataManager_Utils.ROLLBACK_DAYS_THIRD)) {
                opps_toDel.add(opps[i+1]);
                opps_toDel.add(opps[i+2]);
                i+=3;
            }
            // DEFAULT: go up
            else {
                i++;
            }
        }
        
        System.debug('Original opps: '+ opps.size());
        System.debug('toDel opps: '+ opps_toDel.size());
        
        return opps_toDel;
    }
    
    // =========================================================================
    //           OppLIs Creation
    // =========================================================================
	
    public List<OpportunityLineItem> createOLI(String[] filelines) {
        // Process CSV lines
        List<OpportunityLineItem> OppLI = new List<OpportunityLineItem>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputValues = filelines[i].split(',');
            try {
                // If the related Opp is not out of the timeframe (i.e. not present)
                OpportunityLineItem temp = new OpportunityLineItem();
                Id opp = objectIdbyName.get('Opportunity').get(inputValues[0]);
                
                if (opp != null) {
                    temp.OpportunityId = opp;
                    
                    Id PBEId = objectIdbyName.get('PBE').get(inputValues[1]+'.00');
                    if (PBEId != null) {
                        temp.PricebookEntryId = PBEId;
                        temp.Quantity = Integer.ValueOf(inputValues[2]);
                        temp.TotalPrice = Integer.ValueOf(inputValues[3]);
                        OppLI.add(temp);
                    }
                    else {
                        System.debug('No PBE found for: '+inputValues[1]+'.00');
                    }
                }
                else {
                    System.debug('Can not found Opp named: '+inputValues[0]);
                }
            }
            catch(Exception e) {
                System.debug('Error while creating OLI for: '+filelines[i]+'. Error: '+e.getMessage());
            }
        }
        
        return OppLI;
    }
    
    // =========================================================================
    //           OppHists Creation
    // =========================================================================
	
    public List<OpportunityHistory__c> createOH(String[] filelines) {
        // Process CSV lines
        List<OpportunityHistory__c> OppHists = new List<OpportunityHistory__c>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = filelines[i].split(',');
            String oppName = inputValues[0];
            
            // If the related Opp is not out of the timeframe (i.e. not present)
            if ((inputvalues.size() == 8) && (objectIdbyName.get('Opportunity').get(oppName) != null)) {
            	OpportunityHistory__c temp = new OpportunityHistory__c();
                temp.OpportunityId__c = objectIdbyName.get('Opportunity').get(oppName);
                temp.CloseDate__c = DataManager_Utils.string2Date(inputValues[1]).addDays(absDaysDiff);
                temp.Amount__c = integer.ValueOf(inputValues[2]);
                temp.CreatedDate = DataManager_Utils.string2Date(inputValues[3]).addDays(absDaysDiff);
                temp.StageName__c = inputValues[4];
                temp.ForecastCategory__c = inputValues[5];
                temp.Probability__c = integer.ValueOf(inputValues[6]);
                temp.ExpectedRevenue__c = integer.ValueOf(inputValues[7]);
                
                // Add the Opp to the list is it's in the time frame
                if (DataManager_Utils.isInTimeframe(oppsByName.get(oppName), DataManager_Utils.ROLLBACK_HIST_DAYS)) {
                    OppHists.add(temp); 
                }
            }
            else {
                System.debug('Error with csv for line:'+filelines[i]);
            }
        }
        
        return OppHists;
    }
    
    // =========================================================================
    //           CaseHists Creation
    // =========================================================================
	
    //public List<CaseHistory__c> createCH(String[] filelines) {
    //    // Process CSV lines
    //    List<CaseHistory__c> CaseHists = new List<CaseHistory__c>();
    //    for (Integer i=1;i<filelines.size();i++)
    //    {
    //        String[] inputvalues = filelines[i].split(',');
    //        
    //        System.debug(objectIdbyName.get('Case').get(inputValues[1]));
    //        System.debug(inputValues[1]);
    //        
    //        CaseHistory__c temp = new CaseHistory__c();
    //        temp.CaseId__c = objectIdbyName.get('Case').get(inputValues[1]);
    //        temp.CreatedDate = DataManager_Utils.string2Date(inputValues[3]).addDays(absDaysDiff).addDays(absDaysDiff-428);
    //        temp.Changed_Field__c = inputValues[4];
    //        temp.New_Value__c = inputValues[7];
    //        temp.Old_Value__c = inputValues[8];
    //        
    //        CaseHists.add(temp);
    //    }
    //    
    //    return CaseHists;
    //}
}