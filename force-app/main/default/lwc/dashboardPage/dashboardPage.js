import { LightningElement} from 'lwc';
import fetchTickets from '@salesforce/apex/TicketHandler.fetchTickets';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import ChartJs from '@salesforce/resourceUrl/ChartJs';
import gettingOwnerName from '@salesforce/apex/TicketHandler.gettingOwnerName';
import searchTickets from '@salesforce/apex/TicketHandler.searchTickets';
import selectOwnerName from '@salesforce/apex/TicketHandler.selectOwnerName';

export default class DashboardPage extends LightningElement {
  charts=ChartJs;
  allTicketsList = null;       
  ticketsSizeFlag=false;
  selectedProjectId='';
  totalOpenStages=0;
  totalPendingStages=0;
  totalResolvedStages=0;
  totalWaitingOnCustomerStages=0;
  totalClosedStages=0;
  totalOtherStages=0;
  totalNoOfTickets=0;
  graphData=[];
  selectOwnerNames=[];
  firstItemInOwnerselectList=null;
  selectListOfOwners=[];
  listOfOwner=[];
  listOfOwnerForsearchItem=[];
  searchOwnerVal='';
  isSelectOnwerItem=false;
  listOfTicketPerUser=[];
  colors=['#007bff',"#dd9105", "#28a745","#dc3545",'#00FFFF','#0000A0','#ADD8E6','#FFFF00','#808080','#FFA500','#808000'];
  listOfUsers=[];
  listOfUsersandCount=[];

  constructor(){
    super();
    let communityUrlMap = new URL(window.location.href).searchParams;
    this.selectedProjectId =  communityUrlMap.get('projId');
    this.gettingOwnerNames();
   }

  renderedCallback(){
    Promise.all([loadScript(this, this.charts)])
      .then(() => {
        this.initializeChart();
      })
      .catch(error => {});

   }


  connectedCallback(){
    this.fetchTicketsFunc();
    var  conList = this.querySelectorAll('li');
    for (let i = 0; i < conList.length; i++){
      let indvRow = conList[i];
      let indvRowId = conList[i].getAttribute('id');  
      if(indvRow!=null){
        if(indvRowId.includes('Dashboard')) indvRow.classList.add("slds-is-active");
        else    indvRow.classList.remove("slds-is-active");
       }
     }
   }


  gettingOwnerNames = async=>{
    gettingOwnerName()
      .then(result=> {
        this.listOfOwner=[];
        var listOfResultOwner=result;
        for(var key in listOfResultOwner){
            this.listOfOwner=[...this.listOfOwner,{Id:listOfResultOwner[key].Id,Name:listOfResultOwner[key].Name.toLowerCase(),isCheck:false}];

        }
        this.listOfOwnerForsearchItem=this.listOfOwner;

       })
      .catch({});

  }  




  searchTicketsFunc = async() => {
    await searchTickets({projectId: this.selectedProjectId,AssignTo:this.selectListOfOwners })
      .then(result =>{
        this.allTicketsList = result;
        this.countTickets(); 
      })
      .catch(error =>{
        this.error = error;
        console.log('Error while fetching data => '+ this.error);
      });
    await selectOwnerName({userId:this.selectListOfOwners})
      .then(result=>{
          this.selectOwnerNames=result;
          this.countNoOfTicketsPerUser();
        })
      .catch(error=>{alert(error)

        });
  }


  fetchTicketsFunc = async() => {
    await fetchTickets({projectId: this.selectedProjectId})
      .then(result =>{
        this.allTicketsList = result;  
        if(this.allTicketsList.length === 0)   this.ticketsSizeFlag = true;
        else{
          this.ticketsSizeFlag=false;
          this.countTickets();
         }
       })
      .catch(error =>{
        console.log('Error while fetching data => '+ this.error);
      });
  }




