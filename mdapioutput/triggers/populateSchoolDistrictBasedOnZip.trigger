trigger populateSchoolDistrictBasedOnZip on Account (before update, before insert) {

// Create and add zipcodes into a Set. Criteria set for only Churches with zipcodes populated and blank School Districts.
    Set<String> zipCodeSet = new Set<String>();

    for (Account a : Trigger.new) {
        if (a.RecordTypeId == '0121N000000qpORQAY' && a.BillingPostalCode != null && a.School_District_Lookup__c == null) {
            zipCodeSet.add(a.BillingPostalCode);
        }
    }

// Create List of School Distrct Accounts whose zipcode match that of the Church 
    List<Account> matchedSchoolDistricts = new List<Account>([SELECT Id, BillingPostalCode
                                            FROM Account
                                            WHERE Type = 'School District' 
                                            AND BillingPostalCode IN :zipCodeSet]);

    Map<String, Account> zipCodeMap = new Map<String, Account> ();
    Set<String> zipCodeKeyDuplicates = new Set<String>();

// Adding the zipcodes of the matched School Districts onto a Map for comparing to the original Church. This is also where 
// School Districts with the same zipcodes are added onto a set.
    for (Account p : matchedSchoolDistricts) {
        if (zipCodeMap.containsKey(p.BillingPostalCode)) {
            zipCodeKeyDuplicates.add(p.BillingPostalCode);
        }
        else {
            zipCodeMap.put(p.BillingPostalCode, p);
        }
    }

    for (String zipCode : zipCodeKeyDuplicates) {
        zipCodeMap.remove(zipCode);
    }

// Now comparing each Church account so that if its zip code matches one in the map, the corresponding school district
// is populated in that church's lookup field.     
    for (account a : Trigger.New) {
        if (zipCodeMap.containsKey(a.BillingPostalCode)) {
            Account match = zipCodeMap.get(a.BillingPostalCode);
            a.School_District_Lookup__c = match.Id;
        }
    } 
}

  
