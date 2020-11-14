import { LightningElement,api,track } from 'lwc';
import FetchTicketDetailPageVal from '@salesforce/apex/TicketHandler.FetchTicketDetailPageVal';
import pickListVal from '@salesforce/apex/TicketHandler.gettingListPicklistValuesOfPriority';
import updateTicket from '@salesforce/apex/TicketHandler.updateTicket';
import emailIcon from '@salesforce/resourceUrl/emailIcon';
import taskIcon from '@salesforce/resourceUrl/taskIcon';
import attachmentIcon from '@salesforce/resourceUrl/attachmentIcon';
import notesIcon from '@salesforce/resourceUrl/notesIcon';
import editIcon from '@salesforce/resourceUrl/editIcon';
import releatedFiles from '@salesforce/apex/TicketHandler.releatedFiles';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import sendMailMethod from '@salesforce/apex/TicketHandler.sendMailMethod';
import fetchSendedEmailForTicket from '@salesforce/apex/TicketHandler.fetchSendedEmailForTicket';
import { deleteRecord } from 'lightning/uiRecordApi';
import  deletReleatedFile from '@salesforce/apex/TicketHandler.deletReleatedFile';
import  createCustomNoteRecord from '@salesforce/apex/TicketHandler.createCustomNoteRecord'
import listCustomNoteRecord from '@salesforce/apex/TicketHandler.listCustomNoteRecord';
import downloadAttachment from '@salesforce/apex/TicketHandler.DownloadAttachment';

export default class TicketDetailPageCmp extends LightningElement {

selectedProjectId=null;
selectedTicketId=null;
ticketDetailVal=null;
ticketName=null;
emailIcon=emailIcon;
taskIcon=taskIcon;
attachmentIcon=attachmentIcon;
notesIcon=notesIcon;
editIcon=editIcon;
listPriorityValues=[];
listStageValues=[];
listTypeValues=[];
listGroupValues=[];
ticketPriorityval='';
ticketStageVal='';
ticketSubjectVal='';
ticketTypeVal='';
ticketGroupVal='';
ticketDescriptionVal='';
ticketAsingUserName='';
ticketAsingUserId=null;
isOpenSubjectInputVal=false;
isOpenDescriptionInputVal=false;
isShowSubjectEditButton=false;
isOpenPriorityVal=false;
isShowPriorityVal=false;
isOpenStageVal=false;
isShowStageEditButton=false;
isShowTypeEditButton=false;
isOpenTypeVal=false;
isShowGroupEditButton=false;
isOpenGroupVal=false;
isShowDescriptionEditButton=false;
isOpenDescriptionInputVal=false;
isEmailDetailsOpen=false;
isAttachmentDetailsOpen=false;
isNoteDetailsOpen=false;
istaskDetailsOpen=false;
ticketId=null;
noteValue='';
isShowAttachmentval=false;
attachmentDownloadUrl='';
selectedAttachmentId=null;
isShowListAttachments=false;
ticketOwnerEmail='';
listOfEmailForTicket=null;
@track listAttachmentForTicket;
selectedRecords;
isShowUpdateAndCancelButton=false;
@track ticketListPerPage = [];
@track ticketsSizeFlag = false;
@track currentPageNo = 1;
ticketsPerPage = 5;
@track totalPages = [];
set_size = 5;
toEmailVal='';
emailSubjectVal='';
emailBobyVal='';
isShowEmailForm=false;
isShowlistOfEmailForTicket=false;
isShowNoteInput=false;
listNoteforTicket=null;
isShowListNotes=false;
ticketFirstName='';
ticketLastName='';
constructor(){
  super();
  let communityUrlMap = new URL(window.location.href).searchParams;
  this.selectedProjectId = communityUrlMap.get('projId');
  this.selectedTicketId = communityUrlMap.get('tktId');
  this.fetchTicketDetailsFunc();
  this.gettingOwnerNames();
  this.getRelatedFiles();
  this.isShowUpdateAndCancelButton=true;
}


fetchTicketDetailsFunc = async() => {
    await FetchTicketDetailPageVal({ticketName:this.selectedTicketId})
    .then(result =>{
        this.ticketDetailVal = result; 
        this.ticketId=this.ticketDetailVal.Id;
        this.ticketName=this.ticketDetailVal.Name;
        this.ticketFirstName=this.ticketDetailVal.AssignTo__r.FirstName;
        this.ticketLastName=this.ticketDetailVal.AssignTo__r.LastName;        
        this.ticketPriorityval=this.ticketDetailVal.Priority__c;
        this.ticketStageVal=this.ticketDetailVal.Stage__c;
        this.ticketSubjectVal=this.ticketDetailVal.Subject__c;
        this.ticketTypeVal=this.ticketDetailVal.Type__c;
        this.ticketGroupVal=this.ticketDetailVal.Group__c;
        this.ticketDescriptionVal=this.ticketDetailVal.Description__c;
        this.ticketAsingUserId=this.ticketDetailVal.AssignTo__c;
        this.ticketAsingUserName=this.ticketDetailVal.AssignTo__r.Name;
        this.ticketOwnerEmail=this.ticketDetailVal.AssignTo__r.Email;
        this.getListNotesForTicket();
        this.fetchemails();
 
     })
    .catch(error =>{});
    }