  countTickets(){

      this.totalNoOfTickets=0;
      this.totalOpenStages=0;
      this.totalPendingStages=0;
      this.totalResolvedStages=0;
      this.totalWaitingOnCustomerStages=0;
      this.totalClosedStages=0;
      this.totalOtherStages=0;
      this.listOfUsers=[];
      this.totalNoOfTickets=this.allTicketsList.length
      for(var i=0;i<this.allTicketsList.length;i++){
        if(this.allTicketsList[i].Stage__c!==null) {
          let stageVal=this.allTicketsList[i].Stage__c;
          if(stageVal==='Open') this.totalOpenStages++;
          else if(stageVal==='Pending') this.totalPendingStages++;
          else if(stageVal==='Resolved') this.totalResolvedStages++;
          else if(stageVal==='Waiting on Customer') this.totalWaitingOnCustomerStages++;
          else if(stageVal==='Closed') this.totalClosedStages++;
          else this.totalOtherStages++;
        }

        if(this.allTicketsList[i].AssignTo__r.Name!=='')   this.listOfUsers.push(this.allTicketsList[i].AssignTo__r.Name);  
       }
    if(this.selectListOfOwners.length===0){
      this.gettingListOfUsersAndCount();
      this.triggerCharts();   
     }
  }


  countNoOfTicketsPerUser(){
    this.listOfTicketPerUser=[];
    for(let k=0;k<this.selectOwnerNames.length;k++) {
      let totalNoOfTicketperUser=0;
      let totalOpenStageperUser=0;
      let totalPendingStageperUser=0;
      let totalResolvedStageperUser=0;
      let totalWaitingOnCustomerStageperUser=0;
      let totalClosedStageperUser=0;
      let totalOtherStageperUser=0;

      for(let j=0;j<this.allTicketsList.length;j++){
        if(this.selectOwnerNames[k].Name=== this.allTicketsList[j].AssignTo__r.Name) {
          if(this.allTicketsList[j].Stage__c!==null){
            let stageVal=this.allTicketsList[j].Stage__c;
            if(stageVal==='Open') totalOpenStageperUser++;
            else if(stageVal==='Pending') totalPendingStageperUser++;
            else if(stageVal==='Resolved') totalResolvedStageperUser++;
            else if(stageVal==='Waiting on Customer') totalWaitingOnCustomerStageperUser++;
            else if(stageVal==='Closed')  totalClosedStageperUser++;
            else totalOtherStageperUser++;
            }
          totalNoOfTicketperUser++;       
         }
       }
      this.listOfTicketPerUser=[...this.listOfTicketPerUser,{UserName:this.selectOwnerNames[k].Name,totalTicketPerUser:totalNoOfTicketperUser,totalOpenStageperUser:totalOpenStageperUser,
      totalPendingStageperUser:totalPendingStageperUser,totalResolvedStageperUser:totalResolvedStageperUser,totalWaitingOnCustomerStageperUser:totalWaitingOnCustomerStageperUser,
      totalClosedStageperUser:totalClosedStageperUser,totalOtherStageperUser:totalOtherStageperUser}];
    }

    for(let i=0;i<this.listOfTicketPerUser.length;i++){
      let totalTicketsPerUser=0;
      let currentElemnt=this.listOfTicketPerUser[i].UserName;
      for(let j=0;j<this.listOfTicketPerUser.length;j++){

        if(this.listOfTicketPerUser[j].UserName===currentElemnt) { 

          totalTicketsPerUser++;
          if(totalTicketsPerUser>1) {
            this.listOfTicketPerUser.splice(j, 1);
            j--; 
          }
        }
      }
    }

  }


  gettingListOfUsersAndCount(){

    let listOfUser=this.listOfUsers;
    this.listOfUsersandCount=[];
    for(let i=0;i<listOfUser.length;i++){
      let totalTicketsPerUser=0;
      let currentElemnt=listOfUser[i];
      for(let j=0;j<listOfUser.length;j++) {

        if(listOfUser[j]===currentElemnt) { 
          totalTicketsPerUser++;
          if(totalTicketsPerUser>1) {
              listOfUser.splice(j, 1);
              j--; 
          }
        }
      }
      if(this.colors.length>i) this.listOfUsersandCount=[...this.listOfUsersandCount,{username:currentElemnt,color:this.colors[i],count:totalTicketsPerUser}];
      else {
        let color='#007bff'
        this.listOfUsersandCount=[...this.listOfUsersandCount,{username:currentElemnt,color:color,count:totalTicketsPerUser}];
      }
    }

  }


  /***Chart Initialization */
  initializeChart(){
    let container = this.template.querySelector('.chartContainer')
    Highcharts.chart(container, {
      chart: {
      type: 'column',
      },
      title: {
      text: 'No of Tickets per User  '
      },
      xAxis: {
      categories:this.listOfUsers,
      },
      tooltip: {
      headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
      pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b> <br/>'
      },
      legend: {
      enabled: false
      },

      series: [{
      name: 'No of Tickets to ',
      data: this.graphData,
      }] 
    });
  }

