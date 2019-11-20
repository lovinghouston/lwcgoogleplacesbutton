@isTest
private class TestSchoolDistrictTrigger {

    @isTest
    static void TestOneDistrictMatch() {

        List<Account> church = TestDataFactory.getAccounts(1, 'Church District');
        List<Account> district = TestDataFactory.getAccounts(1, 'School District');

        church[0].BillingPostalCode = '54321';
        district[0].BillingPostalCode = '54321';

        Test.startTest();
        insert(district);
        insert(church);
        Test.stopTest();

        System.assert(church[0].School_District_Lookup__c == district[0].Id);
    }

    @isTest
    static void TestNoDistrictMatch() {

    }

    @isTest
    static void TestMultipleDistrictMatches() {

    }

    @isTest
    static void TestMatchesWithBulkUpload() {

    }
}