 gettingOwnerNames = async=>{
        pickListVal({objectName:'Ticket__c',fieldName:'Priority__c'}).then(result=>{
                var resultlist=result;
                for( var i=0;i<resultlist.length;i++){
                this.listPriorityValues = [...this.listPriorityValues ,{value:resultlist[i] ,label: resultlist[i]} ]; 
             }}).catch(error=>{ });

        pickListVal({objectName:'Ticket__c',fieldName:'Stage__c'}).then(result=>{
                var resultlist=result;
                for( var i=0;i<resultlist.length;i++){
                this.listStageValues = [...this.listStageValues ,{value:resultlist[i] ,label: resultlist[i]} ];               
              }}).catch(error=>{});
                  
        pickListVal({objectName:'Ticket__c',fieldName:'Type__c'}).then(result=>{
              var resultlist=result;
              for( var i=0;i<resultlist.length;i++){
              this.listTypeValues = [...this.listTypeValues ,{value:resultlist[i] ,label: resultlist[i]} ];   
            }}).catch(error=>{});
              
        pickListVal({objectName:'Ticket__c',fieldName:'Group__c'}).then(result=>{
              var resultlist=result;
              for( var i=0;i<resultlist.length;i++){
              this.listGroupValues = [...this.listGroupValues ,{value:resultlist[i] ,label: resultlist[i]} ];                   
              }}).catch(error=>{});
              
        }



  fetchemails=async=>{
      fetchSendedEmailForTicket({ticketId:this.ticketId}).then(result=>{
          let listOfEmail=result;
          this.listOfEmailForTicket=[];
          if(listOfEmail.length>0) {
                 for(let i=0;i<listOfEmail.length;i++){
                        let emailCreatedDate=new Date(listOfEmail[i].CreatedDate);
                        let createDate=emailCreatedDate.toString().split('(')[0];
                        listOfEmail[i].CreatedDate=createDate;
                     } 
               this.listOfEmailForTicket=listOfEmail;
              this.isShowlistOfEmailForTicket=false;
              }
          else  this.isShowlistOfEmailForTicket=true;
        }).cath(error=> { alert('Emails are not Fetch') });

      }


  updateTicketRecordFun=async=>{
       updateTicket({id:this.selectedTicketId,assingUserId:this.ticketAsingUserId,ticketName:this.ticketName,subject:this.ticketSubjectVal,description:this.ticketDescriptionVal,priority:this.ticketPriorityval,stage:this.ticketStageVal,typeVal:this.ticketTypeVal,groupVal:this.ticketGroupVal})
        .then(result=>{
                        var updateticket=result;
                        this.fetchTicketDetailsFunc();
                        this.isOpenDescriptionInputVal=false;
                        this.isOpenSubjectInputVal=false;
                        this.isShowSubjectEditButton=false;
                        this.isShowPriorityVal=false;
                        this.isOpenPriorityVal=false;
                        this.isShowStageEditButton=false;
                        this.isOpenStageVal=false;
                        this.isShowTypeEditButton=false;
                        this.isOpenTypeVal=false;
                        this.isShowGroupEditButton=false;
                        this.isOpenGroupVal=false;
                        this.isShowDescriptionEditButton=false;
                        this.isOpenDescriptionInputVal=false;
                                  this.isShowUpdateAndCancelButton=true;
          })
        .catch(error=>{
                      alert('Ticket is not Update');
              })
     }

