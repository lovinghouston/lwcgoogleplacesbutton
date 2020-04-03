@isTest
public with sharing class GooglePlacesTestData {
    
    public static List<Account> createSchoolAccount(Integer amount) {
        String schoolRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId();
        List<Account> schools = new List<Account>();
        Set<Id> schoolId = new Set<Id>();

        for (Integer i = 0; i < amount; i ++) {

            Account school = new Account();
            school.Name = 'Test School ' + i;
            school.RecordTypeId = schoolRT;
            school.Type = 'School';
            school.BillingStreet = '6587 Jaffe Ct';
            school.BillingCity = 'San Deiego';
            school.BillingState = 'CA';
            school.BillingCountry = 'US';
            school.BillingPostalCode = '92119';
            schools.add(school);
        }
        insert schools;
        for (Account school : schools) {
            schoolId.add(school.Id);
        }
        List<Account> queriedSchools = [SELECT Id, BillingLongitude, BillingLatitude, Type FROM Account WHERE Id IN :schoolId];

        return queriedSchools;
    }

    public static List<Account> createDuplicateChurchAccount(Integer amount) {
        String churchRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();
        List<Account> churches = new List<Account>();
        Set<Id> churchId = new Set<Id>();

        for (Integer i = 0; i < amount; i ++) {

            Account church = new Account();
            church.Name = 'Del Mar Church ' + i;
            church.RecordTypeId = churchRT;
            church.Type = 'Church';
            church.BillingStreet = '1425 Ocean Avenue';
            church.BillingCity = 'Del Mar';
            church.BillingState = 'CA';
            church.BillingCountry = 'US';
            church.BillingPostalCode = '92014';
            churches.add(church);
        }
        insert churches;
        for (Account church : churches) {
            churchId.add(church.Id);
        }
        List<Account> queriedSchools = [SELECT Id, BillingLongitude, BillingLatitude, Type FROM Account WHERE Id IN :churchId];

        return queriedSchools;
    }

    public static String textSearchValidKey() {
        String result = '{' +
        '   \"results\" : [' +
        '       {' +
        '           \"formatted_address\" : \"1425 Ocean Avenue, Del Mar, CA 92014\",' +
        '           \"name\" : \"Del Mar Church\",' +
        '           \"place_id\" : \"1425Ocean\",' +
        '           \"rating\" : 5,' +
        '           \"user_ratings_total\" : 20' +
        '       }' +
        '   ],' +
        '   \"status\" : \"OK\"' +
        '}';
        return result;
    }

    public static String textSearchInvalidKey() {
        String result = '{' +
        '   \"error_message\" : \"The provided API key is invalid.\",' +
        '   \"results\" : [],' +
        '   \"status\" : \"REQUEST_DENIED\"' +
        '}';
        return result;
    }

    public static String detailsSearchValidKey() {
        String result = '{' +
        '   \"result\" : {' +
        '       \"address_components\" : [' +
        '           {' +
        '               \"long_name\" : \"1425\",' +
        '               \"short_name\" : \"1425\",' +
        '               \"types\" : [ \"street_number\" ]' +
        '           },' +
        '           {' +
        '               \"long_name\" : \"Ocean Avenue\",' +
        '               \"short_name\" : \"Ocean Ave\",' +
        '               \"types\" : [ \"route\" ]' +
        '           },' +
        '           {' +
        '               \"long_name\" : \"Del Mar\",' +
        '               \"short_name\" : \"Del Mar\",' +
        '               \"types\" : [ \"locality\" ]' +
        '           },' +
        '           {' +
        '               \"long_name\" : \"California\",' +
        '               \"short_name\" : \"CA\",' +
        '               \"types\" : [ \"administrative_area_level_1\" ]' +
        '           },' +
        '           {' +
        '               \"long_name\" : \"United States\",' +
        '               \"short_name\" : \"US\",' +
        '               \"types\" : [ \"country\" ]' +
        '           },' +
        '           {' +
        '               \"long_name\" : \"92014\",' +
        '               \"short_name\" : \"92014\",' +
        '               \"types\" : [ \"postal_code\" ]' +
        '           }' +
        '       ],' +
        '       \"formatted_phone_number\" : \"1234567890\",' +
        '       \"name\" : \"Del Mar Church\",' +
        '       \"website\" : \"delmarchurch\"' +
        '       },' +
        '   \"status\" : \"OK\"' +
        '}';
        return result;
    }
}
