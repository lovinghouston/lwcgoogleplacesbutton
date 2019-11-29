public class ACCT_Finder_Request implements Comparable {

    @InvocableVariable (label='Account Id')
    public Id inputAccountId;

    @InvocableVariable (label='Threshold Distance')
    public Double threshold;

    public Account holderAccount;

    // Method for testing the Request in dev console
    public void setInputs(Id inputAccountId, Double threshold) {
        this.inputAccountId = inputAccountId;
        this.threshold = threshold;
    }

    public void holdValues(Account account, Double distance) {
        this.threshold = distance;
        this.holderAccount = account;
    }

    public Integer compareTo (Object compareTo) {
        ACCT_Finder_Request compareToReq = (ACCT_Finder_Request)compareTo;

        if (threshold == compareToReq.threshold) {
            return 0;
        }
        if (threshold < compareToReq.threshold) {
            return -1;
        }
        return 1;
    }
    
    public Account getAccount () {
        return holderAccount;
    }
}
