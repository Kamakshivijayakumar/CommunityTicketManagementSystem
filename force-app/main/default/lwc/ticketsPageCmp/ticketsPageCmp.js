import { LightningElement,wire,track } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import fetchTickets from '@salesforce/apex/TicketHandler.fetchTickets';
import searchTickets from '@salesforce/apex/TicketHandler.searchTickets';
import  createTicket  from '@salesforce/apex/TicketHandler.createNewTicket';
import fectchProjectId from '@salesforce/apex/TicketHandler.fetchProjectId';
import { refreshApex } from '@salesforce/apex';
import gettingOwnerName from '@salesforce/apex/TicketHandler.gettingOwnerName';
import pickListVal from '@salesforce/apex/TicketHandler.gettingListPicklistValuesOfPriority';
import  subject_Fiels from '@salesforce/schema/Ticket__c.Stage__c';

export default class TicketsPageCmp extends NavigationMixin(LightningElement) {
    selectedProjectId;
    searchOwnerVal='';
    searchProrityVal='';
    searchStageVal='';
    searchGroupVal='';
    searchTypeVal='';
    ticketsFields=[subject_Fiels];
    allTicketsList = [];
    @track ticketListPerPage = [];
    @track ticketsSizeFlag = false;
    @track currentPageNo = 1;
    ticketsPerPage = 5;
    @track totalPages = [];
    set_size = 5;
    searchingTickets=null;
    searchticketsSizeFlag=false;
    newTicketFlag=false;
    subjectValue='';
    listOfOwner=[];
    items=[];
    itemsOfPriorityList=[];
    listStageValues=[];
    ownerName=null;
    listPriorityVal=[];
    selectstageVal=[];
    projectIds=null;
    picklist=null;
    expanded = false;
    isOpenMoreFilters=false;
    listOwners=[];
    searchItemInOwnerfilter=null;
    firstItemInOwnerselectList=null;
    firstItemInStageSelectList=null;
    isSelectOnwerItem=false;
    isSelectStageItem=false;
    isSelectPriorityItem=false;
    lengthOfselectedOwnerName=null
    listOfOwnerForsearchItem=[];
    listOfStageForsearchItem=[];
    listOfPriortyValues=[];
    firstItemInPrioritySelectList=[];
    isLoading=false;
    listTypeValues=[];
    listGroupValues=[];
    listOfGroupForsearchItem=[];
    listOfTypeForsearchItem=[];
    isSelectTypeItem=false;
    firstItemInTypeSelectList='';
    selectGroupVal=[];
    selectTypeVal=[];
    firstItemInGroupSelectList='';
    isSelectGroupItem=false;


    constructor(){
        super();
        let communityUrlMap = new URL(window.location.href).searchParams;
        this.selectedProjectId = communityUrlMap.get('projId');
    }

    connectedCallback(){
        console.log('inside connect call back ticket');
        this.fetchTicketsFunc();
        this.gettingOwnerNames();
        this.fetchProjectIdFunc();
    }

