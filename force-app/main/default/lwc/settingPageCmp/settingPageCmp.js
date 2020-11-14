import { LightningElement } from 'lwc';

export default class SettingPageCmp extends LightningElement {


    openHomePage(event){
        var eventName=event.currentTarget.name;
        var communityPathArray=  window.location.pathname.split('/');
        var communityHomePath = '';
       
        for (var key in communityPathArray)
         {

          if(key == communityPathArray.length-1)    break;
          communityHomePath += communityPathArray[key];
          communityHomePath += "/";
         }
          window.open(communityHomePath,'_self');
        }
    

    
}