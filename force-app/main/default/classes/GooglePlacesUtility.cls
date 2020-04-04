public with sharing class GooglePlacesUtility {

    // Making sure inputs are acceptable before making the call
    public static void validateInputs(Id account, Decimal longitude, Decimal latitude, Integer radius, String type) {

        if (!type.equalsIgnoreCase('school')) {
            AuraHandledException e = new AuraHandledException('Type needs to be school.');
            e.setMessage('Type needs to be school.');
            throw e;
        }

        if (longitude == null || latitude == null) {
            AuraHandledException e = new AuraHandledException('Account Longitude and/or latitude are invalid.');
            e.setMessage('Account Longitude and/or latitude are invalid.');
            throw e;
        }
    }

    // Textsearch API Call for the initial search
    public static HttpResponse createTextSearchCall(Decimal longitude, Decimal latitude, Integer radius, String apiKey, String type) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String googleTextSearchUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + latitude + ',' + longitude + '&radius=' + radius + '&type=' + type + '&key=' + apiKey;

        request.setEndpoint(googleTextSearchUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug('Text Search status code: ' + response.getStatusCode());
        System.debug('Text Search status: ' + response.getStatus());
    
        return response;
    }

    // Details call for more information about each place (placeId is from textSearch call)
    public static HttpResponse createDetailsCall(String apiKey, String placeId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String googleDetailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json'+ '?place_id=' + placeId + '&key=' + apiKey;

        request.setEndpoint(googleDetailsUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug('Details Call status code: ' + response.getStatusCode());
        System.debug('Details Call status: ' + response.getStatus());

        return response;
    }

    // Transform the returned Google response into readable Map
    public static Map<Integer, Map<String,Object>> processResults(HttpResponse response, String apiKey) {

        Map<Integer, Map<String,Object>> bulkData = new Map<Integer, Map<String,Object>>();
        System.debug('Test Response: ' + response);
        System.debug('Response Body: ' + response.getBody());
        Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('google Results: ' + googleResults);
        
        if (!googleResults.get('status').equals('OK')) {
            System.debug('Error: ' + googleResults.get('error_message'));
            AuraHandledException e = new AuraHandledException('Error with Google Call: Status: ' + googleResults.get('status') + ' Error Message: ' + googleResults.get('error_message'));
            e.setMessage('Error with Google Call: Status: ' + googleResults.get('status') + ' Error Message: ' + googleResults.get('error_message'));
            throw e;
        }

        List<Object> results = (List<Object>) googleResults.get('results');
        
        for (Integer i = 0; i < results.size(); i ++) {

            Map<String,Object> formatted = (Map<String,Object>) results[i];
            bulkData.put(i, formatted);

        }

        for (Integer i = 0; i < bulkData.keySet().size(); i ++) {

            Map<String, Object> bulkDataDetails = bulkData.get(i);
            HttpResponse detailsResponse = createDetailsCall(apiKey, (String)bulkDataDetails.get('place_id'));
            Map<String, Object> detailsData = (Map<String, Object>) JSON.deserializeUntyped(detailsResponse.getBody());
            Map<String, Object> detailsResults = (Map<String, Object>) detailsData.get('result');
            bulkDataDetails.putAll(detailsResults);
        }

        for (Integer index : bulkData.keySet()) {
            for (String key : bulkData.get(index).keySet()) {
                System.debug(key + ' : ' + bulkData.get(index).get(key));
            }
        }

        // Log any error messages if present.
        System.debug('Status: ' + googleResults.get('status'));
        System.debug('Error Message: ' + googleResults.get('error_message'));
        
        return bulkData;
    }

    // Utility method for formatting the address that is returned
    public static Map<String, String> formatAddress (List<Object> addresses) {
        Map<String, String> formatted = new Map<String, String>();
        
        System.debug('NEW CHURCH');
        for (Object address : addresses) {
            Map<String, Object> component = (Map<String, Object>) address;
            for (String key : component.keySet()) {

                if (key.equals('types')) {

                    List<String> typeStrings = new List<String>();
                    List<Object> typesObjects = (List<Object>) component.get(key);

                    for (Object typeObject : typesObjects) {
                        typeStrings.add(String.valueOf(typeObject));
                    }

                    if (typeStrings.contains('street_number')) { formatted.put('Street Number', (String)component.get('long_name')); }
                    if (typeStrings.contains('route')) { formatted.put('Street Name', (String)component.get('long_name')); }
                    if (typeStrings.contains('locality')) { formatted.put('City', (String)component.get('long_name')); }
                    if (typeStrings.contains('administrative_area_level_1')) { formatted.put('State', (String)component.get('long_name')); }
                    if (typeStrings.contains('country')) { formatted.put('Country', (String)component.get('long_name')); }
                    if (typeStrings.contains('postal_code')) { formatted.put('Zip', (String)component.get('long_name')); }
                }
            }
        }

        System.debug(formatted);
        return formatted;
    }
}