    gettingOwnerNames = async=>{
        gettingOwnerName()
            .then(result=> {
                this.listOfOwner=[];
                var listOfResultOwner=result;
                for(var key in listOfResultOwner){
                    this.listOfOwner=[...this.listOfOwner,{Id:listOfResultOwner[key].Id,FirstName:listOfResultOwner[key].FirstName.toLowerCase(),LastName:listOfResultOwner[key].LastName.toLowerCase(),isCheck:false}];
                    // this.items = [...this.items ,{value:this.listOfOwner[key].id, label:this.listOfOwner[key].Name} ];                                   
                 }
                this.listOfOwnerForsearchItem=this.listOfOwner; 
             })
            .catch({});


        pickListVal({objectName:'Ticket__c',fieldName:'Priority__c'})
            .then(result=>{
            var picklist=result;
            for( var i=0;i<picklist.length;i++){
                this.itemsOfPriorityList = [...this.itemsOfPriorityList ,{value:picklist[i].toLowerCase() ,isCheck:false} ];                                   
             } 
            this.listOfPriortyValues=this.itemsOfPriorityList;
              })
            .catch(error=>{});


        pickListVal({objectName:'Ticket__c',fieldName:'Stage__c'})
            .then(result=>{
                this.picklist=result;
                for( var i=0;i<this.picklist.length;i++){
                        this.listStageValues = [...this.listStageValues ,{value:this.picklist[i].toLowerCase() , isCheck:false} ];   
                        this.listOfStageForsearchItem=this.listStageValues;
                    }
              })
            .catch(error=>{});


        pickListVal({objectName:'Ticket__c',fieldName:'Type__c'})
            .then(result=>{
                var resultlist=result;
                for( var i=0;i<resultlist.length;i++){
                    this.listTypeValues = [...this.listTypeValues ,{value:resultlist[i].toLowerCase() ,label: resultlist[i],isCheck:false} ];   
                    this.listOfTypeForsearchItem=this.listTypeValues;
                }                
            })
            .catch(error=>{});


        pickListVal({objectName:'Ticket__c',fieldName:'Group__c'})
            .then(result=>{
                var resultlist=result;
                for( var i=0;i<resultlist.length;i++){
                    this.listGroupValues = [...this.listGroupValues ,{value:resultlist[i].toLowerCase() ,label: resultlist[i],isCheck:false} ];    
                    this.listOfGroupForsearchItem=this.listGroupValues;               
                }                
            })
            .catch(error=>{});
 
     }


    fetchTicketsFunc = async() => {
       await fetchTickets({projectId: this.selectedProjectId})
        .then(result =>{
                this.allTicketsList = result;       
                if(this.allTicketsList.length === 0)  this.ticketsSizeFlag = true;
                else    this.ticketsSizeFlag=false;
                this.setPages(this.allTicketsList);  
                this.pageData();       
          })
        .catch(error =>{
              this.error = error;
              console.log('Error while fetching data => '+ this.error);
        });
     }

    fetchProjectIdFunc = async() => {
        await fectchProjectId({projectId: this.selectedProjectId})
            .then(result =>{
                this.projectIds = result; 
             })
            .catch(error =>{});
     }


    // Function for getting search ticket
    searchTicketsFunc = async() => {
        await searchTickets({projectId: this.selectedProjectId, searchedTicket:this.searchingTickets,AssignTo:this.listOwners,priorityVal:this.listPriorityVal,stageValue:this.selectstageVal,groupValue:this.selectGroupVal,typeValue:this.selectTypeVal })
            .then(result =>{
                this.allTicketsList = result;   
                if(this.allTicketsList.length === 0) this.searchticketsSizeFlag = true;
                else this.searchticketsSizeFlag=false;
                this.totalPages=[];
                this.setPages(this.allTicketsList);  
                this.pageData();       
             })
            .catch(error =>{
                this.error = error;
                console.log('Error while fetching data => '+ this.error);
             });
     }