  triggerCharts(){
      this.graphData=[];
      for(var i=0;i<this.listOfUsersandCount.length;i++){
        this.graphData = [...this.graphData ,{name:this.listOfUsersandCount[i].username ,color:this.listOfUsersandCount[i].color, y:this.listOfUsersandCount[i].count} ];   
      } 
      //this.initializeChart();
      console.log(JSON.stringify(this.graphData))
      window.setTimeout(()=>{  this.initializeChart() },1000)
  }



  openOnwerFilter(){

    var selected = this.template.querySelector(".selected-owner");
    var optionsContainer = this.template.querySelector(".options-container-owner");
    var  optionsList =this.template.querySelectorAll(".option-owner");
    selected.addEventListener("click", () => {
    optionsContainer.classList.toggle("active");
    }); 
  
  }


  getOwnerBySearch(event){
    var searchitem=event.currentTarget.value;
    this.searchOwnerVal=searchitem;
    var listOnwer=this.listOfOwnerForsearchItem;
    this.listOfOwner=[];
    for(var i=0;i<listOnwer.length;i++){
      if(listOnwer[i].Name.includes(searchitem.toLowerCase()))  {
      this.listOfOwner.push(listOnwer[i]);
      }
    }
     if(this.listOfOwner.length==0)this.listOfOwner=null;
  }


  getListFilteredOwner(event){
    var  checked=event.target.checked;
    var   checkedVal=event.currentTarget.value;
    if(checked){
      this.selectListOfOwners.push(checkedVal);
      var firstSelectItem=this.selectListOfOwners[0];
      this.isSelectOnwerItem=true;
      for(var i=0;i<this.listOfOwnerForsearchItem.length;i++){
        if(this.listOfOwnerForsearchItem[i].Id==firstSelectItem) {
          this.firstItemInOwnerselectList=this.listOfOwnerForsearchItem[i].Name ;
          this.lengthOfselectedOwnerName=this.selectListOfOwners.length-1;
          if(this.lengthOfselectedOwnerName>0)  this.firstItemInOwnerselectList=this.firstItemInOwnerselectList+'[+'+this.lengthOfselectedOwnerName+']';
        }
      if(this.listOfOwnerForsearchItem[i].Id==checkedVal)    this.listOfOwnerForsearchItem[i].isCheck=true;
      }
    }

    else{
      for(var i=0;i<this.selectListOfOwners.length;i++) if(this.selectListOfOwners[i]==checkedVal) { this.selectListOfOwners.splice(i, 1); i--; }
      var firstSelectItem=this.selectListOfOwners[0];
      this.isSelectOnwerItem=true;
      for(var i=0;i<this.listOfOwnerForsearchItem.length;i++) {
        if(this.listOfOwnerForsearchItem[i].Id==firstSelectItem)  {
        this.firstItemInOwnerselectList=this.listOfOwnerForsearchItem[i].Name ;
        this.lengthOfselectedOwnerName=this.selectListOfOwners.length-1;
        if(this.lengthOfselectedOwnerName>0)  this.firstItemInOwnerselectList=this.firstItemInOwnerselectList+'[+'+this.lengthOfselectedOwnerName+']';
        }
        if(this.listOfOwnerForsearchItem[i].Id==checkedVal)    this.listOfOwnerForsearchItem[i].isCheck=false;
      }
      if(this.selectListOfOwners.length===0)  {
        this.selectListOfOwners=[];
        this.firstItemInOwnerselectList=null;
        this.isSelectOnwerItem=false;
      }
    }
    this.searchTicketsFunc();
    this.getSelectOwnerName();
  } 


  refreshOwnerFilter(){
    this.searchOwnerVal='';
    this.listOfOwner=this.listOfOwnerForsearchItem;
    this.isSelectOnwerItem=false;
    this.selectListOfOwners=[];
    for(var i=0;i<this.listOfOwnerForsearchItem.length;i++) {
      this.listOfOwnerForsearchItem[i].isCheck=false;
    }
    this.searchTicketsFunc();
    this.getSelectOwnerName();

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

}