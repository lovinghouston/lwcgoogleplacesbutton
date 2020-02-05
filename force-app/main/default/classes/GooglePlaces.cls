public class GooglePlaces {

 	public static void searchPlace(Decimal longitude, Decimal latitude, Integer radius, String type, String key){
        
        if (type != 'church') {
            System.debug('Type needs to be church.');
            return;
        }
        
        String googleNerbyPlacesUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json'+ '?location=' + longitude + ',' + latitude + '&radius=' + radius + '&type=' + type + '&key=' + key;
        System.debug(googleNerbyPlacesUrl);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(googleNerbyPlacesUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> googleresults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            List<Object> results = (List<Object>) googleresults.get('results');
            System.debug('Received the following results:');
            for (Object result: results) {
                System.debug(result);
                System.debug('formatting');
                Map<String,Object> formatted = (Map<string,Object>) result;
                System.debug(formatted.get('formatted_address'));
                System.debug(formatted.get('name'));

            }
            System.debug('Status: ' + googleresults.get('status'));
            System.debug('Error Message: ' + googleresults.get('error_message'));
        }
    }
    
    public static void createChurches(Account account) {
        
        
    }
}