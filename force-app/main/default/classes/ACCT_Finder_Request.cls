public class ACCT_Finder_Request {

    // Method for testing the Request in dev console
    public void setInputs(Account input, Integer threshold) {
        this.inputAccount = input;
        this.threshold = threshold;
    }
    
    @InvocableVariable (label='Account')
    public Account inputAccount;

    @InvocableVariable (label='Threshold Distance')
    public Integer threshold;
}
