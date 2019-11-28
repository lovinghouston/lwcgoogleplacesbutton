//Utility class for finding viable Accounts to create CSP records on

public with sharing class ACCT_Finder {
    public static Id SCHOOL_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId();
    public static Id CHURCH_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();

    public ACCT_Finder() {
        // After the map is implemented 
        // this.recordTypes = new Map<String, Id> ();
        // this.recordTypes.put('School', Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId());
        // this.recordTypes.put('Church', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId());
    }

    @InvocableMethod (label='Get potential Accounts')
    public static List<Account> findAccountsBatch (List<ACCT_Finder_Request> requests) {
        List<Account> relatedAccounts = new List<Account>();
        System.debug('Beginning invocable method');

        for (ACCT_Finder_Request request : requests) {
            relatedAccounts.addAll(findAccounts(request));
        }

        return relatedAccounts;
    }
    
    public static List<Account> findAccounts (ACCT_Finder_Request request) {
        List<Account> accountsToCompare = new List<Account>();
        List<Account> validAccounts = new List<Account>();
        Account inputAccount = request.inputAccount;
        Integer thresholdDistance = request.threshold;
        System.debug('Beginning process of flow request with Account ' + inputAccount.Name + ' and threshold distance of ' + thresholdDistance + ' miles.');
        
        if (inputAccount.Type.equals('Church')) {
            System.debug('Input Account is of type Church. Getting related School Accounts.');
            accountsToCompare = ACCT_Finder.getRelatedAccounts('School');
        }

        else if (inputAccount.Type.equals('School')) {
            System.debug('Input Account is of type School. Getting related Church Accounts');
            accountsToCompare = ACCT_Finder.getRelatedAccounts('Church');
        }
        
        if (accountsToCompare.size() > 0) {
            for (Account account : accountsToCompare) {

                // Potential improvement: Currently this loop will take the first 100 records that fit the requested proximity. This may leave out other potential accounts
                // that might be closer but are not touched because the loop breaks. One way would be to not break after hitting 100 records and letting it run through the whole
                // list, sorting the results by Distance, then trimming that list to 100 and returning that.
                // 
                // Max 100 Accounts returned
                if (validAccounts.size() == 100) {
                    System.debug('Found 100 Accounts, breaking loop.');
                    break;
                }

                Integer distance = ACCT_Finder.calculateDistance(inputAccount, account).intValue();
                System.debug('Account ' + account.Name + ' has distance of ' + distance + ' miles.');

                if (distance < thresholdDistance) {
                    System.debug('Found potential Account: ' + account.Name);
                    validAccounts.add(account);
                }

            }
        }

        return validAccounts;
    }

    // Utility method for calculating distance btwn given input and comparison account
    public static Double calculateDistance (Account inputAccount, Account compareAccount) {
        System.debug('Calculating distance between ' + inputAccount.Name + ' and ' + compareAccount.Name);

        Location inputLocation = Location.newInstance(inputAccount.BillingLatitude, inputAccount.BillingLongitude);
        Location compareLocation = Location.newInstance(compareAccount.BillingLatitude, compareAccount.BillingLongitude);

        System.debug('Location of ' + inputAccount.Name + ' : ' + inputLocation);
        System.debug('Location of ' + compareAccount.Name + ' : ' + compareLocation);

        return Location.getDistance(inputLocation, compareLocation, 'mi');
    }

    // Query to get all potential church or school Accounts based on the type of input account
    public static List<Account> getRelatedAccounts (String type) {
        List<Account> relatedAccounts = new List<Account>();

        // Potential performance improvement might be querying based on proximity by using the Billing Zip Code so this doesn't query all Accounts every run
        if (type.equals('Church')) {
            relatedAccounts = [SELECT Id, Name, BillingLatitude, BillingLongitude
                                FROM Account
                                WHERE Type = 'Church'
                                AND BillingLongitude != null
                                AND BillingPostalCode != null
                                LIMIT 10000];
        }

        else if (type.equals('School')) {
            relatedAccounts = [SELECT Id, Name, BillingLatitude, BillingLongitude
                                FROM Account
                                WHERE Type = 'School'
                                AND BillingLongitude != null
                                AND BillingPostalCode != null
                                LIMIT 10000];        
        }

        System.debug('Found ' + relatedAccounts.size() + ' potential Accounts before checking Distance.');
        return relatedAccounts;
    }
    
    // Convert input accounts to separate by school and church (for use if we decide to intake a list of Accounts in the future)
    public static Map<String, List<Account>> processAccountsByType (List<Account> inputAccounts) {
        Map<String, List<Account>> accountsByType = new Map<String, List<Account>> ();
        accountsByType.put('School', new List<Account>());
        accountsByType.put('Church', new List<Account>());

        for (Account account : inputAccounts) {

            if (account.RecordTypeId == CHURCH_RECORD_TYPE) {
                accountsByType.get('Church').add(account);
            }

            else if (account.RecordTypeId == SCHOOL_RECORD_TYPE) {
                accountsByType.get('School').add(account);
            }
        }

        return accountsByType;
    }

     
}
