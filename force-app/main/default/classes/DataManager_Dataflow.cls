public class DataManager_Dataflow {
    private String org;
    private String sid;
    
    private map<String,String> dataflows;
    private String[] dataflowNames;
    private String dataflowName;
    public Map<String, Object> workflowDefinition;
    
    private String URL_DATAFLOW_API = '/insights/internal_api/v1.0/esObject/workflow';
    private String URL_LENS_APEX = '/analytics/wave/web/lens.apexp';
    
    private Datetime limitDate;
    
    public DataManager_Dataflow() {
        if (ApexPages.currentPage() != null) {
            // TODO: Auto ORG/pod detection
         	String forwardedHeader = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'); 
            org = 'https://' + ((forwardedHeader == null) ? ApexPages.currentPage().getHeaders().get('host') : forwardedHeader);
        }
        else {
            // For DEBUG
            org = 'https://eu6.salesforce.com';
        }
        
        // sid = UserInfo.getSessionId();
       	sid = getSessionIdFromLensApex();
        
        initDataflow();
    }
    
    public void setLimitDate(Date refDate) {
        if (refDate == null) {
            refDate = Date.today();
        }
        
        // Init limitDate for dataflow
        Datetime now = Datetime.now();
        Datetime rightAfterNow = now.addMinutes(10);
        Time nowTime = Time.newInstance(rightAfterNow.hour(), rightAfterNow.minute(), 0, 0);
        limitDate = Datetime.newInstance(refDate, nowTime);
    }
    
    // Init Dataflow list and data
    private void initDataflow() {
        dataflows = new map<String, String>();
        dataflowNames = new List<String>();
    }
    
    
    // =========================================================================
    //           Dataflow Tools
    // =========================================================================
    
    public List<String> getDataflows() {
        return dataflowNames;
    }
    
    public Document getNewDataflow(String name) {
        dataflowName = name;
        pullDataflows();
        pullWorkflowDefinition(dataflowName);
        updateWorkflowDefinition();
        return saveUpdatedDataflow();
    }
    
    // =========================================================================
    //           Dataflow Utils
    // =========================================================================
    
    public Map<String,String> pullDataflows() {
        System.debug('Updating Dataflow list');
        List<Object> response = httpGet(URL_DATAFLOW_API);
        initDataflow();
        
        if (response == null) {
            System.debug('An error occured!!');
            return null;
        }
        else {
            for(Object respJson : response) { 
                Map<String, Object> resultMap = (Map<String, Object>)respJson;
                
                // Check data integrity
                if (resultMap.get('name') == null || resultMap.get('_uid') == null) {
                    System.debug('Unexpected response:');
                    System.debug(resultMap);
                    
                    return null;
                }
                
                // Fill the lists of non-default Dataflow
                if (resultMap.get('name') != 'SalesEdgeEltWorkflow') {
                    dataflows.put((String) resultMap.get('name'), (String) resultMap.get('_uid'));
                    dataflowNames.add((String) resultMap.get('name'));
                }
            }
            
            return dataflows;
        }
    }
    
    private Map<String, Object> pullWorkflowDefinition(String dataflowName) {
        String dataflowId = dataflows.get(dataflowName);
        
        if (dataflowId != null) {
            List<Object> response = httpGet(URL_DATAFLOW_API + '/' + dataflowId + '/json');
            for(Object respJson : response) {
                Map<String, Object> dataflowJSON = (Map<String, Object>)respJson;
                workflowDefinition = (Map<String, Object>) dataflowJSON.get('workflowDefinition');
            }
            
            return workflowDefinition;
        }
        else {
            System.debug('No dataflow found for this name: '+dataflowName);
            return null;
        }
    }
    
    private Map<String, Object> updateWorkflowDefinition() {
        if (workflowDefinition == null) {
            System.debug('Error: workflowDefinition null');
            return null;
        }
        
        // Get Dataflow Edits from Static Ressources
        StaticResource sr_DataflowEdits = [SELECT Body FROM StaticResource WHERE Name = 'DataManager_SalesWave_WorkflowEdits'];
        blob tempB = sr_DataflowEdits.Body;
        String contentFile = tempB.toString();
        Map<String, Object> dataflowEdits = (Map<String, Object>)JSON.deserializeUntyped(contentFile);
        
        // ++ Do main edits if it doesn't exist already ++
        if (workflowDefinition.get('Compute_Historical_Trending_Fields_custom') == null) {
            // ------------ Innactive Users Hack ------------
            
            // Creating new FilterUser node
            Map<String, Object> filterUserParams = new Map<String, Object>();
            filterUserParams.put('filter', 'IsActive:EQ:true|false');
            filterUserParams.put('source', 'Extract_User');
            Map<String, Object> filterUser = new Map<String, Object>();
            filterUser.put('action', 'filter');
            filterUser.put('parameters', filterUserParams);
            
            // Replacing the node
            workflowDefinition.remove('Filter_User');
            workflowDefinition.put('Filter_User', filterUser);
            
            // ------------ Opp History Hack ------------
            
            // Delete Outdated Nodes
            workflowDefinition.remove('Extract_OpportunityHistory');
            //workflowDefinition.remove('computeTrending'); <---this node was renamed so delete the node below instead
            workflowDefinition.remove('Compute_Historical_Trending_Fields');
            
            // Add New Nodes (except Extract_OpportunityHistory_default that is updated everytime)
            // SOLUTION A - ONLY Custom
            Map<String, Object> computeTrending = (Map<String, Object>) dataflowEdits.get('Compute_Historical_Trending_Fields_custom');
            Map<String, Object> computeTrending_params = (Map<String, Object>) computeTrending.get('parameters');
            computeTrending_params.remove('source');
            computeTrending_params.put('source', 'Add_Unique_Sort_Key_to_OpportunityHistory');
            computeTrending.remove('parameters');
            computeTrending.put('parameters', computeTrending_params);
            workflowDefinition.put('Extract_OpportunityHistory', dataflowEdits.get('Extract_OpportunityHistory_custom'));
            workflowDefinition.put('Compute_Historical_Trending_Fields', computeTrending);
            // SOLUTION B - MERGE Custom and Default
            // workflowDefinition.put('Extract_OpportunityHistory_custom', dataflowEdits.get('Extract_OpportunityHistory_custom'));
            // workflowDefinition.put('computeTrending_custom', dataflowEdits.get('computeTrending_custom'));
            // workflowDefinition.put('computeTrending', dataflowEdits.get('computeTrending'));
            // workflowDefinition.put('Extract_OpportunityHistory', dataflowEdits.get('Extract_OpportunityHistory'));
        }
            
        // ++ Customize date filter on Extract_OpportunityHistory_default ++
        // Map<String, Object> OppHist = (Map<String, Object>) dataflowEdits.get('Extract_OpportunityHistory_default');
        // Map<String, Object> OppHist_params = (Map<String, Object>) OppHist.get('parameters');
        // OppHist_params.remove('complexFilterConditions');
        // OppHist_params.put('complexFilterConditions', 'CreatedDate >= '
        //                   + limitDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SS\'Z\''));
        // OppHist.remove('parameters');
        // OppHist.put('parameters', OppHist_params);
        
        // Remove the old one if it exists
        if (workflowDefinition.get('Extract_OpportunityHistory_default') != null) {
            workflowDefinition.remove('Extract_OpportunityHistory_default');
        }
        // workflowDefinition.put('Extract_OpportunityHistory_default', OppHist);
        
        // ------------ Edits Done! ------------
        
        return workflowDefinition;
    }
    
    private Document saveUpdatedDataflow() {
        if (workflowDefinition != null && dataflowName != null) {
            String dataflowJSON = JSON.serialize(workflowDefinition);
            
            String documentName;
            if(test.isRunningTest()) {
	            documentName = dataflowName + '_Testing';
            }
            else {
	            documentName = dataflowName + '_for_Trailhead';
            }
            
            return DataManager_Utils.saveDoc(documentName, dataflowJSON, 'application/json', 'json');
        }
        else {
            System.debug('No workflowDefinition to save or with no name.');
            return new Document();
        }
           
    }
    
    
    // =========================================================================
    //           API Utils
    // =========================================================================
    
    private List<Object> httpGet(String url) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        String response;
        
        req.setMethod('GET');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(org + url); 
        req.setHeader('Authorization', 'OAuth ' + sid);
     
        if(test.isRunningTest()) {
            String ressourceName;
            if (url == URL_DATAFLOW_API) {
                ressourceName = 'Test_WorkflowList';
            }
            else if (url.endsWith('/json')) {
                ressourceName = 'Test_WorkflowDefinition';
            }
            
            if (ressourceName != null) {
                StaticResource sr_DataflowEdits = [SELECT Body FROM StaticResource WHERE Name = :ressourceName];
                blob tempB = sr_DataflowEdits.Body;
                response = tempB.toString();
            }
            else {
                response = '{}';
            }
        } else {
            res = http.send(req);
            response = res.getBody();
        }
        
        System.debug(response);
        
        try {
            Map<String, Object> respObj = (Map<String, Object>)JSON.deserializeUntyped(response);
            
            if (respObj.get('result') != null) {
                return (List<Object>) respObj.get('result');
            }
            else {
                List<Object> errors = new List<Object>();
                errors.add(respObj.get('errorCode')); errors.add(respObj.get('errorDescription')); errors.add(respObj.get('message'));
                
                return errors;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    // This is a bit of a hack. Remove once dashboard public API is available
    // lens.apexp contains the OAuth token
    // UserInfo.getSessionId() is not a first-class token in unmanaged packages
    // so it will fail for the /insights... "private" API calls    
    public String getSessionIdFromLensApex() {
        String homeContent;
        PageReference home = new PageReference(org + URL_LENS_APEX);

        if(test.isRunningTest()) {
            homeContent = 'Some random string';
        } else {
        	blob homeblob = home.getContent();            
            homeContent = homeblob.toString();
        }
        Matcher m = Pattern.compile('\"OAuth \" [+] \"([\\w!.]+)').matcher(homeContent);
        
        if(m.find()) {
            return m.group(1);
        } else {
            return UserInfo.getSessionId();
        }
    }
}