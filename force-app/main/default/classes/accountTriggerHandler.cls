public class accountTriggerHandler {
    @Future(callout=true)
    public static void sendCustomerDetails(String recordId, String email, String tshirtSize, string shoeSize) {
        // Instantiate HTTP request and response
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the endpoint URL
        request.setEndpoint('https://integrations.commutatus.com/webhook/sf-developer-assignment');
        
        // Set the method to POST
        request.setMethod('POST');
        
        // Set the content type to JSON
        request.setHeader('Content-Type', 'application/json');
        
        // Create the body for the request
        String requestBody = '{"email": "' + email + '", ' +
            '"tshirtSize": "' + tshirtSize + '", ' +
            '"shoeSize": ' + decimal.valueOf(shoeSize) + '}';
        
        // Set the request body
        request.setBody(requestBody);
        
        try {
            // Send the request
            HttpResponse response = http.send(request);
            
            // Check the response status
            if (response.getStatusCode() == 200) {
                System.debug('Request successful: ' + response.getBody());
                
                // Deserialize the response body
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
                // Check if status is success and the customer_id is present
                if (result.containsKey('status') && result.get('status') == 'success') {
                    String customerId =string.valueOf( (integer)result.get('customer_id'));
                    
                    // Update the Loyalty Customer ID field on the record
                    Account acc = [SELECT Id, Loyalty_Customer_ID__c FROM Account WHERE Id = :recordId LIMIT 1];
                    acc.Loyalty_Customer_ID__c = customerId;
                    update acc;
                    
                    System.debug('Loyalty Customer ID updated successfully.');
                } else {
                    System.debug('Unexpected response: ' + response.getBody());
                }
            } else if (response.getStatusCode() == 400) {
                // Handle error scenario
                System.debug('Failed request with status: ' + response.getStatusCode());
                Map<String, Object> errorResult = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
                if (errorResult.containsKey('status') && errorResult.get('status') == 'error') {
                    Account acc = [SELECT Id, Loyalty_Customer_ID__c FROM Account WHERE Id = :recordId LIMIT 1];
                    acc.Integration_Error__c = string.valueOf(errorResult.get('message'));
                    update acc;
                    System.debug('Error: ' + errorResult.get('message'));
                }
            } else {
                System.debug('Request failed with status: ' + response.getStatusCode());
                Account acc = [SELECT Id, Loyalty_Customer_ID__c FROM Account WHERE Id = :recordId LIMIT 1];
                acc.Integration_Error__c =string.valueOf(response.getStatusCode());
                update acc;
            }
        } catch (Exception e) {
            system.debug('line Number---->'+e.getLineNumber());
            System.debug('Error during callout: ' + e.getMessage());
        }
    }
}