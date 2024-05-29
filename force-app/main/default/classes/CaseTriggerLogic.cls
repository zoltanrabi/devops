/**
 * @author: Zoltan Rabi - Accenture
 * @date: 2022.01.07.
 * @description: Logic for the CaseTriggerHandler
 */

public with sharing class CaseTriggerLogic {

        /**
     * @description: Set description to related Account
     */
    public static void setDescriptionForAccount(Map<Id, Case> newMap) {
        String result = '';
        Id accId = null;

        for(Case cs : newMap.values()) {    
            if(accId == null) { accId = cs.AccountId; }
            System.debug(cs);
            System.debug('1.'.equals(cs.Description));
            if('1.'.equals(cs.Description)) { result += cs.Subject.substring(0, 1); }
            if('2.'.equals(cs.Description)) { result += cs.Subject.substring(0, 1); }
            if('3.'.equals(cs.Description)) { result += cs.Subject.substring(0, 1); }
            if('4.'.equals(cs.Description)) { result += cs.Subject.substring(0, 1); }
            if('5.'.equals(cs.Description)) { result += cs.Subject.substring(0, 1); }
        }
        result = result.left(3) + '25' + result.right(2) + result.substring(0, 1).capitalize() + 'uFo';
        System.debug('uwu' + result);

        BypassControl.addBypass(BypassControl.ACCOUNTTRIGGERLOGIC_CREATECASESAFTERDESCRIPTIONCHANGE);
        Database.update(new Account(Id = accId, Description = 'https://www.youtube.com/watch?v=' + result));
        BypassControl.removeBypass(BypassControl.ACCOUNTTRIGGERLOGIC_CREATECASESAFTERDESCRIPTIONCHANGE);
    }

    /**
    * @date: 2022.01.07.
    * @description: When a new Case is created the related Account owner should receive an email, if the related Account Send Email checkbox is true.

    public static void sendEmailToAccountWhenCaseCreated(Map<Id,Case> newMap) {
        List<Id> accIds = new List<Id>();
        for(Case cs : newMap.values()) {
            accIds.add(cs.AccountId);
        }
        Map<Id, Account> relatedAccountMap = new Map<Id, Account>([SELECT Send_Email__c, OwnerId FROM Account WHERE Id IN : accIds]);
        Id orgId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Noreply'].Id;
        Contact newContact = new Contact(
            LastName = 'Bela',
            Email = 'noreply@tobela.com'
        );
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE developername='Notify_Account_Owner'];
        try {
            Database.insert(newContact);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    
        Messaging.SingleEmailMessage email;
        Messaging.SingleEmailMessage[] emails = new List<Messaging.SingleEmailMessage>();
    
        for(Case cs : newMap.values()) {
            if(relatedAccountMap.get(cs.AccountId).Send_Email__c == true) {
                email = new Messaging.SingleEmailMessage();
                email.setTemplateId(et.Id);
                email.setToAddresses(new String[] {relatedAccountMap.get(cs.AccountId).OwnerId});
                email.setOrgWideEmailAddressId(orgId);
                email.setTargetObjectId(newContact.Id);
                email.setWhatId(cs.AccountId);
    
                emails.add(email);
            }
        }
    
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);
    
        for(Messaging.SendEmailResult result : results) {
            if(!result.isSuccess) {
                System.debug(result.error);
            }
        }
    }
    */
}