  sendEmailFuc= async => {
    sendMailMethod({mMail:this.toEmailVal,mSubject:this.emailSubjectVal,mbody:this.emailBobyVal,fromEmail:this.ticketOwnerEmail,relatedId:this.ticketId})
      .then(result=> {
                      this.isShowEmailForm=false;
                      this.toEmailVal='';
                      this.emailSubjectVal='';
                      this.emailBobyVal='';
                      alert('Email is Successfully Sended');
                      this.fetchemails();
            })
      .catch(error => {  });

  }


      
  downloadAttachmentFile= async=>{
    downloadAttachment({DownloadAttachmentID:this.selectedAttachmentId})  
      .then(result=>{
                    this.attachmentDownloadUrl=result;
         })
      .catch(error=>{
      alert(error);
         });

  }

  CreateNewNote = async => {
    createCustomNoteRecord({noteVal:this.noteValue,ticketId:this.ticketId})
      .then(result =>{
                  this.getListNotesForTicket();
                  this.isShowNoteInput=false;
                  this.noteValue='';
         })
      .catch(error=>{
    alert('note is not Create');
        });
   }

  getListNotesForTicket= async=>{
    listCustomNoteRecord({ticketId:this.ticketId})
      .then(result =>{
                    this.listNoteforTicket=result;
                    if(this.listNoteforTicket.length>0) 
                    {
                       for(let i=0;i<this.listNoteforTicket.length>0;i++)  
                          {
                            let noteCreatedDate=new Date(this.listNoteforTicket[i].CreatedDate);
                            let createDate=noteCreatedDate.toString().split('(')[0];
                            this.listNoteforTicket[i].CreatedDate=createDate;
                          }
                       this.isShowListNotes=true;
                    }
                  else this.isShowListNotes=false;
                  })

        .catch(error=>{
               alert('error while fetching notes');
           });

   }


  inputSubjectAndDescriptionMethod(event){
        var eventName=event.target.name;
        if(eventName=='descriptionVal') this.ticketDescriptionVal=event.currentTarget.value;
        if(eventName=='subjectVal') this.ticketSubjectVal=event.currentTarget.value;
  }

    showEditButton(){
        this.isShowSubjectEditButton=true;
    }

  showOffEditButton(){
      this.isShowSubjectEditButton=false;
  }

  openSubjectInputMethod(){
      this.isOpenSubjectInputVal=true;
      this.isShowUpdateAndCancelButton=false;
  }

  showPriorityEditButton(){
    this.isShowPriorityVal=true;
  }

  showOffPriorityEditButton(){
    this.isShowPriorityVal=false;
  }

  openPriorityComboboxMethod(){
      this.isOpenPriorityVal=true;
      this.isShowUpdateAndCancelButton=false;
  }

  showStageEditButton(){
      this.isShowStageEditButton=true;
  }

  showOffStageEditButton(){
      this.isShowStageEditButton=false;
  }

  openStageComboboxMethod(){
      this.isOpenStageVal=true;
      this.isShowUpdateAndCancelButton=false;
  }

  showTypeEditButton(){
      this.isShowTypeEditButton=true;
  }

  showOffTypeEditButton(){
      this.isShowTypeEditButton=false;
  }

  openTypeComboboxMethod(){
      this.isOpenTypeVal=true;
      this.isShowUpdateAndCancelButton=false;
  }

  showGroupEditButton(){
      this.isShowGroupEditButton=true;
  }

  showOffGroupEditButton(){
      this.isShowGroupEditButton=false;
  }

  openGroupComboboxMethod(){
      this.isOpenGroupVal=true;
      this.isShowUpdateAndCancelButton=false;
  }

  showDescriptionButton()
  {
      this.isShowDescriptionEditButton=true;
  }

  showOffDescriptionButton(){
      this.isShowDescriptionEditButton=false;
  }

