//Utility class for finding viable Accounts to create CSP records on

public with sharing class ACCT_Finder {

    // add map of record type Ids
    //
    // public Map<String, Id> recordTypes;

    public ACCT_Finder() {
        // After the map is implemented 
        // this.recordTypes = new Map<String, Id> ();
        // this.recordTypes.put('School', Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId());
        // this.recordTypes.put('Church', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Church').getRecordTypeId());
    }

    
    public List<Account> findAccounts (Account inputAccount, Integer thresholdDistance) {
        List<Account> accountsToCompare = new List<Account>();
        List<Account> validAccounts = new List<Account>();
        
        // refactor to get IDs from map
        if (inputAccount.RecordTypeId == '0121N000000qpORQAY') {
            accountsToCompare = ACCT_Finder.getRelatedAccounts('Church');
        }
        else if (inputAccount.RecordTypeId == '0121N000000qpO2QAI') {
            accountsToCompare = ACCT_Finder.getRelatedAccounts('School');
        }
        
        if (accountsToCompare.size() > 0) {
            for (Account account : accountsToCompare) {

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
            relatedAccounts = [SELECT Id, Name
                                FROM Account
                                WHERE account.RecordTypeId = '0121N000000qpORQAY'
                                AND BillingPostalCode != null
                                LIMIT 10000];
        }

        else if (type.equals('Church')) {
            relatedAccounts = [SELECT Id, Name
                                FROM Account
                                WHERE account.RecordTypeId = '0121N000000qpO2QAI'
                                AND BillingPostalCode != null
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

            if (account.RecordTypeId == '0121N000000qpORQAY') {
                accountsByType.get('Church').add(account);
            }

            else if (account.RecordTypeId == '0121N000000qpO2QAI') {
                accountsByType.get('School').add(account);
            }
        }

        return accountsByType;
    }

     
}
