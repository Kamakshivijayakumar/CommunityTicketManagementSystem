import { LightningElement ,api } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
export default class VerticalNavigationCmp extends LightningElement {
    selectedProjectId;
    @api  sldsActive='tickets';

    constructor(){
        super();
        let communityUrlMap = new URL(window.location.href).searchParams;
        this.selectedProjectId = communityUrlMap.get('projId');
    }

    renderedCallback(){
        var  conList = this.template.querySelectorAll('li');
            for (let i = 0; i < conList.length; i++){
                    let indvRow = conList[i];
                    let indvRowId = conList[i].getAttribute('id');  
                    if(indvRow!=null){
                        if(this.sldsActive==='dashboard'){
                        if(indvRowId.includes('Dashboard')) {
                        indvRow.classList.add("slds-is-active");
                        }
                        else  indvRow.classList.remove("slds-is-active");
                            }
    else  if(this.sldsActive==='chatBot'){
    if(indvRowId.includes('ChatBot')) {
    indvRow.classList.add("slds-is-active");
    }
    else  indvRow.classList.remove("slds-is-active");
    }


    else  if(this.sldsActive==='settings'){
        if(indvRowId.includes('settings')) {
        indvRow.classList.add("slds-is-active");
            }
        else  indvRow.classList.remove("slds-is-active");
            }
                }
        }
        }


    TicketPage(){
        var communityPathArray=  window.location.pathname.split('/');
        var communityTicketPath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1)
                break;
            communityTicketPath += communityPathArray[key];
            communityTicketPath += "/";
        }
        communityTicketPath += 'ticketpage?projId='+this.selectedProjectId;
        window.open(communityTicketPath,'_self');
        
    }

    
    DashbordPage(){
             var communityPathArray=  window.location.pathname.split('/');
            var communityTicketPath = '';
            for (var key in communityPathArray) {
                if(key == communityPathArray.length-1)
                    break;
                communityTicketPath += communityPathArray[key];
                communityTicketPath += "/";
            }       
            communityTicketPath += 'dashboardpage?projId='+this.selectedProjectId;
            window.open(communityTicketPath,'_self');

    }

    chatBotPage(){



        var communityPathArray=  window.location.pathname.split('/');
        var communityTicketPath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1)
                break;
            communityTicketPath += communityPathArray[key];
            communityTicketPath += "/";
        }

        communityTicketPath += 'chatbotpage?projId='+this.selectedProjectId;
        window.open(communityTicketPath,'_self');



    }



    settingsPage(){
        var communityPathArray=  window.location.pathname.split('/');
        var communityTicketPath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1) break;
            communityTicketPath += communityPathArray[key];
            communityTicketPath += "/";
        }
        communityTicketPath += 'settingpage?projId='+this.selectedProjectId;
        window.open(communityTicketPath,'_self');

    }





}