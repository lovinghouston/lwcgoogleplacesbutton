public with sharing class GooglePlacesUtility {

    // Making sure inputs are acceptable before making the call
    public static void validateInputs(Id account, Decimal longitude, Decimal latitude, Integer radius, String type) {

        if (!type.equalsIgnoreCase('school')) {
            throwError('Invalid Account Type. Type needs to be school.');
        }

        if (longitude == null || latitude == null) {
            throwError('Invalid Account Billing Address. Billing Address Country and Zip are missing.');
        }
    }

    // Checking the results if status code and if any error message is returned by Google 
    public static void validateResults(HttpResponse response) {

        if (response.getStatusCode() != 200) {
            throwError(response.getStatus());
        }

        Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if (!googleResults.get('status').equals('OK')) {
            System.debug('Error: ' + googleResults.get('error_message'));
            throwError('Error with Google Call: Status: ' + googleResults.get('status') + ' Error Message: ' + googleResults.get('error_message'));
        }
    }

    // Method for creating API call for both textsearch and details call
    public static HttpResponse createApiCall(String callType, Map<String, String> callParameters) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = '';
        
        if (callType.equals('textsearch')) {
            endpoint = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + callParameters.get('latitude') + ',' + callParameters.get('longitude') + '&radius=' + callParameters.get('radius') + '&type=' + callParameters.get('type') + '&key=' + callParameters.get('apiKey');
        }
        if (callType.equals('details')) {
            endpoint = 'https://maps.googleapis.com/maps/api/place/details/json'+ '?place_id=' + callParameters.get('placeId') + '&key=' + callParameters.get('apiKey');
        }

        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        System.debug(callType + ' status code: ' + response.getStatusCode());
        System.debug(callType + ' status: ' + response.getStatus());
        validateResults(response);

        return response;
    }

    // Transform the returned Google response into readable Map
    public static Map<Integer, Map<String,Object>> processResults(HttpResponse response, String apiKey) {

        Map<Integer, Map<String,Object>> bulkData = new Map<Integer, Map<String,Object>>();
        System.debug('Test Response: ' + response);
        System.debug('Response Body: ' + response.getBody());
        Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('google Results: ' + googleResults);

        List<Object> results = (List<Object>) googleResults.get('results');
        
        for (Integer i = 0; i < results.size(); i ++) {

            Map<String,Object> formatted = (Map<String,Object>) results[i];
            bulkData.put(i, formatted);

        }

        for (Integer i = 0; i < bulkData.keySet().size(); i ++) {

            Map<String, Object> bulkDataDetails = bulkData.get(i);
            Map<String, String> callParameters = new Map<String, String>();
            callParameters.put('placeId', (String)bulkDataDetails.get('place_id'));
            callParameters.put('apiKey', apiKey);
            HttpResponse detailsResponse = createApiCall('details', callParameters);
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

    public static void throwError (String message) {
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);
        throw error;
    }
}