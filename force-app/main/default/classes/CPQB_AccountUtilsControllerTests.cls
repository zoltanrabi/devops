@isTest
public class CPQB_AccountUtilsControllerTests {
   @TestSetup static void setup(){
        Account testAccount = new Account(
                Name='Universal Testing',
                AccountNumber='0118999'
        );

        Database.insert(testAccount);

        Contact testContact = new Contact(
                AccountId=testAccount.Id,
                FirstName='Test',
                LastName='User'
        );

        Database.insert(testContact);

        blng__BillingConfig__c blngConfig = new blng__BillingConfig__c(Name='DISABLE_TRIGGERS',
                                                                        blng__BooleanValue__c=true);
        Database.insert(blngConfig);
        blng__BillingRule__c billingRule = new blng__BillingRule__c(
            Name = 'Invoice w/ Special Treatment',
            blng__Active__c = true,
            blng__GenerateInvoices__c = 'No',
            blng__InitialBillingTrigger__c = 'Order Product Activation Date'
        );
        Database.insert(billingRule);

        blng__RevenueRecognitionRule__c revenueRecognitionRule = new blng__RevenueRecognitionRule__c(
            Name = '100% Ratable (Monthly)',
            blng__CreateRevenueSchedule__c = 'No',
            blng__Active__c = true
        );
        Database.insert(revenueRecognitionRule);
        blng__TaxRule__c taxRule = new blng__TaxRule__c(
            Name = 'Standard Tax Rule',
            blng__Active__c = true,
            blng__TaxableYesNo__c = 'Yes'
        );
        Database.insert(taxRule);
    }

    @isTest
    public static void resetAccountTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01'
        );

        Database.insert(p);
        SBQQ__ContractedPrice__c cp = new SBQQ__ContractedPrice__c(SBQQ__Account__c=accId, SBQQ__Price__c=100, SBQQ__Product__c=p.Id);
        Database.insert(cp);
        CPQB_AccountUtilsController.resetAccount(accId, false);
        SBQQ__ContractedPrice__c[] cpToDelete = [SELECT Id FROM SBQQ__ContractedPrice__c WHERE SBQQ__Account__c = :accId];
        System.assert(cpToDelete.size() == 1, 'Contracted Prices not Deleted');
    }

    @isTest
    public static void resetAccountDeleteContractedTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01'
        );

        Database.insert(p);
        SBQQ__ContractedPrice__c cp = new SBQQ__ContractedPrice__c(SBQQ__Account__c=accId, SBQQ__Price__c=100, SBQQ__Product__c=p.Id);
        Database.insert(cp);
        CPQB_AccountUtilsController.resetAccount(accId, true);
        SBQQ__ContractedPrice__c[] cpToDelete = [SELECT Id FROM SBQQ__ContractedPrice__c WHERE SBQQ__Account__c = :accId];
        System.assert(cpToDelete.size() == 0, 'Contracted Prices Deleted');
    }

    @isTest
    public static void resetAccountAndQuoteTest() {
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        CPQB_AccountUtilsController.resetAccountAndQuote(accId, false);
        SBQQ__Quote__c[] quotesToDelete = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Id = :accId];
        System.assert(quotesToDelete.size() == 1, 'New Quote Generated');
        Opportunity[] opportinitiesToDelete = [SELECT 
                                                    Id, 
                                                    AccountId 
                                                FROM Opportunity 
                                                WHERE AccountId = :accId];
        System.assert(opportinitiesToDelete.size() == 1, 'New Opportunity Generated');
    }
}