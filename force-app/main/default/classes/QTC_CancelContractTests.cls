@IsTest
private class QTC_CancelContractTests {
    @TestSetup static void setup() {
        Account testAccount = new Account(
            Name = 'Universal Testing',
            AccountNumber = '0118999'
        );
        
        Database.insert(testAccount);
        
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
        
        Product2 p = new Product2(Name = 'Test Subscription',
                                  IsActive = true,
                                  ProductCode = 'TS',
                                  SBQQ__SubscriptionPricing__c='Fixed Price',
                                  SBQQ__SubscriptionTerm__c=12,
                                  SBQQ__SubscriptionType__c='Renewable',
                                  CurrencyIsoCode = 'USD');
        
        insert p;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert price book entries for each product into the test pricebook
        PricebookEntry entries = new PricebookEntry(Product2Id=p.Id,
                                                    CurrencyIsoCode = 'USD',
                                                    IsActive = true,
                                                    Pricebook2Id = pricebookId,
                                                    UnitPrice = 100);
    
    
    // Insert all entries for all products.
    insert entries;
    
    Opportunity opp = new Opportunity(
        Name='Test Opty',
        StageName='Qualification',
        CloseDate=System.today(),
        Pricebook2Id=pricebookId,
        CurrencyIsoCode='USD'
        
        
    );
    
    insert opp;
    
    SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c ='Draft',
                                              SBQQ__Type__c = 'Quote',
                                              SBQQ__StartDate__c =System.today(),
                                              SBQQ__ExpirationDate__c=System.today().addMonths(1),
                                              SBQQ__SubscriptionTerm__c=12,
                                              SBQQ__Account__c=testAccount.Id,
                                              SBQQ__Opportunity2__c=opp.Id,
                                              SBQQ__PriceBook__c=pricebookId
                                             );
    
    insert quote;
    
        Contract con = new Contract(AccountId=testAccount.Id,
                                   Status='Draft',
                                   StartDate=System.today(),
                                   SBQQ__Quote__c=quote.Id,
                                   SBQQ__Opportunity__c=opp.Id,
                                   ContractTerm=12);
        
        insert con;
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Account__c=testAccount.Id,
                                                             SBQQ__Contract__c=con.Id,
                                                             SBQQ__Product__c=p.Id,
                                                             SBQQ__Quantity__c=1);
        
        insert sub;
        
        
        // Activate the contract        
        con.Status ='Activated';
        
        update con;
    
}
    
    @IsTest
    private static void testCancelContract() {
        Contract testCon = [SELECT Id FROM Contract LIMIT 1];
        // put id in std object
		ApexPages.currentPage().getParameters().put('id',testCon.Id);
        // pass in std object
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testCon);

        // pass std ctl to new instance of QTC_CancelContractCTRL
	    QTC_CancelContractCTRL testCancelController  = new QTC_CancelContractCTRL(stdCtrl);
        testCancelController.cancelContract();
        List<Opportunity> cancelOpp = [SELECT Id, SBQQ__AmendedContract__c FROM Opportunity WHERE SBQQ__AmendedContract__c =: testCon.Id];
        
        System.assert(cancelOpp.size()>0);
        
    }
        
}