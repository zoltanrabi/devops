public with sharing class CertificationSummaryController {

    public class Filters {
        @AuraEnabled
        public String employeeName { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<CertificateApplication> getCertificationsForAll(){
        List<Certificate_Application__c> certApps = [SELECT Contact__c, Certification__c, Name,  Certification__r.Acquired_certification_of_this_type__c, Certification__r.Name, Certification__r.Image_Name__c, Contact__r.Name FROM Certificate_Application__c ORDER BY Contact__r.Name ASC];
        List<CertificateApplication> certificateApplications = new List<CertificateApplication>();
        for (Certificate_Application__c result : certApps) {
            CertificateApplication data = new CertificateApplication();
            data.name = result.Contact__r.Name;
            data.certName = result.Certification__r.Name;
            data.badgeImage = '/resource/certificationBadges/' + result.Certification__r.Image_Name__c + '.png';
            data.autoNumber = result.Name;
            data.Id = result.Certification__c;
            data.nameId = result.Contact__c;
            certificateApplications.add(data);
        }        
        return certificateApplications;
    }

    @AuraEnabled(cacheable=true)
    public static List<Certification__c> getCertificationTypes(){
        return [SELECT Name, Id FROM Certification__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<CertyTypeData> getCertificationsByType(Filters filters){
        String queryParam = '';
        if (!String.isEmpty(filters.employeeName) && filters.employeeName !='All') {
            queryParam = ' WHERE Contact__r.Name =\'' + filters.employeeName + '\'';
        }
        AggregateResult[] groupedResults = Database.query('SELECT COUNT(Certification__c), Certification__r.Name, Certification__r.Training_Material__c FROM Certificate_Application__c' + queryParam +' GROUP BY Certification__r.Name, Certification__r.Training_Material__c');
        List<CertyTypeData> certType = new List<CertyTypeData>();
        for (AggregateResult result : groupedResults){
            CertyTypeData data = new CertyTypeData();
            data.name = (String)result.get('Name');
            data.count = (Integer)result.get('expr0');
            data.splittedImageName = data.name.split(' ');
            data.imageName = String.join(data.splittedImageName, '');
            data.badgeImage = '/resource/certificationBadges/' + data.ImageName + '.png';
            data.trainingMaterial = (String)result.get('Training_Material__c');
            if (queryParam == 'All' || queryParam == '') {
                data.filtered = false;
            } else {
                data.filtered = true;
            }
            if (data.count != 0) {
                certType.add(data);
            } 
        }
        return certType;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        return [SELECT Contact.Name, Contact.Id FROM Contact WHERE Contact.Account.Name = 'Budapest Salesforce Team' ORDER BY Contact.Name ASC];
    }

    public class CertificateApplication {
        @AuraEnabled
        public String name { get;set; }
        @AuraEnabled
        public String autoNumber { get;set; }
        @AuraEnabled
        public String certName { get;set; } 
        @AuraEnabled
        public String badgeImage { get;set; }
        @AuraEnabled
        public String Id { get;set; }
        @AuraEnabled
        public String nameId { get;set; }
    }

    public class CertyTypeData {
        @AuraEnabled
        public String name { get;set; }
        @AuraEnabled
        public Integer count { get;set; }
        @AuraEnabled
        public String badgeImage { get;set; }
        @AuraEnabled
        public List<String> splittedImageName { get;set; }
        @AuraEnabled
        public String imageName { get;set; }
        @AuraEnabled
        public String trainingMaterial { get;set; }
        @AuraEnabled
        public Boolean filtered { get;set; }
    }

}