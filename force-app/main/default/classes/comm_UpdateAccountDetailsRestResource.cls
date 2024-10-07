@RestResource(urlMapping='/updateAccountDetails/*')
global class comm_UpdateAccountDetailsRestResource {
// POST Method to update the T_shirt_size__c, Shoe_Size__c, and Date_Of_Birth__c fields
    @HttpPost
    global static String updateAccountDetails() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Extract parameters from request body (assuming JSON body)
        String requestBody = req.requestBody.toString();
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        String recordId = (String)params.get('recordId');
        String lastName = (String)params.get('lastName');
        String tShirtSize = (String)params.get('T_shirt_size__c');
        String shoeSize = (String)params.get('Shoe_Size__c');
        String dateOfBirth = (String)params.get('Date_Of_Birth__c');
        string phone = (String)params.get('Phone');
        
        if (String.isBlank(recordId) ) {
            res.statusCode = 400;
            return 'Invalid input: recordId ';
        }

        try {
            // Query the Account record to update
            Account accountToUpdate = new Account();
            accountToUpdate.Id = recordId;
            accountToUpdate.Phone = phone;
            
            // Update the fields
            if (tShirtSize != null) {
                accountToUpdate.T_shirt_size__c = tShirtSize;
            }
            if (shoeSize != null) {
                accountToUpdate.Shoe_Size__c = shoeSize;
            }
            if (dateOfBirth != null) {
                accountToUpdate.Date_Of_Birth__c = Date.valueOf(dateOfBirth);  
            }
            accountToUpdate.Profile_Completed__c = true;
            update accountToUpdate;
            return 'Account updated successfully.';
        } catch (Exception e) {
            res.statusCode = 404;
            return 'Error: Account not found or update failed.';
        }
    }
}