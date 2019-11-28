@isTest
private with sharing class Test_ACCT_Finder {

    private Test_ACCT_Finder() {
    }

    @TestSetup
    static void setup() {
        List<Account> churchAccounts = TestDataFactory.getAccounts(150, 'Church');
        List<Account> schoolAccounts = TestDataFactory.getAccounts(150, 'School');
        
        try {
            insert churchAccounts;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        try {
            insert schoolAccounts;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void testRelatedAccountReturn() {
        List<ACCT_Finder_Request> requests = new List<ACCT_Finder_Request>();
        ACCT_Finder_Request request1 = new ACCT_Finder_Request();
        Account inputAccount = [SELECT Id, Name, BillingLongitude, BillingLatitude, Type
                                FROM Account
                                WHERE Name LIKE '%Test%'
                                LIMIT 1];
        request1.setInputs(inputAccount.Id, 10);
        requests.add(request1);

        Test.startTest();

        List<List<Account>> results = ACCT_Finder.findAccountsBatch(requests);
        List<Account> relatedAccounts = results[0];

        Test.stopTest();

        System.assert(relatedAccounts.size() > 1);
        
        // Assert that related accounts were found
        // Assert that the distance is less than threshold
        // Assert that the type of returned account is expected
    }
}
