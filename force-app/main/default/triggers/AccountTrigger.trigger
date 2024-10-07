trigger AccountTrigger on Account (after update) {
    if(trigger.isAfter && trigger.isUpdate){
        List<Account> accForCallout = new List<Account>();
        for(Account accObj: Trigger.new){
            if(accObj.Profile_Completed__c && string.isBlank(accObj.Loyalty_Customer_ID__c)){
                accForCallout.add(accObj);
            }
        }
        if(!accForCallout.isEmpty()){
            System.enqueueJob(new AccountCustomerDetailsQueueable(accForCallout));
           // accountTriggerHandler.handleCommutatusCallout(accForCallout);
        }
    }
}