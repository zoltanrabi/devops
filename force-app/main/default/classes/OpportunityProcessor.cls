public class OpportunityProcessor {
    public static void updateOpportunityStage(Id opportunityId, String newStage) {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityId];
        opp.StageName = newStage;
        update opp;
    }

    public static Decimal calculateTotalAmount(List<Id> opportunityIds) {
        AggregateResult[] results = [SELECT SUM(Amount) total FROM Opportunity WHERE Id IN :opportunityIds];
        return (Decimal)results[0].get('total');
    }
}