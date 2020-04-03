@isTest
private with sharing class GooglePlacesTest {
    
    @isTest
    static void testValidResponse() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.debug(wraps);
        System.assert(wraps.size() > 0,
        'Response should contain data table wrappers.');
    }

    @isTest
    static void testInvalidKey() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutInvalidKey());
        try {
            GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        } catch (Exception e) {
            System.debug('Test Error message: ' + e.getMessage());
            System.assert(e.getMessage() == 'Error with Google Call: Status: REQUEST_DENIED Error Message: The provided API key is invalid.',
            'Google Response should contain error message.');
        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidAddress() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        try {
            GooglePlaces.searchPlace(school.Id, null, null, 20, school.Type);
        } catch (Exception e) {
            System.debug('Test Error message: ' + e.getMessage());
            System.assert(e.getMessage() == 'Account Longitude and/or latitude are invalid.',
            'Longitude/Latitude error should be thrown.');
        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidType() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        try {
            GooglePlaces.searchPlace(school.Id, 56.123, 81.123, 20, 'Church');
        } catch (Exception e) {
            System.debug('Test Error message: ' + e.getMessage());
            System.assert(e.getMessage() == 'Type needs to be school.',
            'Type error should be thrown.');
        }
        Test.stopTest();
    }

    @isTest
    static void testBadStatusCode() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutBadStatusCode());
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.assert(wraps == null, 'Should return nothing if status code is bad.');
    }

    @isTest
    static void testGoogleErrorMessage() {

    }

    @isTest
    static void testDuplicates() {
        Account duplicateChurch = GooglePlacesTestData.createDuplicateChurchAccount(1)[0];
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.assert(wraps.size() > 0, 'Should return data even if dupe is present.');
        System.assert(wraps[0].website == null, 'If duplicate is found, the website will not be updated on the existing Account.');

    }

    @isTest
    static void testNoDuplicates() {

    }

    @isTest
    static void testEmptyRawChurches() {

    }

    @isTest
    static void testInvalidReturnAddress() {

    }

    @isTest
    static void testNoStreetNumberOnReturnAddress() {

    }

    @isTest
    static void testExistingCSPs() {

    }

    public class GoogleMockCalloutValidKey implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            if (request.getEndpoint().startsWith('https://maps.googleapis.com/maps/api/place/textsearch/json')) {
                response.setBody(GooglePlacesTestData.textSearchValidKey());
            }
            if (request.getEndpoint().startsWith('https://maps.googleapis.com/maps/api/place/details/json')) {
                response.setBody(GooglePlacesTestData.detailsSearchValidKey());
            }
            return response;
        }
    }
    
    public class GoogleMockCalloutInvalidKey implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(GooglePlacesTestData.textSearchInvalidKey());
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }
    }

    public class GoogleMockCalloutBadStatusCode implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(GooglePlacesTestData.textSearchInvalidKey());
            response.setStatusCode(0);
            return response;
        }
    }
}
