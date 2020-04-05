@isTest
private with sharing class GooglePlacesTest {
    
    @isTest
    static void testValidResponse() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        GoogleMockCallout callout = new GoogleMockCallout('validKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.debug(wraps);
        System.assert(wraps.size() > 0,
        'Response should contain data table wrappers.');
    }

    @isTest
    static void testInvalidKey() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        GoogleMockCallout callout = new GoogleMockCallout('invalidKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
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
        GoogleMockCallout callout = new GoogleMockCallout('validKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
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
        GoogleMockCallout callout = new GoogleMockCallout('validKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
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
        GoogleMockCallout callout = new GoogleMockCallout('badStatusCode');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        try {
            List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage() == 'The requested resource does not exist', 'Status codes that are not 200 should throw an exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testDuplicates() {
        Account duplicateChurch = GooglePlacesTestData.createDuplicateChurchAccount(1)[0];
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        GoogleMockCallout callout = new GoogleMockCallout('validKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.assert(wraps.size() > 0, 'Should return data even if dupe is present.');
        System.assert(wraps[0].website == null, 'If duplicate is found, the website will not be updated on the existing Account.');

    }

    @isTest
    static void testBadReturnAddress() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        GoogleMockCallout callout = new GoogleMockCallout('badAddress');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        try {
            List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        } catch (Exception e) {
            System.assert(e.getMessage() == 'Addresses returned by Google are not valid.', 'No churches created if return data is invalid.');
        }
        Test.stopTest();
    }

    @isTest
    static void testNoStreetNumberOnReturnAddress() {
        Account school = GooglePlacesTestData.createSchoolAccount(1)[0];
        GoogleMockCallout callout = new GoogleMockCallout('noStreetNumber');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(school.Id, 56.1232, 81.123, 20, school.Type);
        Test.stopTest();
        System.debug(wraps);
        System.assert(wraps.size() > 0,
        'Response should contain data table wrappers even if Street number is not in formatted address.');
    }

    @isTest
    static void testExistingCSPs() {
        List<Account> schools = GooglePlacesTestData.createSchoolAccount(1);
        List<Account> churches = GooglePlacesTestData.createDuplicateChurchAccount(1);
        GooglePlacesTestData.createExistingCSP(1, schools, churches);
        GoogleMockCallout callout = new GoogleMockCallout('validKey');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, callout);
        List<GooglePlaces.DataTableWrapper> wraps = GooglePlaces.searchPlace(schools[0].Id, 56.1232, 81.123, 20, schools[0].Type);
        Test.stopTest();
        System.assert(wraps.size() == 0, 'If existing CSP, no new CSP is created.');
    }

    public class GoogleMockCallout implements HttpCalloutMock {
        public String type;

        public GoogleMockCallout(String type) {
            this.type = type;
        }

        public HttpResponse respond (HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');

            if (request.getEndpoint().contains('textsearch')) {

                if (type.equals('validKey')) { response.setBody(GooglePlacesTestData.apiCallResponse('textsearch', 'validKey')); }

                if (type.equals('invalidKey')) { response.setBody(GooglePlacesTestData.apiCallResponse('textsearch', 'invalidKey')); }

                if (type.equals('badAddress')) { response.setBody(GooglePlacesTestData.apiCallResponse('textsearch', 'badAddress')); }

                if (type.equals('noStreetNumber')) { response.setBody(GooglePlacesTestData.apiCallResponse('textsearch', 'noStreetNumber')); }

            }
            if (request.getEndpoint().contains('details')) {

                if (type.equals('validKey')) { response.setBody(GooglePlacesTestData.apiCallResponse('details', 'validKey')); }

                if (type.equals('invalidKey')) { response.setBody(GooglePlacesTestData.apiCallResponse('textsearch', 'invalidKey')); }

                if (type.equals('badAddress')) { response.setBody(GooglePlacesTestData.apiCallResponse('details', 'badAddress')); }

                if (type.equals('noStreetNumber')) { response.setBody(GooglePlacesTestData.apiCallResponse('details', 'noStreetNumber')); }

            }
            if (type.equals('badStatusCode')) { response.setStatusCode(404); response.setStatus('The requested resource does not exist'); }

            return response;
        }
    }
}
