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
            for (Integer i = 0; i < 5; i ++) {
                System.debug('raw data: ' + results[i]);
                Map<String,Object> formatted = (Map<string,Object>) results[i];
                System.debug('Creating Churches: ');
                createChurches(formatted);
                createCSPs(formatted);

            }
            System.debug('Status: ' + googleresults.get('status'));
            System.debug('Error Message: ' + googleresults.get('error_message'));
        }
    }
    
    public static void createChurches(Map<String,Object> result) {
        Account church = new Account();
        church.Name = (String)result.get('Name');
        System.debug(result.get('formatted_address'));
        String address = (String)result.get('formatted_address');
        List<String> fullAddress = formatAddress(address);
        System.debug('formatted address: ');
        for (String value : fullAddress) {
            System.debug(value);
        }        
    }
    
    public static List<String> formatAddress (String address) {
        List<String> formatted = address.split(', ');
        System.debug('List size: ' + formatted.size());
        if (formatted.size() == 3) {
            List<String> stateZip = formatted[2].split(' ');
            formatted.remove(2);
            for (String value : stateZip) {
                formatted.add(value);
            }
        }
        return formatted;
    }
    
    public static void createCSPs(Map<String,Object> result) {
        
    }
}