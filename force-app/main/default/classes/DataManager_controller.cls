public class DataManager_controller {
    
    // =========================================================================
    //           Variables
    // =========================================================================
    
    public String error {get;set;}
    
    // UI used Boolean to check wether the data dates are up to date
    public Boolean is_up_to_date {get; set;}
    public Integer act_days_diff {get; set;}
    public String sref_date {get; set;}
    private Date refDate;
    
    // DTC Data checks
    public boolean clean_data {get; set;}
    // Object specifix
    public Integer accounts_count {get; set;}
    public Integer opps_count {get; set;}
    public Integer opplis_count {get; set;}
    public Integer opphists_count {get; set;}
    public Integer events_count {get; set;}
    public Integer tasks_count {get; set;}
    public Integer cases_count {get; set;}
    
    // Quota and Dataflow Files
    public DataManager_Quota quotaManager;
    public DataManager_Dataflow dataflowManager;
    public Document dataflowDoc;
    public Document quotaDoc;
    public List<String> dataflowNames;
    public String dataflowName {get; set;}
    
    
    // General Job ID for queued proccesses
    public ID job_id {get; set;}
    // Which Job is running ?
    public Boolean cleanup_isrunning {get; set;}
    public Boolean acc_isrunning {get; set;}
    public Boolean opp_isrunning {get; set;}
    public Boolean opprel_isrunning {get; set;}
    public Boolean activity_isrunning {get; set;}
    
    // Org URL
    public String orgUri{get; set;}
    
    // Actual Step in the UI
    public Integer step {get; set;}
    public String step1 {get; set;}
    public String step2 {get; set;}
    public String step3 {get; set;}
    
    
    // =========================================================================
    //           Constructor
    // =========================================================================
    
    public DataManager_controller() {
        // Update reference dates
        updateDTCRefs();
        
        // Update data based on current/past processes
        updateJobsData();
        
        // Init Files
        // TODO! Pass over the last time an update was made to the data: refDate (if != '2015-07-08').
        quotaManager = new DataManager_Quota(DataManager_Utils.quotaAmount);
        dataflowManager = new DataManager_Dataflow();
        dataflowManager.setLimitDate(refDate);
        
        // Get Org URL
        String forwardedHeader = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
        orgUri = (forwardedHeader == null) ? ApexPages.currentPage().getHeaders().get('host') : forwardedHeader;
        
        // Get UI initiated on Step 1
        setStep1();
    }
    
    
    // =========================================================================
    //           UI Steps Functions
    // =========================================================================
    
    public void setStep1() {
        resetSteps();
        step = 0;
        step1 = 'active';
    }
    
    public void setStep2() {
        resetSteps();
        step = 1;
        step1 = 'done';
        step2 = 'active';
    }
    
    public void setStep3() {
        resetSteps();
        step = 2;
        step1 = 'done';
        step2 = 'done';
        step3 = 'active';
    }
    
    private void resetSteps() {
        step1 = '';
        step2 = '';
        step3 = '';
    }
    
    
    // =========================================================================
    //           UI Data Utils
    // =========================================================================
    
    private void resetJobVars() {
        // If nothing is running, reset jobs variables
        job_id = null;            
        cleanup_isrunning = false;
        opp_isrunning = false;
        opprel_isrunning = false;
        activity_isrunning = false;
    }
    
    
    // =========================================================================
    //           UI Data Functions
    // =========================================================================
        
    // Check if a process is actually running
    public void updateJobsData() {
        resetJobVars();
        
        AsyncApexJob[] jobs = [Select ID, ApexClassID, JobType, MethodName, Status, ExtendedStatus, CreatedDate
                               From AsyncApexJob
                               ORDER BY CreatedDate DESC];
        
        // Creating Running boolean
        boolean isRunning = (jobs.size() != 0);
        
        // Processing the Job that is running
        if (isRunning) {
            AsyncApexJob job = jobs[0];
            
            // If not processing
            if ((job.Status != 'Processing')&&(job.Status != 'Queued')) {
                
                // If errored or aborted
                if (job.Status == 'Aborted' || job.Status == 'Failed') {
                    error = job.ExtendedStatus;
                    System.debug('An error occured for '+job + ': ' + error);
                }
                else {
                    // Update reference dates
                    updateDTCRefs();
                }
            }
            // If STILL processing
            else {
                // Save general job ID
                job_id = job.ID;
                
                // Find which job it is actually running
                ApexClass apexClass = [SELECT Name FROM ApexClass WHERE Id = :job.ApexClassID];
                if (apexClass.Name == 'DataManager_CleanUp') {
                    cleanup_isrunning = true;
                }
                else if (apexClass.Name == 'DataManager_Opportunity') {
                    opp_isrunning = true;
                }
                else if (apexClass.Name == 'DataManager_OpportunityRelated') {
                    opprel_isrunning = true;
                }
                else if (apexClass.Name == 'DataManager_Activity') {
                    activity_isrunning = true;
                }
                else {
                    // If none of the known Class is running a job, it's not related to the data manager.
                    job_id = null;
                }
            }
        }
    }
    
    
    // =========================================================================
    //           Data Utils
    // =========================================================================
    
    // Data Sanity Check Function that checks that there is OppHists and such...
    public void updateDTCRefs() {
        // Update Dates referentials
        updateRefDates();
        
        // Update Objects referentials
        accounts_count = [SELECT count() FROM Account];
        opps_count = [SELECT count() FROM Opportunity];
        opplis_count = [SELECT count() FROM OpportunityLineItem];
        opphists_count = [SELECT count() FROM OpportunityHistory__c];
        events_count = [SELECT count() FROM Event];
        tasks_count = [SELECT count() FROM Task];
        cases_count = [SELECT count() from Case];
        if (accounts_count > 0
           && opps_count > 0
           && opplis_count > 0
           && opphists_count > 0
           && events_count > 0
           && tasks_count > 0
           && cases_count > 0
           && act_days_diff == 0) {
            clean_data = true;
        }
        else {
            clean_data = false;
        }
    }
    
    
    public void updateRefDates() {
        Opportunity[] opps = [SELECT CloseDate FROM Opportunity WHERE Name = :DataManager_Utils.refOpp];

        if (opps.size() > 0) {
            Opportunity o = opps[0];
            refDate = o.CloseDate;
            sref_date = String.valueof(refDate.month()) + '/' + String.valueof(refDate.day()) + '/' + String.valueof(refDate.year());
            
            act_days_diff = DataManager_Utils.calculateDaysDifference(refDate);
            is_up_to_date = (act_days_diff == 0);
        }
        else {
            act_days_diff = -1;
            is_up_to_date = null;
        }
    }
    
    
    // =========================================================================
    //           Processing Init
    // =========================================================================
    
    // Start Data Processing
    public void startDataRefresh() {
        // Update jobs data
        updateJobsData();
        
        if (job_id == null) {
            // enqueue the jobs for processing
            
            // 0 - Clean-up the org
            job_id = System.enqueueJob(new DataManager_CleanUp());
            cleanup_isrunning = true;
        }
        else {
            System.debug('Another DataManager Process is already running.');
        }
    }
    
    
    // =========================================================================
    //           Quota Functions
    // =========================================================================
    
    public void updateQuota() {
        if (quotaDoc == null) {
            quotaDoc = quotaManager.getQuotaCsv();
        }
    }
    
    public Document getQuota() {
        if (quotaDoc != null) {
            return quotaDoc;
        }
        else {
            return new Document();
        }
    }
    
    
    // =========================================================================
    //           Dataflow Functions
    // =========================================================================
    
    
    public List<SelectOption> getDataflowNames() {
        List<SelectOption> dataflowOptions = new List<SelectOption>();
        for (String dataflow : dataflowManager.getDataflows()) {
            dataflowOptions.add(new SelectOption(dataflow, dataflow));
        }
        
        if (dataflowOptions.size() != 0) {
            return dataflowOptions;
        }
        else {
            return null;
        }
    }
    
    public void updateDataflowNames() {
        dataflowManager.pullDataflows();
    }
    
    public Document getDataflow() {
        if (dataflowDoc != null) {
            return dataflowDoc;
        }
        else {
            return new Document();
        }
    }
    
    public void updateDataflow() {
        if (dataflowName != null) {
            dataflowDoc = dataflowManager.getNewDataflow(dataflowName);
        }
        else {
            System.debug('No dataflowName set up yet.');
        }
    }
}