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
    public static HttpResponse createCall(Decimal longitude, Decimal latitude, Integer radius, String key, String type) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String googleNearbyPlacesUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + longitude + ',' + latitude + '&radius=' + radius + '&type=' + type + '&key=' + key;

        request.setEndpoint(googleNearbyPlacesUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        return response;
    }

    public static Map<Integer, Map<String,Object>> processResults(HttpResponse response) {

        Map<Integer, Map<String,Object>> bulkData = new Map<Integer, Map<String,Object>>();
        Map<String, Object> googleResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> results = (List<Object>) googleResults.get('results');
        
        for (Integer i = 0; i < results.size(); i ++) {

            System.debug(results[i]);
            // Setting the limit of records created to 5 for now. In the future, can add functionality to dynamically create a requested number of records.
            if (i == 5) {
                break;
            }

            Map<String,Object> formatted = (Map<string,Object>) results[i];
            bulkData.put(i, formatted);

        }

        // Log any error messages if present.
        System.debug('Status: ' + googleResults.get('status'));
        System.debug('Error Message: ' + googleResults.get('error_message'));
        
        return bulkData;
    } 
}
