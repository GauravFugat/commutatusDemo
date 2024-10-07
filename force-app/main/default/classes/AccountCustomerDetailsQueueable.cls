/*
* @Purpose: Queueable class to for commutatus callout handle
* @Author: Gaurav Fugat
* @CreatedDate: 06/10/2024
* @Test Class: not created yet
* @LastModifiedDate: 
* @LastModifiedBy: 
*/
public class AccountCustomerDetailsQueueable implements Queueable, Database.AllowsCallouts {
    
    // List of accounts to process
    private List<Account> accountList;
    
    // Constructor to pass account list
    public AccountCustomerDetailsQueueable(List<Account> accounts) {
        this.accountList = accounts;
    }
    
    // Execute method for queueable processing
    public void execute(QueueableContext context) {
        // Iterate over the list of accounts and call the sendCustomerDetails method
        for (Account acc : accountList) {
            if (acc.PersonEmail != null && acc.T_shirt_size__c != null && acc.Shoe_Size__c != null) {
                // Calling the future method to send customer details
                accountTriggerHandler.sendCustomerDetails(acc.Id, acc.PersonEmail, acc.T_shirt_size__c, acc.Shoe_Size__c);
            } else {
                System.debug('Account ' + acc.Id + ' is missing required fields.');
            }
        }
    }
}