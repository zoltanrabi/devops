@isTest
public class OpportunityProcessorTest {
    @isTest
    static void testUpdateOpportunityStage() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 1000);
        insert opp;

        Test.startTest();
        OpportunityProcessor.updateOpportunityStage(opp.Id, 'Closed Won');
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', updatedOpp.StageName, 'Opportunity stage should be updated');
    }

    @isTest
    static void testCalculateTotalAmount() {
        Opportunity opp1 = new Opportunity(Name = 'Opp1', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 1000);
        Opportunity opp2 = new Opportunity(Name = 'Opp2', StageName = 'Prospecting', CloseDate = Date.today(), Amount = 2000);
        insert new List<Opportunity>{opp1, opp2};

        Test.startTest();
        Decimal total = OpportunityProcessor.calculateTotalAmount(new List<Id>{opp1.Id, opp2.Id});
        Test.stopTest();

        System.assertEquals(3000, total, 'Total amount should be calculated correctly');
    }
}