  openDescriptionInputMethod(){
      this.isOpenDescriptionInputVal=true;
      this.isShowUpdateAndCancelButton=false;
  }



    handleTicketChange(event){
        var eventName=event.target.name;
        if(eventName=='priority')   this.ticketPriorityval=event.currentTarget.value;
        else if(eventName=='stage') this.ticketStageVal=event.currentTarget.value;
        else  if(eventName=='type') this.ticketTypeVal=event.currentTarget.value;
        else if(eventName=='group') this.ticketGroupVal=event.currentTarget.value;

    }

 updateTicketMethod(){
      this.updateTicketRecordFun();
      this.isShowUpdateAndCancelButton=true;
    }

 cancelUpdateTicketMethod(){
        
      this.fetchTicketDetailsFunc();
      this.isOpenDescriptionInputVal=false;
      this.isOpenSubjectInputVal=false;
      this.isShowSubjectEditButton=false;
      this.isShowPriorityVal=false;
      this.isOpenPriorityVal=false;
      this.isShowStageEditButton=false;
      this.isOpenStageVal=false;
      this.isShowTypeEditButton=false;
      this.isOpenTypeVal=false;
      this.isShowGroupEditButton=false;
      this.isOpenGroupVal=false;
      this.isShowDescriptionEditButton=false;
      this.isOpenDescriptionInputVal=false;
      this.isShowUpdateAndCancelButton=true;
      this.fetchemail();
          
  }


  openHomePage(event){
    var eventName=event.currentTarget.name;
    var communityPathArray=  window.location.pathname.split('/');
    var communityTicketPath = '';
    for (var key in communityPathArray) {
       if(key == communityPathArray.length-1)  break;
       communityTicketPath += communityPathArray[key];
       communityTicketPath += "/";
    }
    if(this.selectedProjectId) if(eventName=='ticketPage') communityTicketPath += 'ticketpage?projId='+this.selectedProjectId;
      window.open(communityTicketPath,'_self');
  }


  openEmailTab(){
      var  conList = this.template.querySelectorAll('li');
      for (let i = 0; i < conList.length; i++){
              let indvRow = conList[i];
              let indvRowId = conList[i].getAttribute('id');  
              if(indvRow!=null){
                if(indvRowId.includes('email'))   indvRow.classList.add("slds-is-active");
                else  indvRow.classList.remove("slds-is-active");
               }
              this.isEmailDetailsOpen=false;
              this.isAttachmentDetailsOpen=false;
              this.isNoteDetailsOpen=false;
              this.istaskDetailsOpen=false;

         }
    }



  openAttachmentTab(){
      var  conList = this.template.querySelectorAll('li');
      for (let i = 0; i < conList.length; i++){
            let indvRow = conList[i];
            let indvRowId = conList[i].getAttribute('id');  
            if(indvRow!=null){
                if(indvRowId.includes('attachment'))   indvRow.classList.add("slds-is-active");
                else  indvRow.classList.remove("slds-is-active");
                    
              }
         }
            this.isEmailDetailsOpen=true;
            this.isAttachmentDetailsOpen=true;
            this.isNoteDetailsOpen=false;
            this.istaskDetailsOpen=false;


  }

    openNoteTab(){
      var  conList = this.template.querySelectorAll('li');
      for (let i = 0; i < conList.length; i++){
        let indvRow = conList[i];
        let indvRowId = conList[i].getAttribute('id');  
        if(indvRow!=null){
            if(indvRowId.includes('note'))   indvRow.classList.add("slds-is-active");
            else  indvRow.classList.remove("slds-is-active");
           }
        }
      this.isEmailDetailsOpen=true;
      this.isAttachmentDetailsOpen=false;
      this.isNoteDetailsOpen=true;
      this.istaskDetailsOpen=false;

      }


    openTaskTab(){
        var  conList = this.template.querySelectorAll('li');
        for (let i = 0; i < conList.length; i++){
          let indvRow = conList[i];
          let indvRowId = conList[i].getAttribute('id');  
          if(indvRow!=null){
            if(indvRowId.includes('task'))   indvRow.classList.add("slds-is-active");
            else  indvRow.classList.remove("slds-is-active");
          }
        }
        this.isEmailDetailsOpen=true;
        this.isAttachmentDetailsOpen=false;
        this.isNoteDetailsOpen=false;
        this.istaskDetailsOpen=true;


      }


