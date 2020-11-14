import { LightningElement,track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import createChatbotRecord from '@salesforce/apex/TicketHandler.createChatbotRecord';
import listChatBotRecords from '@salesforce/apex/TicketHandler.listChatBotRecords';
import gettingOwnerName from '@salesforce/apex/TicketHandler.gettingOwnerName';

export default class ChatBotPageCmp extends LightningElement {
    listOfChatBotMessages=[];
    chatMessage='';
    chatbotReciverUserId='';
    listOfOwner='';
    isShowChatInputAndMessages=false;
    isShowChatMessages=false;
    @track intervalID=null;
    isScrollToDown=false;
    listOfUserForsearchItem=[];
    userName='';

    connectedCallback(){
        this.gettingOwnerNames();
    }

    gettingOwnerNames = async=>{
        gettingOwnerName()
            .then(result=> {
                this.listOfOwner=[];
                var listOfResultOwner=result;
                for(let key in listOfResultOwner){
                    var name=listOfResultOwner[key].FirstName+' '+listOfResultOwner[key].LastName;
                    this.listOfOwner=[...this.listOfOwner,{value:listOfResultOwner[key].Id,label:name.toLowerCase(),ischeck:false}];

                  }
                //this.listOfOwnerForsearchItem=this.listOfOwner;
                for(let j=0 ;j<this.listOfOwner.length;j++ )
                {
                    if(this.listOfOwner[j].value==USER_ID) { 
                        this.userName=this.listOfOwner[j].label;
                        this.listOfOwner.splice(j, 1); j--;
                    }
                // if(this.listOfOwner[j].label.includes('Platform Integration User'))   alert('Hello');//this.listOfOwner.splice(j, 1); j--;
                }

                this.listOfUserForsearchItem=this.listOfOwner;
                this.chatbotReciverUserId=this.listOfOwner[0].value;
                this.getListChatBotMessages();
                this.intervalID=setInterval( ()=>{ this.getListChatBotMessages()},5000);  

             })
            .catch({});
     }


    sendedMessage= asyn=> {
        if(this.chatMessage!=''){
            createChatbotRecord({message:this.chatMessage,chatbotReciverUserId:this.chatbotReciverUserId})
                .then(result=>{
                    //   if(this.intervalID!==null) clearInterval(this.intervalID);
                    this.getListChatBotMessages();
                    this.chatMessage='';
                  })
                .catch();
          }

        else{
            alert('Please Type new Message');
        }
    }

    getListChatBotMessages=async=>{
        listChatBotRecords({sendedUserId:USER_ID,chatbotReciverUserId:this.chatbotReciverUserId})
            .then(result=>{
                // this.listOfChatBotMessages=result;
                var listChatMessage=result;
                this.listOfChatBotMessages=[];
                this.isShowChatMessages=true;
                this.isShowChatInputAndMessages=true;
                this.isShowChatInputAndMessages=true;

                for(let i in  listChatMessage) {
                    let chatCreatedDate=new Date(listChatMessage[i].CreatedDate);
                    let createdDate=chatCreatedDate.toString().split('(')[0];
                    if(listChatMessage[i].CreatedById===USER_ID)   this.listOfChatBotMessages=[...this.listOfChatBotMessages,{createdDate:createdDate,chat:listChatMessage[i].chatbot_message__c,isSender:true}];
                    else this.listOfChatBotMessages=[...this.listOfChatBotMessages,{createdDate:createdDate,chat:listChatMessage[i].chatbot_message__c,isSender:false}];
                    
                 }
                    /*
                    if(this.isScrollToDown===false){
                    let ins=this.template.querySelector(".slds-scrollable_y");
                    alert(this.template.querySelector(".slds-scrollable_y").scrollHeight)
                    window.scrollTo(0,this.template.querySelector(".slds-scrollable_y").scrollHeight); 
                    this.isScrollToDown=true; 
                    }
                    */

                if(this.listOfChatBotMessages.length>15){ this.listOfChatBotMessages[19].isSender=true;
                    this.listOfChatBotMessages[1].isSender=true;
                 }

                for(let j in this.listOfOwner) if(this.chatbotReciverUserId===this.listOfOwner[j].value)   this.listOfOwner[j].ischeck=true; else this.listOfOwner[j].ischeck=false;
                for(let j in this.listOfUserForsearchItem) if(this.chatbotReciverUserId===this.listOfUserForsearchItem[j].value)   this.listOfUserForsearchItem[j].ischeck=true; else this.listOfUserForsearchItem[j].ischeck=false;


             })    
            .catch(error=>{
                this.isShowChatMessages=false;
                alert(error);
                if(this.intervalID!==null) window.clearInterval(this.intervalID);
            });
    }



    openHomePage(event){
        var eventName=event.currentTarget.name;
        var communityPathArray=  window.location.pathname.split('/');
        var communityHomePath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1) break;
            communityHomePath += communityPathArray[key];
            communityHomePath += "/";
        }
        window.open(communityHomePath,'_self');
        }


    selectedUserToChat(event){
        this.chatbotReciverUserId=event.currentTarget.dataset.id;
        this.isShowChatInputAndMessages=true;
        this.isScrollToDown=false;
        this.getListChatBotMessages();
        /*   let ins=this.template.querySelector(".scrolledCss");
        ins.scrollIntoView(0,this.template.querySelector(".scrolledCss").scrollHeight);*/
        if(this.intervalID!==null) window.clearInterval(this.intervalID);  this.intervalID=setInterval( ()=>{ this.getListChatBotMessages()},5000);  
     }
      
     
    getMessageValueMethod(event){
        this.chatMessage=event.currentTarget.value;
    }


    searchUseForChatrMethod(event){
        var searchUserName=event.currentTarget.value;
        var listOnwer=this.listOfUserForsearchItem;
        this.listOfOwner=[];
        for(var i=0;i<listOnwer.length;i++){
             if(listOnwer[i].label.includes(searchUserName.toLowerCase()))  this.listOfOwner.push(listOnwer[i]);
        
          }
        if(this.listOfOwner.length==0) this.listOfOwner=null;    
     }

}