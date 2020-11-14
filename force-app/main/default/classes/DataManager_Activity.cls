public class DataManager_Activity  implements Queueable {
    private map<string, map<string,id>> objectIdbyName;
    map<string, Opportunity> oppsByName;
    
    // List of Event to import, initiated in the constructor
    private List<Event> DTC_Events;
    
    // List of Tasks to import, initiated in the constructor
    private List<Task> DTC_Tasks;
    
    // List of Telephony to import, initiated in the constructor
    private List<Task> DTC_Telephony;
    
    // The absolute days difference initiated at construction
    private Integer absDaysDiff;
    
    // =========================================================================
    //           Class Functions (constructor and execute)
    // =========================================================================
    
    public DataManager_Activity() {
        // Init Object IDs map
        objectIdbyName = DataManager_Utils.getObjectIdbyName();
        oppsByName = DataManager_Utils.getOppsByName();
        absDaysDiff = DataManager_Utils.getAbsDaysDiff();
        
        // Read DTC_Event CSV & Process CSV lines
        DTC_Events = createEvents(DataManager_Utils.getCsv('DTC_Event'));
        
        // Read DTC_Task CSV & Process CSV lines
        DTC_Tasks = createTasks(DataManager_Utils.getCsv('DTC_Task'));
        
        // Read DTC_Telephony CSV & Process CSV lines
        DTC_Telephony = createTelephony(DataManager_Utils.getCsv('DTC_Telephony'));
    }
    
    public void execute(QueueableContext context) {
        insert DTC_Events;
        insert DTC_Tasks;
        insert DTC_Telephony;
        
        // ==============================================
        // 					Import done!
        // ==============================================
    }
    
    // =========================================================================
    //           Event Record Creation
    // =========================================================================
	
    public List<Event> createEvents(String[] filelines) {
        List<Event> Events = new List<Event>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = filelines[i].split(',');
            
            // If the related Opp is not out of the timeframe (i.e. not present)
            if (objectIdbyName.get('Opportunity').get(inputValues[0]) != null) {
                Date aDate = DataManager_Utils.string2Date(inputValues[4]).addDays(absDaysDiff);
                String oppName = inputValues[0];
                
                Event temp = new Event();
                temp.WhatId = objectIdbyName.get('Opportunity').get(oppName);
                temp.OwnerId = objectIdbyName.get('User').get(inputValues[1]);
                temp.CreatedDate = DataManager_Utils.string2Date(inputValues[2]).addDays(absDaysDiff);
                temp.LastModifiedDate = DataManager_Utils.string2Date(inputValues[3]).addDays(absDaysDiff);
                temp.ActivityDate = aDate;
                temp.StartDateTime = Datetime.newInstance(aDate, Time.newInstance(0, 0, 0, 0));
                temp.Subject = inputValues[5];
                temp.DurationInMinutes = integer.ValueOf(inputValues[6]);
            
                
                // Add the Opp to the list is it's in the time frame
                if (DataManager_Utils.isInTimeframe(oppsByName.get(oppName), DataManager_Utils.ROLLBACK_SUB_DAYS)) {
                    // Add the Event to the list
                    Events.add(temp);
                }
            }
        }
        
        return Events;
    }
    
    // =========================================================================
    //           Task Record Creation
    // =========================================================================
	
    public List<Task> createTasks(String[] filelines) {
        // Process CSV lines
        List<Task> Tasks = new List<Task>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = filelines[i].split(',');
            
            // If the related Opp is not out of the timeframe (i.e. not present)
            if (objectIdbyName.get('Opportunity').get(inputValues[0]) != null) {
                String oppName = inputValues[0];
                
                Task temp = new Task();
                temp.WhatId = objectIdbyName.get('Opportunity').get(oppName);
                temp.OwnerId = objectIdbyName.get('User').get(inputValues[1]);
                temp.Status = inputValues[2];
                temp.Priority = inputValues[3];
                temp.TaskSubtype = inputValues[4];
                temp.Type = inputValues[5];
                temp.CreatedDate = DataManager_Utils.string2Date(inputValues[6]).addDays(absDaysDiff);
                temp.ActivityDate = DataManager_Utils.string2Date(inputValues[7]).addDays(absDaysDiff);
                temp.LastModifiedDate = DataManager_Utils.string2Date(inputValues[8]).addDays(absDaysDiff);
                temp.Subject = inputValues[9];
                temp.Description = inputValues[10];
                
                // Add the Opp to the list is it's in the time frame
                if (DataManager_Utils.isInTimeframe(oppsByName.get(oppName), DataManager_Utils.ROLLBACK_SUB_DAYS)) {
                    // Add the Task to the list
                    Tasks.add(temp);
                }
            }
        }
        
        return Tasks;
    }
    
    // =========================================================================
    //           Telephony Record Creation
    // =========================================================================
	
    public List<Task> createTelephony(String[] filelines) {
        // Process CSV lines
        List<Task> Telephony = new List<Task>();
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = filelines[i].split(',');
            
            // Replace classic Admin User by the actual admin name!
            String userName = inputValues[1];
            if (userName == 'Admin User') {
                userName = UserInfo.getName();
            }
            
            Task temp = new Task();
            temp.WhatId = objectIdbyName.get('Case').get(inputValues[0]);
            temp.OwnerId = objectIdbyName.get('User').get(userName);
            temp.Status = inputValues[2];
            temp.Priority = inputValues[3];
            temp.TaskSubtype = inputValues[4];
            temp.CreatedDate = DataManager_Utils.string2Date(inputValues[5]).addDays(absDaysDiff-428);
            temp.ActivityDate = DataManager_Utils.string2Date(inputValues[6]).addDays(absDaysDiff-428);
            temp.LastModifiedDate = DataManager_Utils.string2Date(inputValues[7]).addDays(absDaysDiff-428);
            temp.Subject = inputValues[8];
            temp.CallDisposition = inputValues[9];
            temp.CallType = inputValues[10];
            temp.CallObject = inputValues[11];
            temp.CallDurationInSeconds = integer.valueOf(inputValues[12]);
                
            // Add the Task to the list
            Telephony.add(temp);
        }
        
        return Telephony;
    }
}