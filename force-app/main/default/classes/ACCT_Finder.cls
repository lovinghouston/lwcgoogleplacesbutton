//Utility class for finding viable Accounts to create CSP records on

public with sharing class ACCT_Finder {
    public static Id schoolRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId();
    public static Id churchRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId();

    public ACCT_Finder() {
        // After the map is implemented 
        // this.recordTypes = new Map<String, Id> ();
        // this.recordTypes.put('School', Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId());
        // this.recordTypes.put('Church', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId());
    }

    @InvocableMethod (label='Get potential Accounts')
    public static List<Account> findAccountsBatch (List<ACCT_Finder_Request> requests) {
        List<Account> relatedAccounts = new List<Account>();

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
        
        if (inputAccount.RecordTypeId == churchRT) {
            accountsToCompare = ACCT_Finder.getRelatedAccounts('Church');
        }
        else if (inputAccount.RecordTypeId == schoolRT) {
            accountsToCompare = ACCT_Finder.getRelatedAccounts('School');
        }
        
        if (accountsToCompare.size() > 0) {
            for (Account account : accountsToCompare) {

                // Max 100 Accounts returned
                if (validAccounts.size() == 100) {
                    break;
                }

                Integer distance = ACCT_Finder.calculateDistance(inputAccount, account).intValue();

                if (distance < thresholdDistance) {
                    validAccounts.add(account);
                }

            }
        }

        return validAccounts;
    }

    // Utility method for calculating distance btwn given input and comparison account
    public static Double calculateDistance (Account inputAccount, Account compareAccount) {
        Location inputLocation = Location.newInstance(inputAccount.BillingLatitude, inputAccount.BillingLongitude);
        Location compareLocation = Location.newInstance(compareAccount.BillingLatitude, compareAccount.BillingLongitude);

        return Location.getDistance(inputLocation, compareLocation, 'mi');
    }

    // Query to get all potential church or school Accounts based on the type of input account
    public static List<Account> getRelatedAccounts (String type) {
        List<Account> relatedAccounts = new List<Account> ();

        // Re-factor to get record Type id from the map
        if (type.equals('School')) {
            relatedAccounts = [SELECT Id, Name, BillingLatitude, BillingLongitude
                                FROM Account
                                WHERE account.RecordTypeId = :churchRT
                                AND BillingLongitude != null
                                AND BillingPostalCode != null
                                LIMIT 10000];
        }

        else if (type.equals('Church')) {
            relatedAccounts = [SELECT Id, Name, BillingLatitude, BillingLongitude
                                FROM Account
                                WHERE account.RecordTypeId = :schoolRT
                                AND BillingLongitude != null
                                AND BillingPostalCode != null
                                AND Type != 'School District'
                                LIMIT 10000];        
        }

        return relatedAccounts;
    }
    
    // Convert input accounts to separate by school and church (for use if we decide to intake a list of Accounts in the future)
    public static Map<String, List<Account>> processAccountsByType (List<Account> inputAccounts) {
        Map<String, List<Account>> accountsByType = new Map<String, List<Account>> ();
        accountsByType.put('School', new List<Account>());
        accountsByType.put('Church', new List<Account>());

        for (Account account : inputAccounts) {

            if (account.RecordTypeId == churchRT) {
                accountsByType.get('Church').add(account);
            }

            else if (account.RecordTypeId == schoolRT) {
                accountsByType.get('School').add(account);
            }
        }

        return accountsByType;
    }

     
}
