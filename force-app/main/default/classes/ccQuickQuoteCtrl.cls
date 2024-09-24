public class ccQuickQuoteCtrl {
    
    @AuraEnabled // Annotation that makes the method available to Lightning Components
    public static Id createQuote(String StartDate, Integer SubscriptionTerm){
        Id stdPriceBook = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
        //ID contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
        ID contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        ID AccID  = [Select AccountID from Contact where id =:contactId].AccountId;
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Type__c='Quote',
                SBQQ__Status__c='Draft',
                SBQQ__SubscriptionTerm__c=SubscriptionTerm,
                SBQQ__StartDate__c=Date.parse(StartDate).addDays(1),
                SBQQ__ExpirationDate__c=System.today()+60,
                SBQQ__PricebookId__c = stdPriceBook,
                SBQQ__Account__c=AccId,
                SBQQ__PrimaryContact__c=contactId
        );

        try {
            Database.insert(q);
            System.debug('Successfully inserted new Quote: ' + q.Id);
        } catch (DmlException e) {
            System.debug('An error occurred inserting the Quote: ' + e);
            System.debug('Stack trace:' + e.getStackTraceString());
        }

        return q.Id;
        
    }
    
 
}