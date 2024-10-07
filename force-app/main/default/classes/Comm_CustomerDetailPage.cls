/*
* @Purpose: Controller for the Comm_CustomerDetailPage LWC 
* @Author: Gaurav Fugat
* @CreatedDate: 06/10/2024
* @Test Class: not created yet
* @LastModifiedDate: 
* @LastModifiedBy: 
*/
global class Comm_CustomerDetailPage {
    //store domainurl
    public static string domainUrl = Url.getOrgDomainUrl().toExternalForm();
    
    //Get record details on initial load
    @AuraEnabled
    global static string getDetails(string recordId, string LastName){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        //get access token
        String sessionId = getAccessToken();
        
        // Set up the request for the GET method
        req.setEndpoint(domainUrl + '/services/apexrest/accountDetails/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' +sessionId);
        
        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'recordId' => recordId,
            'lastName' => LastName
        };
        req.setBody(JSON.serialize(requestBody));
        
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Account data: ' + res.getBody());
                return res.getBody();
            } else {
                System.debug('Error response: ' + res.getBody());
                return res.getBody();
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    //update record on save
    @AuraEnabled
    global static string updateAccountDetails(string recordId,string phone, string tshirtSize,string shoeSize, date dob) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        //get access token
        String sessionId = getAccessToken();
        
        // Set up the request for the POST method
        req.setEndpoint(domainUrl + '/services/apexrest/updateAccountDetails/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' +sessionId);
        
        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'recordId' => recordId,
                'Phone' => phone,
                'T_shirt_size__c' => tshirtSize,
                'Shoe_Size__c' => shoeSize,
                'Date_Of_Birth__c' => string.valueOf(dob)
                };
        req.setBody(JSON.serialize(requestBody));
        
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Account update response: ' + res.getBody());
            } else {
                System.debug('Error response: ' + res.getBody());
            }
            return res.getBody();
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            return e.getMessage();
        }
    }
    
    //get access token for authorization 
    global static string getAccessToken(){
        
        Http httpCls = new Http();
        HttpRequest request = new HttpRequest();
        
        //set endpoint
        request.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        
        //set method and timeout
        request.setMethod('POST');
        request.setTimeout(2 * 60 * 1000);  
        
        //set header
        request.setHeader('Content-Type','application/x-www-form-urlencoded');   
        
        //get the client credentials and set the body with it
        Comm_Creds__c Creds = [ SELECT Client_Id__c,Client_Secret__c,Password__c,User_Name__c FROM Comm_Creds__c WHERE Name = 'Comm Creds' Limit 1];
        request.setBody('grant_type=password' + 
                        '&client_id=' + Creds.Client_Id__c + 
                        '&client_secret=' + Creds.Client_Secret__c + 
                        '&username=' + Creds.User_Name__c + 
                        '&password=' + Creds.Password__c);  
        
        
        //sending the json to the request body
        httpResponse response = httpCls.send(request); 
        
        String accesstoken ;
        if(response.getStatusCode() == 200){            
            system.debug('## Successfully retrieving access token' ); 
            
            map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(response.getBody());
            
            accesstoken = (String)resultMap.get('access_token');                     
        }
        else{
            system.debug('## Could not retrieve the access token' ); 
            system.debug('## response status :' + response.getStatus()); 
            system.debug('## response message :' + response.getBody());             
        }
        system.debug('accesstoken-->'+accesstoken);
        return accesstoken;
    }
}