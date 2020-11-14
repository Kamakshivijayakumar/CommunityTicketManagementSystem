public class DataManager_Quota {
    public String quotaCsv;
    
    public DataManager_Quota(String quotaAmount) {
        // Init startdates
        Date now = Date.today();
        List<Date> startDates = new List<Date>();
        for(Integer i = -6; i <= 6; i++) {
            startDates.add(now.addMonths(i));
        }
        
        // Set Header
        quotaCsv = 'QuotaAmount,StartDate,OwnerName,Username\n';
        
        // Get Users and create a quota for each of them
        for(User u : [Select Username, Name from User WHERE Username LIKE 'trailhead%']) {
            for(Date startDate : startDates) {
                String startDateMonth = '0'+startDate.month();
                if (startDate.month() >= 10) {
                    startDateMonth = String.valueOf(startDate.month());
                }
                
            	quotaCsv += quotaAmount + ',' + startDate.year() + '-' + startDateMonth + '-01,' + u.Name + ',' + u.Username+'\n';
            }
        }
    }
    
    public Document getQuotaCsv() {
        String documentName;
        if(test.isRunningTest()) {
            documentName = 'DTC_Quota_Testing';
        }
        else {
            documentName = 'DTC_Quota';
        }
        return DataManager_Utils.saveDoc(documentName, quotaCsv, 'text/csv', 'csv');
    }
}