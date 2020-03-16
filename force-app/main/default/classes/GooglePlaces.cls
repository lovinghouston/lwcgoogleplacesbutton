public class GooglePlaces {

    @AuraEnabled
 	public static List<Church_School_Partnership__c> searchPlace (Id account, Decimal longitude, Decimal latitude, Integer radius, String type, String key){

         // Validation to check if type is church. In the future it would be nice to add functionality to take in different types like School.
        if (GooglePlacesUtility.validateInputs(account, longitude, latitude, radius, type).equals('invalid')) {
            return null;
        }
        
        HttpResponse response = GooglePlacesUtility.createTextSearchCall(longitude, latitude, radius, key, type);
        
        // If the request is successful, parse the JSON response. Status code is always 200 for Google Maps API
        if (response.getStatusCode() == 200) {
            
            // Deserialize the JSON string into collections of primitive data types.
            Map<Integer, Map<String,Object>> bulkData = GooglePlacesUtility.processResults(response);            
            
            // Check for dupes here
            // List<Account> nonDupes = GooglePlacesUtility.checkDupes(bulkData)
            // List<Account> churches = createChurches(nonDupes)
            List<Account> rawChurches = createRawChurches(bulkData);
            Map<String, List<Account>> processedChurches = GooglePlacesUtility.checkAccountDupes(rawchurches);
            if (processedChurches == null) {
                System.debug('Dupe check failed, breaking call.');
                return null;
            }
            List<Account> churchesNeedCSP = GooglePlacesUtility.checkCSPDupes(processedChurches.get('Dupes'), account);
            churchesNeedCSP.addAll(createProcessedChurches(processedChurches.get('Non-dupes')));
            return createPotentialCSPs(churchesNeedCSP, account);
        }
        return null;
    }
    

    public static List<Account> createRawChurches (Map<Integer, Map<String,Object>> bulkData) {

        String churchRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();
        List<Account> churches = new List<Account>();
        Integer i = 1;

        for (Integer index : bulkData.keySet()) {

            if (i == 50) {
                break;
            }
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
                churches.add(church);
            }
            
            i ++;
        }
        
        return churches;
    }

    public static List<Account> createProcessedChurches (List<Account> processedChurches) {

        try {
            insert processedChurches;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return processedChurches;

    }

    public static List<Church_School_Partnership__c> createPotentialCSPs (List<Account> churches, Id account) {
        
        if (churches.size() == 0) {
            System.debug('20 closest Churches have already been found and created');
        }

        List<Church_School_Partnership__c> partnerships = new List<Church_School_Partnership__c>();

        for (Account church : churches) {

            Church_School_Partnership__c partnership = new Church_School_Partnership__c();
            partnership.Church_Account__c = church.Id;
            partnership.School_Account__c = account;
            partnership.Status__c = 'Potential';
            // partnership.Church_Status__c = 'Not Ready Yet';
            partnerships.add(partnership);

        }

        try {
            insert partnerships;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        List<Id> cspIds = new List<Id>();
        for (Church_School_Partnership__c partnership : partnerships) {
            System.debug('Inserted CSP record Id: ' + partnership.Id);
            cspIds.add(partnership.Id);
        }

        List<Church_School_Partnership__c> queriedPartnerships = [SELECT Name, Church_Name__c, School_Name__c, Id, Status__c
                                                                    FROM Church_School_Partnership__c
                                                                    WHERE Id IN :cspIds];

        return queriedPartnerships;
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