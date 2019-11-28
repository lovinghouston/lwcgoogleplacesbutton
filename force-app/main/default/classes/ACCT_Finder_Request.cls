public class ACCT_Finder_Request {

    // Method for testing the Request in dev console
    public void setInputs(Id inputAccountId, Integer threshold) {
        this.inputAccountId = inputAccountId;
        this.threshold = threshold;
    }
    
    @InvocableVariable (label='Account Id')
    public Id inputAccountId;

    @InvocableVariable (label='Threshold Distance')
    public Integer threshold;
}