  // Getting releated files of the current record
  getRelatedFiles = async=> {
    releatedFiles({idParent: this.selectedTicketId})
      .then(data => {
              this.listAttachmentForTicket = data;
              if(this.listAttachmentForTicket===null) this.isShowListAttachments=false;
              else  if(this.listAttachmentForTicket.length>0) { this.isShowListAttachments=true;
              this.totalPages=[];
              this.setPages(this.listAttachmentForTicket);  
              this.pageData(); 
              }})
     .catch(error => {});
  }

    handleUploadAttachmentIsFinished(){
          this.getRelatedFiles();
          this.isShowListAttachments=true;
    }


   get acceptedFormats() {
          return ['.pdf', '.png'];
    }

      

  openAttachmentFile(event){
      this.isShowAttachmentval=true;
      this.selectedAttachmentId=event.currentTarget.dataset.value;
      this.downloadAttachmentFile();
  }

      
    closeModal(){
        this.isShowAttachmentval=false;
        this.isShowEmailForm=false;
    }




    get pagesList() {
          let mid = Math.floor(this.set_size / 2) + 1;
          if (this.currentPageNo > mid)   return this.totalPages.slice(this.currentPageNo - mid, this.currentPageNo + mid - 1);
          return this.totalPages.slice(0, this.set_size);
     }

    setPages = (data) => {
          let numberOfPages = Math.ceil(data.length / this.ticketsPerPage);
          for (let index = 1; index <= numberOfPages; index++) {
                this.totalPages.push(index);
               }
    }

    pageData = () => {
            let currentPageNo = this.currentPageNo;
            let ticketsPerPage = this.ticketsPerPage;
            let startIndex = (currentPageNo * ticketsPerPage) - ticketsPerPage;
            let endIndex = (currentPageNo * ticketsPerPage);
            //return this.data.slice(startIndex, endIndex);
            this.attachmentListPerPage = this.listAttachmentForTicket.slice(startIndex,endIndex);
       }

    get hasPrev() {
          return this.currentPageNo > 1;
    }

    get hasNext() {
        return this.currentPageNo < this.totalPages.length
    }

    onNext = () => {
        ++this.currentPageNo;
        this.pageData();
    }

    onPrev = () => {
        --this.currentPageNo;
        this.pageData();
    }

    onPageClick = (e) => {
        this.currentPageNo = parseInt(e.currentTarget.dataset.id, 10);
        this.pageData();
    }

    openCreateEmailMthod(){
        this.isShowEmailForm=true;
    }

    inputValueForEmail(event){
        let eventName=event.target.name;
        if(eventName==='email') this.toEmailVal=event.currentTarget.value;
        else if(eventName==='subject') this.emailSubjectVal=event.currentTarget.value;
        else if(eventName==='body') this.emailBobyVal=event.currentTarget.value;
        
    }

    sendEmailMethodCall(){
      this.sendEmailFuc();
    }

    cancelEmailMethodCall(){
        this.isShowEmailForm=false;
        this.toEmailVal='';
        this.emailSubjectVal='';
        this.emailBobyVal='';
    }

    deletedAttachment(event){
        deletReleatedFile({id:event.currentTarget.value})
          .then(() => {
                this.dispatchEvent(
                new ShowToastEvent({
                title: 'Success',
                message: 'Attachment  deleted',
                variant: 'success'
                })
                );
                this.getRelatedFiles();
           })
          .catch(error => {
                this.dispatchEvent(
                new ShowToastEvent({
                title: 'Error deleting record',
                message: error.body.message,
                variant: 'error'
                })
                );
            });
     }


    showNoteInput(){
      this.isShowNoteInput=true;
    }

    getNoteInputValue(event){
      this.noteValue=event.currentTarget.value;
    }

    saveNoteValue(){
        if(this.noteValue!=='')    this.CreateNewNote();
        else alert('Please write some in Note');
     }


    closeNoteInputFiled(){
          this.isShowNoteInput=false;
          this.noteValue=null;
    }

  }