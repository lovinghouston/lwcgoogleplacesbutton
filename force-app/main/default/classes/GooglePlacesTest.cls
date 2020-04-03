@isTest
private with sharing class GooglePlacesTest {
    
    @isTest
    static void testValidResponse() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
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
        }
        Test.stopTest();
    }

    @isTest
    static void testBadStatusCode() {

    }

    @isTest
    static void testGoogleErrorMessage() {

    }

    @isTest
    static void testDuplicates() {

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
}
