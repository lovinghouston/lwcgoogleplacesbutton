@isTest
private with sharing class GooglePlacesTest {
    
    @isTest
    static void testValidResponse() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        System.debug('Test Schhol ' + school);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleMockCalloutValidKey());
        GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
    }

    @isTest
    static void testInvalidKey() {

    }

    @isTest
    static void testInvalidAddress() {

    }

    @isTest
    static void testInvalidType() {

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

    private class GoogleMockCalloutValidKey implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint().startsWith('https://maps.googleapis.com/maps/api/place/textsearch/json')) {
                response.setBody(GooglePlacesTestData.textSearchValidKey());
                response.setStatusCode(200);
            }
            if (request.getEndpoint().startsWith('https://maps.googleapis.com/maps/api/place/details/json')) {
                response.setBody(GooglePlacesTestData.detailsSearchValidKey());
                response.setStatusCode(200);
            }
            return response;
        }
    }
}
