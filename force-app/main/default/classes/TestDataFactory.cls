public class TestDataFactory {
    private static String CHURCH_ACCOUNT_RECORD_TYPE = '0121N000000qpORQAY';
    private static String SCHOOL_ACCOUNT_RECORD_TYPE = '0121N000000qpO2QAI';

    public static List<Account> getAccounts(Integer numberOfAccounts, String type) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numberOfAccounts; i ++) {
            Account acct = new Account();
            acct.Name = 'Test ' + i;

            if (type.equals('Church')) {
                acct.Type = 'Church';
            }

            if (type.equals('School District')) {
                acct.Type = 'School District';
            }

            if (type.equals('School')) {
                acct.Type = 'School';
            }

            acct.BillingLongitude = 20 + (i * 0.1);
            acct.BillingLatitude = 20 + (i * 0.1);

            accts.add(acct);
        }

        return accts;

    }
}
