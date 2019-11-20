public class TestDataFactory {
    private static String CHURCH_ACCOUNT_RECORD_TYPE = '0121N000000qpORQAY';
    private static String SCHOOL_ACCOUNT_RECORD_TYPE = '0121N000000qpO2QAI';

    public static List<Account> getAccounts(Integer numberOfAccounts, String type) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numberOfAccounts; i ++) {
            Account acct = new Account();
            acct.Name = 'Testing Trigger Part ' + i;

            if (type == 'Church') {
                acct.RecordTypeId = CHURCH_ACCOUNT_RECORD_TYPE;
            }

            if (type == 'School District') {
                acct.Type = 'School District';
            }

            accts.add(acct);
        }

        return accts;

    }
}
