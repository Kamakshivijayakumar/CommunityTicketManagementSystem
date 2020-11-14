public class DataManager_Utils {
    // =========================================================================
    //           Constant
    // =========================================================================
    
    // Constant for Opps rollback
    static public Integer ROLLBACK_DAYS_ALL =7*30;
    static public Integer ROLLBACK_DAYS_HALF = 12*30;
    static public Integer ROLLBACK_DAYS_THIRD = 15*30;
    // Constant for OppJiss rollback
    static public Integer ROLLBACK_HIST_DAYS = 12*30;
    // Constant for Event and Task rollback
    static public Integer ROLLBACK_SUB_DAYS = 1*30;
    
    // Quota Amount
    static public String quotaAmount = '1700000';
    
    // Reference Opportunity
    static public String refOpp = 'Opportunity for Ray1381';
    
    // Absolute days difference from Base date 2015-07-08 in which the CSV are based on
    static public Integer getAbsDaysDiff() {
        return DataManager_Utils.calculateDaysDifference(DataManager_Utils.string2Date('2015-07-08'));
    }
    
    // =========================================================================
    //           Date Utils
    // =========================================================================
    
	static public Integer calculateDaysDifference(Date refDate) {
        return refDate.daysBetween(date.today()); 
    }
    
    static public Date string2Date(String srcString) {
        try {
            if (srcString.length() > 7) {
                String yyyy=srcString.subString(0,4);
                String mm=srcString.subString(5,7);
                String dd=srcString.subString(8,10);
                
                Integer year = integer.valueOf(yyyy);
                Integer month = integer.valueOf(mm);
                Integer day = integer.valueOf(dd);
            
                return Date.newInstance(year, month, day);
            }
            else {
                return null;
            }
        }
        catch(Exception e) {
            System.debug('Can not convert '+srcString+'. Error: '+e.getMessage());
            return null;
        }
    }
    
    static public boolean isInTimeframe(Opportunity opp, Integer daysDiff) {
        if (opp != null) {
            Date limitDate = Date.today().addDays(-daysDiff);
            return (limitDate.daysBetween(opp.CloseDate) >= 0);
        }
        else {
            System.debug('Can not calculate timeframe belonging: empty opp object');
            return false;
        }
    }
    
    // =========================================================================
    //           Document Utils
    // =========================================================================

    static public Document saveDoc(String documentName, String dataflowBody, String ContentType, String Type) {
        // ---- Init Doc Object
        Document[] docs = [SELECT Id,Name FROM Document WHERE Name = :documentName];
        Document doc;
        
        // Use the existing doc if it already exist
        if (docs.size() != 0) {
            System.debug('Updating Doc '+documentName);
            doc = docs[0];
        }
        // If doesn't exist already, init new doc
        else {
            System.debug('Creating new Doc '+documentName);
            doc = new Document();
            doc.ContentType = ContentType;
            doc.Type = Type;
            doc.Name = documentName;
            doc.DeveloperName = documentName;
            doc.FolderId = DataManager_Utils.getTrailheadFolder();
        }

        // ----- Save Doc Body and upsert
        doc.Body = Blob.valueOf(dataflowBody);
        upsert doc;        
        System.debug(doc);
        
        return doc;
    }
    
    static private Id getTrailheadFolder() {
        Folder[] trailheadFolder = [SELECT Id FROM Folder WHERE Name = 'Trailhead Data Manager Documents'];
        
        if (trailheadFolder.size() != 0) {
            return trailheadFolder[0].Id;
        }
        else {
            System.debug('No "Trailhead Data Manager Documents" folder found!');
            // TODO: throw exception?
            return null;
        }
    }
    
    static public String[] getCsv(String name) {
        // Read DTC_Opps CSV
        StaticResource[] srs_DTC_Opps = [SELECT Body FROM StaticResource WHERE Name = :name];
        
        if (srs_DTC_Opps.size() > 0) {
            StaticResource sr_DTC_Opps = srs_DTC_Opps[0];
            blob tempB = sr_DTC_Opps.Body;
            String contentFile = tempB.toString();
            String[] filelines = contentFile.split('\n');
            
            if (filelines.size() > 1) {
                return filelines;
            }
            else {
                System.debug('CSV not parsed: no more than one line for '+name);
                return null;
            }
        }
        else {
            System.debug('CSV file not found in the static files: '+name);
            return null;
        }
    }
    
    // =========================================================================
    //           Object Utils
    // =========================================================================
    
    static public map<string, map<string,id>> getObjectIdbyName() {
        map<string, map<string,id>> objectIdbyName = new map<string, map<string,id>> ();
        
        // Get Users
		objectIdbyName.put('User', new map<string, id>());
        for(User u : [Select id, FirstName, LastName from User])
            objectIdbyName.get('User').put(u.FirstName + ' ' + u.LastName,u.Id);
        
        // Get Account
		objectIdbyName.put('Account', new map<string, id>());
        for(Account a : [Select id, Name from Account])
            objectIdbyName.get('Account').put(a.Name,a.Id);
        
        // Get Opps
		objectIdbyName.put('Opportunity', new map<string, id>());
        for(Opportunity o : [Select id, Name from Opportunity])
            objectIdbyName.get('Opportunity').put(o.Name,o.Id);
        
        // Get Cases
		objectIdbyName.put('Case', new map<string, id>());
        for(Case c : [Select id, Case_ExternalId__c from Case])
            objectIdbyName.get('Case').put(c.Case_ExternalId__c,c.Id);
        
        // Get PBE
		objectIdbyName.put('PBE', new map<string, id>());
        for(PricebookEntry PBE : [SELECT Id,UnitPrice FROM PricebookEntry])
            objectIdbyName.get('PBE').put(String.valueOf(PBE.UnitPrice),PBE.Id);
        
        return objectIdbyName;
    }
    
    static public map<string, Opportunity> getOppsByName() {
        map<string, Opportunity> oppsByName = new map<string, Opportunity> ();
        // Get Opps
        for(Opportunity o : [Select id, Name, CloseDate from Opportunity])
            oppsByName.put(o.Name,o);
        
        return oppsByName;
    }
}