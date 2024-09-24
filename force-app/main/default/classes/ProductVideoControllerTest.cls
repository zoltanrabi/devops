@IsTest
public with sharing class ProductVideoControllerTest {

    private static Id productId = null;
    private static Id userId = null;

    private static void setupData() {
        Account testAccount = new Account(
                Name='Universal Testing',
                AccountNumber='0118999'
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
        userId = ProductVideoControllerTestUtils.createUser(null);

        ProductVideoControllerTestUtils.assignPermissionSetToUser(userId, 'B2B_LE_Video_Player_Admin');

        ProductVideoControllerTestUtils.createProduct2('Sample product', '24601', 'An excellent product');



    }

    @IsTest
    /*
        Parent record is an exact match for requested language 
    */
    public static void testCode1() {

        User adminUser = ProductVideoControllerTestUtils.createAdminUser();

        System.runAs(adminUser) {

            setupData();

        }

        Id recordId = productId;

        User normalUser = ProductVideoControllerTestUtils.getUser(userId);

        Test.startTest();

            System.runAs(normalUser) {

            Id productVideoId = ProductVideoControllerTestUtils.createProductVideo(productId, 'en_US');

            ProductVideoControllerTestUtils.createProductVideoI18N(productVideoId, 'es');

            String results = ProductVideoController.getVideos(recordId, '5', 'en_US');

            System.debug('results: ' + results);

            List<Object> resultsList = (List<Object>)JSON.deserializeUntyped(results);

            Map<String, Object> pvMap = (Map<String, Object>)resultsList.get(0);

            String id = (String)pvMap.get('id');

            System.assertEquals(id, productVideoId);

        }

        Test.stopTest();

    }

    @IsTest
    /*
        Child record contains a matching locale prefix.
    */
    public static void testCode2() {

        User adminUser = ProductVideoControllerTestUtils.createAdminUser();

        System.runAs(adminUser) {

            setupData();

        }

        User normalUser = ProductVideoControllerTestUtils.getUser(userId);

        Test.startTest();

            System.runAs(normalUser) {

                Id recordId = productId;

                Id productVideoId = ProductVideoControllerTestUtils.createProductVideo(productId, 'en_US');

                ProductVideoControllerTestUtils.createProductVideoI18N(productVideoId, 'es');

                String results = ProductVideoController.getVideos(recordId, '5', 'es_MX');

                System.debug('results: ' + results);

                List<Object> resultsList = (List<Object>)JSON.deserializeUntyped(results);

                Map<String, Object> pvMap = (Map<String, Object>)resultsList.get(0);

                String id = (String)pvMap.get('id');

                System.assertEquals(id, productVideoId);

            }

        Test.stopTest();

    }

    @IsTest
    /*
        Child record contains an exact match locale.
    */
    public static void testCode3() {

        User adminUser = ProductVideoControllerTestUtils.createAdminUser();

        System.runAs(adminUser) {

            setupData();

        }

        User normalUser = ProductVideoControllerTestUtils.getUser(userId);

        Test.startTest();

            System.runAs(normalUser) {

                Id recordId = productId;

                Id productVideoId = ProductVideoControllerTestUtils.createProductVideo(productId, 'en_US');

                ProductVideoControllerTestUtils.createProductVideoI18N(productVideoId, 'es');

                String results = ProductVideoController.getVideos(recordId, '5', 'es');

                System.debug('results: ' + results);

                List<Object> resultsList = (List<Object>)JSON.deserializeUntyped(results);

                Map<String, Object> pvMap = (Map<String, Object>)resultsList.get(0);

                String id = (String)pvMap.get('id');

                System.assertEquals(id, productVideoId);

            }

        Test.stopTest();

    }
    
}