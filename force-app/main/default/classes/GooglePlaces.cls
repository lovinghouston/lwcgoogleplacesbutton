public class GooglePlaces {

 	public static void searchPlace (Id account, Decimal longitude, Decimal latitude, Integer radius, String type, String key){
        
        // Validation to check if type is church. In the future it would be nice to add functionality to take in different types like School.
        if (type != 'church') {
            System.debug('Type needs to be church.');
            return;
        }
        
        // Using the textsearch call instead of nearbyplaces since the former provides formatted addresses. 
        String googleNearbyPlacesUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + longitude + ',' + latitude + '&radius=' + radius + '&type=' + type + '&key=' + key;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(googleNearbyPlacesUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response. Status code is always 200 for Google Maps API
        if (response.getStatusCode() == 200) {
            
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<Integer, Map<String,Object>> bulkData = new Map<Integer, Map<String,Object>>();
            // Cast the values in the 'animals' key as a list
            List<Object> results = (List<Object>) googleResults.get('results');
            System.debug('Received the following results:');
            
            for (Integer i = 0; i < results.size(); i ++) {
                
            	// Setting the limit of records created to 5 for now. In the future, can add functionality to dynamically create a requested number of records.
                if (i == 5) {
                    break;
                }
                
                Map<String,Object> formatted = (Map<string,Object>) results[i];
                bulkData.put(i, formatted);
                
            }
            
            // Log any error messages if present.
            System.debug('Status: ' + googleresults.get('status'));
            System.debug('Error Message: ' + googleresults.get('error_message'));
            List<Account> churches = createChurches(bulkData);
            createPotentialCSPs(churches, account);
            
        }
    }
    

    public static List<Account> createChurches (Map<Integer, Map<String,Object>> bulkData) {

        String churchRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();
        List<Account> churches = new List<Account>();

        for (Integer index : bulkData.keySet()) {

            // Typecasting the address value and using the utility method to format it
            String address = (String)bulkData.get(index).get('formatted_address');
            List<String> formattedAddress = formatAddress(address);
            Account church = new Account();
            
            church.Name = (String)bulkData.get(index).get('name');
            church.Type = 'Church';
            church.RecordTypeId = churchRecordId;
            
            if (formattedAddress.size() == 4) {
                church.BillingStreet = formattedAddress[0];
                church.BillingCity = formattedAddress[1];
                church.BillingState = formattedAddress[2];
                church.BillingPostalCode = formattedAddress[3];
            }
            
            churches.add(church);

        }
        
        try {
            insert churches;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        for (Account church : churches) {
            System.debug('Inserted Account id: ' + church.Id);
        }
        
        return churches;
    }

    public static void createPotentialCSPs (List<Account> churches, Id account) {

        List<Church_School_Partnership__c> partnerships = new List<Church_School_Partnership__c>();

        for (Account church : churches) {

            Church_School_Partnership__c partnership = new Church_School_Partnership__c();
            partnership.Church_Account__c = church.Id;
            partnership.School_Account__c = account;
            partnership.Status__c = 'Potential';
            partnership.Church_Status__c = 'Not Ready Yet';
            partnerships.add(partnership);

        }

        try {
            insert partnerships;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        for (Church_School_Partnership__c partnership : partnerships) {
            System.debug('Inserted CSP record Id: ' + partnership.Id);
        }
    }
    
    // Utility method for formatting the address that is returned
    public static List<String> formatAddress (String address) {
        
        // Google provides formatted address like the following: 123 Sunny drive, Los Angeles, CA 90210.
        // Because of this, I'm currently doing two split methods. If the first split does not provide three items, I assume that street is not given and do not enter the address values for the Account record.
        // First split
        List<String> formatted = address.split(', ');

        if (formatted.size() == 3) {
            // Second split
            List<String> stateZip = formatted[2].split(' ');
            // Removing the "CA 90210" item to replace with separated ones.
            formatted.remove(2);
            for (String value : stateZip) {
                formatted.add(value);
            }
        }

        return formatted;
    }
}