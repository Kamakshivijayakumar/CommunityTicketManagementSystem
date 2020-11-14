public class TicketHandler {
    public TicketHandler() {
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Project__c> fetchProjects(){
        return [SELECT Id,Name,Project_Number__c FROM Project__c]; 
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<Ticket__c> fetchTickets(String projectId){
        
        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId];
    }
    @AuraEnabled(cacheable=true)
    public static Project__c  fetchProjectId(String projectId){
        
        return [SELECT Id,Project_Number__c FROM Project__c WHERE Project_Number__c =: projectId];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Ticket__c> searchTickets(String projectId,string searchedTicket,list<string> AssignTo,list<string> priorityVal,list<string> stageValue,list<string> groupValue,list<string> typeValue){
       string projectIdTicket=projectId ;
        string searchedticketVal;
        string AssingUsers;
        string selectPriorityVal;
        string selectStageVAl;
        string selectGroupVal;
        string selectTypeVal;     
        
        
       if(searchedTicket!=null) searchedticketVal=' AND Name Like :'+searchedTicket+'%'; else searchedticketVal='';
        if(AssignTo.size()>0) AssingUsers= ' AND AssignTo__c =:'+AssignTo;   else   AssingUsers='';                                         
                if(stageValue.size()>0) selectStageVAl=' AND Stage__c=:'+stageValue; else selectStageVAl='';
                    if(priorityVal.size()>0) selectPriorityVal=' AND Priority__c =:'+priorityVal; else selectPriorityVal='';
                        if(groupValue.size()>0) selectGroupVal=' AND Group__c =:'+groupValue; else selectGroupVal='';
                        if(typeValue.size()>0)   selectTypeVal=' AND Type__c =:'+typeValue; else selectTypeVal='';

        string ticketQuery='SELECT Id,Name,Subject__c  FROM  Ticket__c  WHERE Project__r.Project_Number__c =:projectIdTicket '+searchedticketVal+AssingUsers+selectPriorityVal+selectStageVAl+selectGroupVal+selectTypeVal ;
  system.debug(ticketQuery);
        list<Ticket__c> tkt= Database.query(ticketQuery);
return tkt;
/*        

        if(searchedTicket!=null){
            if(AssignTo.size()>0){                                                     
                if(priorityVal.size()>0){
                    if(stageValue.size()>0){
                        if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                        
                      else  if(typeValue.size()>0)
                      return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND  Type__c=:typeValue];

                     return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue];
                    } 
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal];
             
                }
                
                return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND AssignTo__c =: AssignTo];
            }
            
            
            
           else  if(priorityVal.size()>0){
                    if(stageValue.size()>0){
                        if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%' AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                        
                      else  if(typeValue.size()>0)
                      return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Priority__c=:priorityVal AND Stage__c=:stageValue AND  Type__c=:typeValue];

                     return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Priority__c=:priorityVal AND Stage__c=:stageValue];
                    } 
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Priority__c=:priorityVal];
             
                }
            
            
                else   if(stageValue.size()>0){
                        if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                        
                      else  if(typeValue.size()>0)
                      return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Stage__c=:stageValue AND  Type__c=:typeValue];

                     return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Stage__c=:stageValue];
                    } 
            
            
                 else    if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'  AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'   AND Group__c=:groupValue];
                        }
                        
                      else  if(typeValue.size()>0)
                      return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Name Like : searchedTicket+ '%'   AND  Type__c=:typeValue];

            
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId AND Name Like : searchedTicket+ '%'];
            
        }
  else if(AssignTo.size()>0){
            if(priorityVal.size()>0){
                if(stageValue.size()>0)   
                {    
                    if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId   AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                      else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue AND  Type__c=:typeValue];
 
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal AND Stage__c=:stageValue];
                }
                return  [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId AND AssignTo__c =: AssignTo AND Priority__c=:priorityVal];
                
            }
           else      if(stageValue.size()>0)    {    
                    if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId   AND AssignTo__c =: AssignTo  AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                      else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo  AND Stage__c=:stageValue AND  Type__c=:typeValue];
 
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId AND AssignTo__c =: AssignTo  AND Stage__c=:stageValue];
                }
      
                         if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId   AND AssignTo__c =: AssignTo  AND Group__c=:groupValue];
                        }
                      else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND AssignTo__c =: AssignTo   AND  Type__c=:typeValue];
     
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  AssignTo__c =: AssignTo];
        }   
        
        else if(priorityVal.size()>0){
            if(stageValue.size()>0){
                    if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Priority__c=:priorityVal AND Stage__c=:stageValue AND Group__c=:groupValue];
                        }
                else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Priority__c=:priorityVal AND Stage__c=:stageValue AND  Type__c=:typeValue];

                return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Priority__c=:priorityVal AND Stage__c=:stageValue];
            }
           
                 else  if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Priority__c=:priorityVal  AND Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Priority__c=:priorityVal  AND Group__c=:groupValue];
                        }
                else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Priority__c=:priorityVal  AND  Type__c=:typeValue];

            
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Priority__c=:priorityVal];
            
        }
        
        
        
        
        
        else if(stageValue.size()>0){
             if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Stage__c=:stageValue AND Group__c=:groupValue AND Type__c=:typeValue];
                  
                 return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND   Stage__c=:stageValue AND Group__c=:groupValue];
                        }
            
                else  if(typeValue.size()>0)
            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId AND Stage__c=:stageValue AND  Type__c=:typeValue];

            return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Stage__c=:stageValue];
        
        }
        
        
            else if(groupValue.size()>0){
                        if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND   Group__c=:groupValue AND Type__c=:typeValue];
                    return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND Group__c=:groupValue];
                        }
                    
                     else   if(typeValue.size()>0)
                        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId  AND  Type__c=:typeValue];
                      
        return [SELECT Id,Name,Subject__c,Priority__c,Stage__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Group__c,Type__c FROM Ticket__c WHERE Project__r.Project_Number__c =: projectId];
*/
 
}
    
    
    
    @auraEnabled
    public static void  createNewTicket(string projectId,string subject){
        Project__c ins = [ select id,name from Project__c where Project_Number__c =: projectId];
        Ticket__c acc=new Ticket__c();
        acc.Project__c=ins.Id;
        acc.Subject__c=subject;
        insert acc;
        
        
    }
    @auraenabled
    public static list<User>  gettingOwnerName(){
        map<id,string> listOwner=new map<id,string>();
        list<User> listUser=[select id,Name FROM User];
        return listUser; 
    }
    
    @auraenabled 
    public static list<string> gettingListPicklistValuesOfPriority(String objectName,String fieldName){
        
        //String objectName = 'Ticket__c';
        //String fieldName ='Priority__c';
        list<string> ins=new list<string>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            ins.add(pickListVal.getValue());
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
        }    
        return ins;    
    }
    
    @AuraEnabled 
    public static Ticket__c  FetchTicketDetailPageVal(string ticketName)
    {
        Ticket__c ins=[select id,Name,Stage__c,Subject__c,Priority__c,AssignTo__r.Name,AssignTo__r.email,AssignTo__c,Type__c,Group__c,Description__c from Ticket__c where Ticket__c.Name=: ticketName];
      //  system.debug('Check '+ ins.AssignTo__r.Name);
//system.debug(ins.AssignTo__r.email);
        return ins;
    }
    
    @AuraEnabled 
    public static void updateTicket(id ticketId,string ticketName,Id assingUserId,string subject,string description,string priority,string stage,string typeVal,string groupVal){
        try{
            Ticket__c tkt=[select id,Name,Stage__c,Subject__c,Priority__c,AssignTo__c,Type__c,Group__c,Description__c from Ticket__c where Ticket__c.Name=: ticketName];
            tkt.AssignTo__c=assingUserId;
            tkt.Description__c=description;  
            tkt.Subject__c=subject;
            if(priority!=null)      tkt.Priority__c=priority;
             if(stage!=null)  tkt.Stage__c=stage;
            if(typeVal!=null)  tkt.Type__c=typeVal;
            if(groupVal!=null)  tkt.Group__c=groupVal;
            update tkt;   
        }
        catch(exception e){
            system.debug('check ones'+ e.getMessage()+e.getLineNumber()+e.getCause());
        }
        
    }
    
    
    @AuraEnabled
    public static list<ContentVersion> releatedFiles(string idParent){  
       list<id> lstConDocs = new list<id>();
       for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId  in (select id from Ticket__c where Ticket__c.Name =:idparent) ]) {
           lstConDocs.add(cntLink.ContentDocumentId);
        }  

        if(!lstConDocs.isEmpty())   return [SELECT Id, Title, ContentDocumentId,FileType,CreatedBy.Name,ContentSize FROM ContentVersion WHERE ContentDocumentId=:lstConDocs];
        
        else    return null;
    
    }
    
     @AuraEnabled 
    public static void deletReleatedFile(Id id){  
        try{
 list<ContentDocument> ins= [SELECT Id FROM ContentDocument WHERE Id=:id];
            delete ins;
        }
        catch(exception e){
                        system.debug('Attachment is not delete'+ e.getMessage());
        }
    }
    
    
    
 
 @AuraEnabled
     public static void sendMailMethod(String mMail ,String mSubject ,String mbody,string fromEmail, id relatedId){
         try{
     List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
  
     // Step 1: Create a new Email
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
       List<String> sendTo = new List<String>();
       OrgWideEmailAddress OEA=  [select id, Address,DisplayName from OrgWideEmailAddress];
       sendTo.add(mMail);
       mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
       mail.setReplyTo(OEA.Address); // change it with your mail address.
       mail.setSenderDisplayName(OEA.DisplayName); 
    
    // Step 4. Set email contents - you can use variables!
      mail.setSubject(mSubject);
      mail.setHtmlBody(mbody);
         mail.setWhatId(relatedId);
      mails.add(mail);
    
  // Step 6: Send all emails in the master list
     Messaging.sendEmail(mails);
         }
         catch(exception e){
             system.debug(e.getMessage());
             system.debug(e.getCause());
         }
             
             
             
   }   
    
    @AuraEnabled
    public static list<EmailMessage> fetchSendedEmailForTicket( id ticketId){
        return [SELECT Id, Subject,TextBody,CreatedDate,ToAddress,FromAddress FROM EmailMessage WHERE RelatedToId=:ticketId ORDER  BY CreatedDate desc ];
        
    } 


    @AuraEnabled
    public static void createCustomNoteRecord(string noteVal,string ticketId){
        customNote__c acc=new customNote__c();
        acc.note__c=noteVal;
       acc.TicketNum__c=ticketId;  
        insert acc;
    }

    
    @AuraEnabled
    public static list<customNote__c> listCustomNoteRecord(string ticketId){
system.debug(ticketId);
           list<customNote__c> ins= [select id,note__c,TicketNum__c,CreatedDate,CreatedBy.Name  from customNote__c where TicketNum__c=:ticketId ORDER  BY CreatedDate desc];
        for(customNote__c inst:ins){
system.debug(string.valueOf(inst.CreatedDate));
        }
        
        return ins;
        
    }
    
    
        @AuraEnabled
     public static string  DownloadAttachment(Id DownloadAttachmentID)
   {
    System.Debug('Old LV INitial :'+ DownloadAttachmentID);
      
    ContentVersion oldCV = [Select Id,Title from ContentVersion Where ContentDocumentId=:DownloadAttachmentID];
   System.Debug('Old LV INitial :'+ oldCV.Id);
   // System.Debug('Old Lock :'+ oldCV.Locked__c);
    String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
    String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download/'+oldCV.Id;
    system.debug('Download URL:' +URlDownload);
    return URlDownload; 
    } 
    
    @AuraEnabled 
    public static void createChatbotRecord(string message,string chatbotReciverUserId){
        try{
        communityChatBot__c ins=new communityChatBot__c();
        ins.chatbot_message__c=message;
        ins.chatbot_user__c=chatbotReciverUserId;
        insert ins;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    }
    
     @AuraEnabled 
    public static list<communityChatBot__c> listChatBotRecords(string sendedUserId,string chatbotReciverUserId){
   system.debug(chatbotReciverUserId);
           system.debug(sendedUserId);

        try{
            
            list<communityChatBot__c> listChatBot=[select id,createdById,createdDate,chatbot_message__c,chatbot_User__c from communityChatBot__C where (createdById=:sendedUserId and chatbot_User__c =:chatbotReciverUserId) or (createdById=:chatbotReciverUserId and chatbot_User__c =:chatbotReciverUserId)  order by CreatedDate asc ];
           if(listChatBot!=null)  return listChatBot;
            else return null;
            
        }
        catch(exception e){
            return null;
        }
        
    }
    
    
    @AuraEnabled 
    public static list<user> selectOwnerName(list<string>  userId){
     
    list<User> ins= [select id,name from User where Id=:userId ];
    return ins;
    }
    
    
}