    openHomePage(event){
        var eventName=event.currentTarget.name;
        var communityPathArray=  window.location.pathname.split('/');
        var communityHomePath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1)  break;
            communityHomePath += communityPathArray[key];
            communityHomePath += "/";
         }
        window.open(communityHomePath,'_self');
    }


    get pagesList() {
        let mid = Math.floor(this.set_size / 2) + 1;
        if (this.currentPageNo > mid)  return this.totalPages.slice(this.currentPageNo - mid, this.currentPageNo + mid - 1);
        return this.totalPages.slice(0, this.set_size);
     }

    setPages = (data) => {
        console.log('data length===>>'+ data.length);
        let numberOfPages = Math.ceil(data.length / this.ticketsPerPage);
        for (let index = 1; index <= numberOfPages; index++)   this.totalPages.push(index);
     }

    pageData = () => {
        let currentPageNo = this.currentPageNo;
        let ticketsPerPage = this.ticketsPerPage;
        let startIndex = (currentPageNo * ticketsPerPage) - ticketsPerPage;
        let endIndex = (currentPageNo * ticketsPerPage);
        //return this.data.slice(startIndex, endIndex);
        this.ticketListPerPage = this.allTicketsList.slice(startIndex,endIndex);
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


    handleTicketLinkClick(event){
        console.log('inside handleTicketLinkClick***');
        //var communityUrl = location.protocol + '//' + location.host;     
        var communityPathArray=  window.location.pathname.split('/');
        var communityTicketPath = '';
        for (var key in communityPathArray) {
            if(key == communityPathArray.length-1) break;
            communityTicketPath += communityPathArray[key];
            communityTicketPath += "/";
          }

        var selectedTicketId = event.currentTarget.dataset.item;
        communityTicketPath += 'ticketdetailpage?projId='+this.selectedProjectId+'&tktId='+selectedTicketId;
        window.open(communityTicketPath,'_self');
        }


    searchingTicketMethod(event){
        this.searchingTickets=event.currentTarget.value;
        this.searchTicketsFunc();
        console.log(this.searchingTickets)
      }


    clearingSearchResult()  {
        this.searchingTickets=null;
        this.searchTicketsFunc();

     }


    newTicketMethod(){
        this.newTicketFlag=true;
        this.isLoading=true;
        this.gettingOwnerNames();
    }


    inputOfTicketsMethode(event){
        var ticketFieldName=event.target.name;
        if(ticketFieldName==='subject')  this.subjectValue=event.currentTarget.value;   
     }

    saveTicket(){
        this.searchTicketsFunc();
        this.newTicketFlag=false;
    }

    resetFilters(){
        this.ownerName=null;
        this.priorityVal=null;
        this.searchingTickets=null;
        this.selectstageVal=null;
        this.searchTicketsFunc();
    }

    closeModal(){
        this.newTicketFlag=false;
        this.isOpenMoreFilters=false;
    }


    // Code for Owner Filter
    openOnwerFilter(){

        var selected = this.template.querySelector(".selected-owner");
        var optionsContainer = this.template.querySelector(".options-container-owner");
        var  optionsList =this.template.querySelectorAll(".option-owner");
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); 
        //selected.addEventListener("click", () => {
        //});

        /* optionsList.forEach(o => {
        o.addEventListener("click", () => {
        selected.innerHTML = o.querySelector("label").innerHTML;
        optionsContainer.classList.remove("active");
        });
        });
        */
    }


    getOwnerBySearch(event){
        var searchitem=event.currentTarget.value;
        this.searchOwnerVal=searchitem;
        var listOnwer=this.listOfOwnerForsearchItem;
        this.listOfOwner=[];
        for(var i=0;i<listOnwer.length;i++){

            if(listOnwer[i].Name.includes(searchitem.toLowerCase())) 
            {
            this.listOfOwner.push(listOnwer[i]);
            }
         }
        if(this.listOfOwner.length==0){
        this.listOfOwner=null;
        }
    }

    getListFilteredOwner(event){
        var  checked=event.target.checked;
        var   checkedVal=event.currentTarget.value;
        if(checked){
            this.listOwners.push(checkedVal);
            var firstSelectItem=this.listOwners[0];
            this.isSelectOnwerItem=true;
            for(var i=0;i<this.listOfOwnerForsearchItem.length;i++) 
            {
                if(this.listOfOwnerForsearchItem[i].Id==firstSelectItem) 
                {
                    this.firstItemInOwnerselectList=this.listOfOwnerForsearchItem[i].FirstName +' '+this.listOfOwnerForsearchItem[i].LastName;
                    this.lengthOfselectedOwnerName=this.listOwners.length-1;
                    if(this.lengthOfselectedOwnerName>0)  this.firstItemInOwnerselectList=this.firstItemInOwnerselectList+'[+'+this.lengthOfselectedOwnerName+']';
                }
                if(this.listOfOwnerForsearchItem[i].Id==checkedVal)    this.listOfOwnerForsearchItem[i].isCheck=true;
            }
         }

        else {
            for(var i=0;i<this.listOwners.length;i++) if(this.listOwners[i]==checkedVal) { this.listOwners.splice(i, 1); i--; }
            var firstSelectItem=this.listOwners[0];
            this.isSelectOnwerItem=true;
            for(var i=0;i<this.listOfOwnerForsearchItem.length;i++) {
                if(this.listOfOwnerForsearchItem[i].Id==firstSelectItem) 
                {
                    this.firstItemInOwnerselectList=this.listOfOwnerForsearchItem[i].FirstName +' '+this.listOfOwnerForsearchItem[i].LastName;
                    this.lengthOfselectedOwnerName=this.listOwners.length-1;
                    if(this.lengthOfselectedOwnerName>0)  this.firstItemInOwnerselectList=this.firstItemInOwnerselectList+'[+'+this.lengthOfselectedOwnerName+']';

                }
                if(this.listOfOwnerForsearchItem[i].Id==checkedVal)    this.listOfOwnerForsearchItem[i].isCheck=false;
            }
            if(this.listOwners.length===0) 
            {
                this.listOwners=[];
                this.firstItemInOwnerselectList=null;
                this.isSelectOnwerItem=false;
            }
         }
         this.searchTicketsFunc();
    } 


    refreshOwnerFilter(){
        this.searchOwnerVal='';
        this.listOfOwner=this.listOfOwnerForsearchItem;
        this.isSelectOnwerItem=false;
        this.listOwners=[];
        for(var i=0;i<this.listOfOwnerForsearchItem.length;i++)   this.listOfOwnerForsearchItem[i].isCheck=false;
        this.searchTicketsFunc();
     }



    // Code for Stage Filter
    openStageFilter(){
        var selected = this.template.querySelector(".selected-stage");
        var optionsContainer = this.template.querySelector(".options-container-stage ");
        var  optionsList =this.template.querySelectorAll(".option-stage");
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); 
        /* optionsList.forEach(o => {
        o.addEventListener("click", () => {
        selected.innerHTML = o.querySelector("label").innerHTML;
        optionsContainer.classList.remove("active");
        });
        }); */

    }


    getStageBySearch(event){
        var searchitem=event.currentTarget.value;
        this.searchStageVal=searchitem;
        var listStage=this.listOfStageForsearchItem;
        this.listStageValues=[];
        for(var i=0;i<listStage.length;i++){
            if(listStage[i].value.includes(searchitem.toLowerCase())) this.listStageValues.push(listStage[i]);
         }
        if(this.listStageValues.length==0) this.listStageValues=null;
    }

    getListCheckStageVal(event){
        var  checked=event.target.checked;
        var   checkedVal=event.currentTarget.value;
        if(checked){
            this.selectstageVal.push(checkedVal);
            var firstSelectItem=this.selectstageVal[0];
            this.isSelectStageItem=true;
            for(var i=0;i<this.listOfStageForsearchItem.length;i++)  {
                if(this.listOfStageForsearchItem[i].value==firstSelectItem) {
                    this.firstItemInStageSelectList=this.listOfStageForsearchItem[i].value;
                    var lengthOfselectedStage=this.selectstageVal.length-1;
                    if(lengthOfselectedStage>0) this.firstItemInStageSelectList=this.firstItemInStageSelectList+'[+'+lengthOfselectedStage+']';
                }
                if(this.listOfStageForsearchItem[i].value==checkedVal)   this.listOfStageForsearchItem[i].isCheck=true;
            }
        }

        else{
        for(var i=0;i<this.selectstageVal.length;i++) if(this.selectstageVal[i]==checkedVal) { this.selectstageVal.splice(i, 1); i--; }
        var firstSelectItem=this.selectstageVal[0];
        for(var i=0;i<this.listOfStageForsearchItem.length;i++) {
            if(this.listOfStageForsearchItem[i].value==firstSelectItem) {
                this.firstItemInStageSelectList=this.listOfStageForsearchItem[i].value;
                var lengthOfselectedStage=this.selectstageVal.length-1;
                if(lengthOfselectedStage>0) this.firstItemInStageSelectList=this.firstItemInStageSelectList+'[+'+lengthOfselectedStage+']';
            }
            if(this.listOfStageForsearchItem[i].value==checkedVal)    this.listOfStageForsearchItem[i].isCheck=false;
        }

        if(this.selectstageVal.length===0)  {
            this.selectstageVal=[];
            this.firstItemInStageSelectList=null;
            this.isSelectStageItem=false;
        } 
        }
        this.searchTicketsFunc();
    }

    refreshStageFilter(){
        this.searchStageVal='';
        this.listStageValues=this.listOfStageForsearchItem;
        this.isSelectStageItem=false;
        this.selectstageVal=[];
        for(var i=0;i<this.listOfStageForsearchItem.length;i++) {
            this.listOfStageForsearchItem[i].isCheck=false;
        }
        this.searchTicketsFunc();
    }


    //  Code For Priority Filter
    openPriotiyFilter(){
        var selected = this.template.querySelector(".selected-priority");
        var optionsContainer = this.template.querySelector(".options-container-priority");
        var  optionsList =this.template.querySelectorAll(".option-priority");
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); 
        /*
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); */
    }



    getPriorityBySearch(event){
        var searchitem=event.currentTarget.value;
        this.searchProrityVal=searchitem;
        var listPriority=this.listOfPriortyValues;
        this.itemsOfPriorityList=[];
        for(var i=0;i<listPriority.length;i++){
            if(listPriority[i].value.includes(searchitem.toLowerCase()))   this.itemsOfPriorityList.push(listPriority[i]);
        }
        if(this.itemsOfPriorityList.length==0) this.itemsOfPriorityList=null;
        
    }

    getListCheckPriorityVal(event){
        var  checked=event.target.checked;
        var   checkedVal=event.currentTarget.value;
        if(checked){
            this.listPriorityVal.push(checkedVal);
            var firstSelectItem=this.listPriorityVal[0];
            this.isSelectPriorityItem=true;
            for(var i=0;i<this.listOfPriortyValues.length;i++)  {
                    if(this.listOfPriortyValues[i].value==firstSelectItem)  {
                    this.firstItemInPrioritySelectList=this.listOfPriortyValues[i].value;
                    var lengthOfselectedStage=this.listPriorityVal.length-1;
                    if(lengthOfselectedStage>0) this.firstItemInPrioritySelectList=this.firstItemInPrioritySelectList+'[+'+lengthOfselectedStage+']';
                }
                if(this.listOfPriortyValues[i].value==checkedVal)   this.listOfPriortyValues[i].isCheck=true;
            }
        }

        else{
            for(var i=0;i<this.listPriorityVal.length;i++) if(this.listPriorityVal[i]==checkedVal) { this.listPriorityVal.splice(i, 1); i--; }
            var firstSelectItem=this.listPriorityVal[0];
            for(var i=0;i<this.listOfPriortyValues.length;i++) {
                if(this.listOfPriortyValues[i].value==firstSelectItem)  {
                    this.firstItemInPrioritySelectList=this.listOfPriortyValues[i].value;
                    var lengthOfselectedPriority=this.listPriorityVal.length-1;
                    if(lengthOfselectedPriority>0) this.firstItemInPrioritySelectList=this.firstItemInPrioritySelectList+'[+'+lengthOfselectedPriority+']';
                }
                if(this.listOfPriortyValues[i].value==checkedVal)    this.listOfPriortyValues[i].isCheck=false;
            }
            if(this.listPriorityVal.length===0)  {
                this.listPriorityVal=[];
                this.firstItemInStageSelectList=null;
                this.isSelectPriorityItem=false;
            } 
        }

        this.searchTicketsFunc();
    }

    refreshPriorityFilter(){
        this.searchProrityVal='';
        this.itemsOfPriorityList=this.listOfPriortyValues;
        this.isSelectPriorityItem=false;
        this.listPriorityVal=[];
        for(var i=0;i<this.listOfPriortyValues.length;i++)  {
            this.listOfPriortyValues[i].isCheck=false;
        }
        this.searchTicketsFunc();
    }

    //Filter for Type

    openTypeFilter(){
        var selected = this.template.querySelector(".selected-type");
        var optionsContainer = this.template.querySelector(".options-container-type");
        var  optionsList =this.template.querySelectorAll(".option-type");
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); 
    }

    getTypeBySearch(event){
        var searchitem=event.currentTarget.value;
        this.searchTypeVal=searchitem;
        var listStage=this.listOfTypeForsearchItem;
        this.listTypeValues=[];
        for(var i=0;i<listStage.length;i++){
            if(listStage[i].value.includes(searchitem.toLowerCase())) this.listTypeValues.push(listStage[i]);
        }
        if(this.listTypeValues.length==0) this.listTypeValues=null;
    }

    getListCheckTypeVal(event){
        var  checked=event.target.checked;
        var   checkedVal=event.currentTarget.value;
        if(checked){
            this.selectTypeVal.push(checkedVal);
            var firstSelectItem=this.selectTypeVal[0];
            this.isSelectTypeItem=true;
            for(var i=0;i<this.listOfTypeForsearchItem.length;i++) {
                if(this.listOfTypeForsearchItem[i].value==firstSelectItem)  {
                    this.firstItemInTypeSelectList=this.listOfTypeForsearchItem[i].value;
                    var lengthOfselectedType=this.selectTypeVal.length-1;
                    if(lengthOfselectedType>0) this.firstItemInTypeSelectList=this.firstItemInTypeSelectList+'[+'+lengthOfselectedType+']';
                }
                if(this.listOfTypeForsearchItem[i].value==checkedVal)   this.listOfTypeForsearchItem[i].isCheck=true;
            }
        }


        else{
            for(var i=0;i<this.selectTypeVal.length;i++) if(this.selectTypeVal[i]==checkedVal) { this.selectTypeVal.splice(i, 1); i--; }
            var firstSelectItem=this.selectTypeVal[0];
            for(var i=0;i<this.listOfTypeForsearchItem.length;i++) {
                if(this.listOfTypeForsearchItem[i].value==firstSelectItem)  {
                    this.firstItemInTypeSelectList=this.listOfTypeForsearchItem[i].value;
                    var lengthOfselectedType=this.selectTypeVal.length-1;
                    if(lengthOfselectedType>0) this.firstItemInTypeSelectList=this.firstItemInTypeSelectList+'[+'+lengthOfselectedType+']';
                }
                if(this.listOfTypeForsearchItem[i].value==checkedVal)    this.listOfTypeForsearchItem[i].isCheck=false;
            }
            if(this.selectTypeVal.length===0) {
                this.selectTypeVal=[];
                this.firstItemInTypeSelectList=null;
                this.isSelectTypeItem=false;
            } 
        }
        //  this.searchTicketsFunc();
    }

    refreshTypeFilter(){
        this.searchTypeVal='';
        this.listTypeValues=this.listOfTypeForsearchItem;
        this.isSelectTypeItem=false;
        this.selectTypeVal=[];
        for(var i=0;i<this.listOfTypeForsearchItem.length;i++) {
        this.listOfTypeForsearchItem[i].isCheck=false;
        }
        //  this.searchTicketsFunc();
    }



    // Filter  for Group
    openGroupFilter(){
        var selected = this.template.querySelector(".selected-group");
        var optionsContainer = this.template.querySelector(".options-container-group");
        var  optionsList =this.template.querySelectorAll(".option-group");
        selected.addEventListener("click", () => {
        optionsContainer.classList.toggle("active");
        }); 
    }


    getGroupBySearch(event){
        var searchitem=event.currentTarget.value;
        this.searchGroupVal=searchitem;
        var listGroup=this.listOfGroupForsearchItem;
        this.listGroupValues=[];
        for(var i=0;i<listGroup.length;i++){
            if(listGroup[i].value.includes(searchitem.toLowerCase())) this.listGroupValues.push(listGroup[i]);
        }
        if(this.listGroupValues.length==0) this.listGroupValues=null;
    }

    getListCheckGroupVal(event){
        var  checked=event.target.checked;
        var   checkedVal=event.currentTarget.value;
        if(checked){
            this.selectGroupVal.push(checkedVal);
            var firstSelectItem=this.selectGroupVal[0];
            this.isSelectGroupItem=true;
            for(var i=0;i<this.listOfGroupForsearchItem.length;i++) {
                if(this.listOfGroupForsearchItem[i].value==firstSelectItem)  {
                    this.firstItemInGroupSelectList=this.listOfGroupForsearchItem[i].value;
                    var lengthOfselectedGroup=this.selectGroupVal.length-1;
                    if(lengthOfselectedGroup>0) this.firstItemInGroupSelectList=this.firstItemInGroupSelectList+'[+'+lengthOfselectedGroup+']';
                }
                if(this.listOfGroupForsearchItem[i].value==checkedVal)   this.listOfGroupForsearchItem[i].isCheck=true;
            }
        }


        else{
            for(var i=0;i<this.selectGroupVal.length;i++) if(this.selectGroupVal[i]==checkedVal) { this.selectGroupVal.splice(i, 1); i--; }
            var firstSelectItem=this.selectGroupVal[0];
            for(var i=0;i<this.listOfGroupForsearchItem.length;i++) {
                if(this.listOfGroupForsearchItem[i].value==firstSelectItem)  {
                    this.firstItemInGroupSelectList=this.listOfGroupForsearchItem[i].value;
                    var lengthOfselectedGroup=this.selectGroupVal.length-1;
                    if(lengthOfselectedGroup>0) this.firstItemInGroupSelectList=this.firstItemInGroupSelectList+'[+'+lengthOfselectedGroup+']';
                }
                if(this.listOfGroupForsearchItem[i].value==checkedVal)    this.listOfGroupForsearchItem[i].isCheck=false;
            }
            if(this.selectGroupVal.length===0) {
                this.selectGroupVal=[];
                this.firstItemInGroupSelectList=null;
                this.isSelectGroupItem=false;
            } 
        }
    }

    refreshGroupFilter(){
        this.searchGroupVal='';
        this.listGroupValues=this.listOfGroupForsearchItem;
        this.isSelectGroupItem=false;
        this.selectGroupVal=[];
        for(var i=0;i<this.listOfGroupForsearchItem.length;i++)  {
            this.listOfGroupForsearchItem[i].isCheck=false;
        }
        // this.searchTicketsFunc();
    }

    applyFilter(){
        this.searchTicketsFunc();
        this.isOpenMoreFilters=false;
    }

    cancelModal(){
        this.selectGroupVal=[];
        this.selectTypeVal=[];
        for(var i=0;i<this.listOfGroupForsearchItem.length;i++) this.listOfGroupForsearchItem[i].isCheck=false;
        for(var i=0;i<this.listOfTypeForsearchItem.length;i++) this.listOfTypeForsearchItem[i].isCheck=false;
        this.isSelectGroupItem=false;
        this.isSelectTypeItem=false;
        this.searchTicketsFunc();
        this.isOpenMoreFilters=false;
    }


    openMoreFilters(){
        this.isOpenMoreFilters=true;
    }

    handleLoadSpinner(){
        this.isLoading=false;
    }


}