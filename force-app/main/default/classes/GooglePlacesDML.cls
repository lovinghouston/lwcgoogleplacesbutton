public with sharing class GooglePlacesDML {
    public GooglePlacesDML() {

    }

    public static List<Account> createRawChurches (Map<Integer, Map<String,Object>> bulkData) {

        String churchRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();
        List<Account> churches = new List<Account>();
        Integer i = 1;

        for (Integer index : bulkData.keySet()) {

            Map<String, Object> bulkDataDetails = bulkData.get(index);

            if (i == 50) {
                break;
            }
            // Typecasting the address value and using the utility method to format it
            String address = (String)bulkDataDetails.get('formatted_address');
            List<String> formattedAddress = GooglePlacesUtility.formatAddress(address);
            Account church = new Account();
            
            church.Name = (String)bulkDataDetails.get('name');
            church.Type = 'Church';
            if (bulkDataDetails.containsKey('website')) {church.Website = (String)bulkDataDetails.get('website');}
            if (bulkDataDetails.containsKey('url')) {church.Google_Maps_Listing__c = (String)bulkDataDetails.get('url');}
            if (bulkDataDetails.containsKey('formatted_phone_number')) {church.Phone = (String)bulkDataDetails.get('formatted_phone_number');}
            church.RecordTypeId = churchRecordId;
            
            if (formattedAddress.size() == 4) {
                church.BillingStreet = formattedAddress[0];
                church.BillingCity = formattedAddress[1];
                church.BillingState = formattedAddress[2];
                church.BillingPostalCode = formattedAddress[3];
                churches.add(church);
            } else {
                System.debug('Invalid address for ' + church.Name + '. Address: ' + formattedAddress);
            }

            for (String key : bulkDataDetails.keySet()) {
                church.Google_API_Place_Details_Response__c += key + ' : ' + bulkDataDetails.get(key);
                church.Google_API_Place_Details_Response__c += '\n';
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
        Account school = [SELECT Id, BillingAddress FROM Account WHERE Id = :account];
        
        if (churches.size() == 0) {
            System.debug('20 closest Churches have already been found and created');
        }

        List<Church_School_Partnership__c> partnerships = new List<Church_School_Partnership__c>();

        for (Account church : churches) {

            Church_School_Partnership__c partnership = new Church_School_Partnership__c();
            partnership.Church_Account__c = church.Id;
            partnership.School_Account__c = account;
            partnership.Status__c = 'Potential';
            GooglePlacesUtility.calculateDistance(school, church);
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

        List<Church_School_Partnership__c> queriedPartnerships = [SELECT Name, School_Name__c, Church_Name__c, Church_Account__c, School_Account__c, Id, Status__c
                                                                    FROM Church_School_Partnership__c
                                                                    WHERE Id IN :cspIds];

        return queriedPartnerships;
    }
}
