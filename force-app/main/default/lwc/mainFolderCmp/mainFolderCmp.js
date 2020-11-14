import { LightningElement,wire } from 'lwc';
import fetchProjects from '@salesforce/apex/TicketHandler.fetchProjects';
import TM from '@salesforce/resourceUrl/TicketMgmtResource';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import Name_Field from '@salesforce/schema/Project__c.Name';
import { refreshApex } from '@salesforce/apex';

export default class MainFolderCmp extends NavigationMixin(LightningElement) {

    @wire(fetchProjects) projectsList;
    projectFields=[Name_Field];
    ticketPageUrl;
    exp=2;
    folderLogo = TM + '/open_folder_120.png';
    newProjectFlag=false;
      
    connectedCallback(){
            console.log('inside connected callback');
        }

    get projectFlag(){
        return  false;
        }


     handleFolderClick(event){
        let selectedProjectId = event.currentTarget.dataset.item;
        this.ticketPageRef = { type: 'standard__webPage',  attributes: {  url : window.location.href+'ticketpage?projId='+selectedProjectId } };
        this[NavigationMixin.GenerateUrl](this.ticketPageRef)
        .then(url => this.url = url);
        this[NavigationMixin.Navigate](this.ticketPageRef);
   
      }



    newProjectMethod(){
        this.newProjectFlag=true;
     }

    newlyCreateProject(){
        this.newProjectFlag=false;
        refreshApex(this.projectsList);
     }

     closeModal(){
        this.newProjectFlag=false;
        }

}