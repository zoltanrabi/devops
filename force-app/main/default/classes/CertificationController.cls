public with sharing class CertificationController {

    @AuraEnabled(cacheable=true)
    public static List<Certificate_Application__c> getCertificationsForAll(){
        return [SELECT Certification__r.Acquired_certification_of_this_type__c, Certification__r.Name, Contact__r.Name FROM Certificate_Application__c ORDER BY Contact__r.Name ASC];
    }

    @AuraEnabled(cacheable=true)
    public static List<CertyTypeData> getCertificationsByType(){
        AggregateResult[] groupedResults = [SELECT COUNT(Certification__c), Certification__r.Name FROM Certificate_Application__c GROUP BY Certification__r.Name];
        List<CertyTypeData> certType = new List<CertyTypeData>();
        for (AggregateResult result : groupedResults){
            CertyTypeData data = new CertyTypeData();
            data.name = (String)result.get('Name');
            data.count = (Integer)result.get('expr0');
            certType.add(data);
        }
        return certType;
    }

    public class CertyTypeData {
        @AuraEnabled
        public String name { get;set; }
        @AuraEnabled
        public Integer count { get;set; }
    }

}