/*
* @Purpose: trigger for account
* @Author: Gaurav Fugat
* @CreatedDate: 06/10/2024
* @Test Class: not created yet
* @LastModifiedDate: 
* @LastModifiedBy: 
*/
trigger AccountTrigger on Account (after update) {
    
    // handle account after update triggers
    if(trigger.isAfter && trigger.isUpdate){
        List<Account> accForCallout = new List<Account>();
        for(Account accObj: Trigger.new){
            //check if the accounts profile is completed and customer id is not generated 
            if(accObj.Profile_Completed__c && string.isBlank(accObj.Loyalty_Customer_ID__c)){
                accForCallout.add(accObj);
            }
        }
        if(!accForCallout.isEmpty()){
            //adding the callout to queue to resolve callout from loop 
            System.enqueueJob(new AccountCustomerDetailsQueueable(accForCallout));
        }
    }
}