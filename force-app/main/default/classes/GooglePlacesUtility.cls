public with sharing class GooglePlacesUtility {

    // Utility Class
    public GooglePlacesUtility() {

    }

    // Making sure inputs are acceptable before making the call
    public static String validateInputs(Id account, Decimal longitude, Decimal latitude, Integer radius, String type) {

        String success = 'valid';
        if (type != 'church') {
            System.debug('Type needs to be church.');
            success = 'invalid';
        }

        if (longitude == null || latitude == null) {
            System.debug('Longitude and latitude are invalid');
            success = 'invalid';
        }

        if (radius > 100) {
            System.debug('radius is too large');
            success = 'invalid';
        }

        return success;
    }

    // Here is where the API call is formed and sent
    public static HttpResponse createTextSearchCall(Decimal longitude, Decimal latitude, Integer radius, String key, String type) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String googleTextSearchUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + latitude + ',' + longitude + '&radius=' + radius + '&type=' + type + '&key=' + key;

        request.setEndpoint(googleTextSearchUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        return response;
    }

    public static Map<Integer, Map<String,Object>> processResults(HttpResponse response) {

        Map<Integer, Map<String,Object>> bulkData = new Map<Integer, Map<String,Object>>();
        Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> results = (List<Object>) googleResults.get('results');
        
        for (Integer i = 0; i < results.size(); i ++) {

            Map<String,Object> formatted = (Map<string,Object>) results[i];
            bulkData.put(i, formatted);

        }

        // Log any error messages if present.
        System.debug('Status: ' + googleResults.get('status'));
        System.debug('Error Message: ' + googleResults.get('error_message'));
        
        return bulkData;
    } 

    
    public static Map<String, List<Account>> checkAccountDupes (List<Account> rawChurches) {

        Map<String, List<Account>> churches = new Map<String, List<Account>>();
        List<Datacloud.FindDuplicatesResult> dupeResults;
        List<Account> processedChurches = new List<Account>();
        List<Account> dupeChurches = new List<Account>();
      
        try {
            dupeResults = Datacloud.FindDuplicates.findDuplicates(rawChurches);
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }

        System.debug('Dupe results size ' + dupeResults.size());
        System.debug('dupe results: ' + dupeResults);

        for (Integer i = 0; i < dupeResults.size(); i ++) {

            for (Datacloud.DuplicateResult result : dupeResults[i].getDuplicateResults()) {

                if (result.matchResults.size() > 0 && result.getMatchResults()[0].matchRecords.size() > 0) {

                    System.debug('Duplicate found.');
                    System.debug('Duplicate Rule: ' + result.getDuplicateRule());

                    for (Datacloud.MatchResult matchResult : result.getMatchResults()) {

                        System.debug('Matching Rule: ' + matchResult.getRule());
                        System.debug('Matches found: ' + matchResult.getSize());

                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            System.debug('Match record: ' + matchRecord.getRecord());
                            dupeChurches.add((Account)matchRecord.getRecord());
                        }
                    }

                } else {

                    processedChurches.add(rawChurches[i]);

                }
                
            }
        }

        churches.put('Dupes', dupeChurches);
        churches.put('Non-dupes', processedChurches);

        return churches;
    }

    public static List<Account> checkCSPDupes(List<Account> churches, Id school) {

        Map<Id, Account> churchesById = new Map<Id, Account>();

        for (Account church : churches) {
            churchesById.put(church.Id, church);
        }

        List<Church_School_Partnership__c> dupes = [SELECT Id, Church_Account__c, School_Account__c
                                                    FROM Church_School_Partnership__c
                                                    WHERE School_Account__c = :school
                                                    AND Church_Account__c IN :churchesById.keySet()];

        if (dupes.size() > 0) {

            for (Church_School_Partnership__c dupe : dupes) {
                churchesById.remove(dupe.Church_Account__c);
            }
        }

        return churchesById.values();
    }

}
