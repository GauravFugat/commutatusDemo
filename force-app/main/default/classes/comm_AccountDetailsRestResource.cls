/*
* @Purpose: rest resource to fetch account data on initial load of LWC Comm_CustomerDetailPage
* @Author: Gaurav Fugat
* @CreatedDate: 06/10/2024
* @Test Class: not created yet
* @LastModifiedDate: 
* @LastModifiedBy: 
*/
@RestResource(urlMapping='/accountDetails/*')
global with sharing class comm_AccountDetailsRestResource {

    // Method to fetch Account details by recordId and LastName
    @HttpPost
    global static Account getAccountDetails() {
        RestContext.response.addHeader('Access-Control-Allow-Origin', '*');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Extract parameters from request body (assuming JSON body)
        String requestBody = req.requestBody.toString();
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        String recordId = (String)params.get('recordId');
        String lastName = (String)params.get('lastName');
        
        if (String.isBlank(recordId) || String.isBlank(lastName)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Invalid input: recordId and lastName are required.');
            return null;
        }

        // Query the Account record with the given Id and LastName
        Account accountRecord;
        try {
            accountRecord = [
                SELECT Id, Name, FirstName, LastName, Phone, PersonEmail, T_shirt_size__c, Shoe_Size__c, Date_Of_Birth__c, Profile_Completed__c 
                FROM Account 
                WHERE Id =: recordId AND LastName =: lastName 
                LIMIT 1
            ];
        } catch (Exception e) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Account not found');
            return null;
        }

        return accountRecord;
    }   
}