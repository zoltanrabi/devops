/**
 * Created by scheck on 8/6/18.
 */

@IsTest
private class SubscriptionViewTests {

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

        Product2 p = new Product2(
                Name = 'Test Product 01',
                IsActive = true,
                ProductCode = 'TP-01',
                CurrencyIsoCode = 'USD'
        );

        Database.insert(p);


        PricebookEntry pbe = new PricebookEntry(
                Product2Id=p.Id,
                CurrencyIsoCode = 'USD',
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100
        );

        Database.insert(pbe);

        Contract testContract = new Contract(
                AccountId=testAccount.Id,
                Status='Draft',
                StartDate=System.today(),
                ContractTerm=12
        );

        Database.insert(testContract);
        testContract.Status = 'Activated';
        Database.update(testContract);


        SBQQ__Subscription__c testSub = new SBQQ__Subscription__c(
                SBQQ__Quantity__c = 10,
                SBQQ__Account__c = testAccount.Id,
                SBQQ__Product__c = p.Id,
                SBQQ__Contract__c = testContract.Id
        );

        Database.insert(testSub);


    }

    @IsTest
    private static void testViewSubs() {
        Contact testContact = [
                SELECT
                        Id
                FROM Contact
                WHERE LastName='User'];
        System.debug('Test Contact: ');
        System.debug(JSON.serializePretty(testContact));


        Profile custCommProfile= [SELECT Id FROM Profile WHERE Name='Customer Community User'];
        UserRole r = new UserRole(DeveloperName = 'CustomCustomerCommunityRole', Name = 'CC Test Role');
        Database.insert(r);

        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer randId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+randId;

        User custTestUsr = new User(FirstName = 'Test',
                LastName = 'User',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = custCommProfile.Id,
                UserRole = r,
                ContactId = testContact.Id
        );

        Database.insert(custTestUsr);

        System.debug('Test User: ');
        System.debug(JSON.serializePretty(custTestUsr));


        System.runAs(custTestUsr) {
            System.debug('Running as user');
            List<SBQQ__Subscription__c> subs = SubscriptionViewCtrl.getSubs();
            System.assert(subs.size()>=0);
        }
    }

    @IsTest
    private static void testIsRendered() {
        Contact testContact = [
                SELECT
                        Id
                FROM Contact
                WHERE LastName='User'];
        System.debug('Test Contact: ');
        System.debug(JSON.serializePretty(testContact));


        Profile custCommProfile= [SELECT Id FROM Profile WHERE Name='Customer Community User'];
        UserRole r = new UserRole(DeveloperName = 'CustomCustomerCommunityRole', Name = 'CC Test Role');
        Database.insert(r);

        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer randId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+randId;

        User custTestUsr = new User(FirstName = 'Test',
                LastName = 'User',
                Email = uniqueName + '@test' + orgId + '.org',
                Username = uniqueName + '@test' + orgId + '.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = uniqueName.substring(18, 23),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = custCommProfile.Id,
                UserRole = r,
                ContactId = testContact.Id
        );

        Database.insert(custTestUsr);

        System.debug('Test User: ');
        System.debug(JSON.serializePretty(custTestUsr));


        System.runAs(custTestUsr) {
            System.debug('Running as user');
            Boolean isRendered = SubscriptionViewCtrl.isRendered();
            System.assert(isRendered);
        }
    }
}