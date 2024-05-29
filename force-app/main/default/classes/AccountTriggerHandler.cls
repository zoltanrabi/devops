/**
 * @author: Zoltan Rabi - Accenture
 * @date: 2022.01.06.
 * @description: Handler to the Account trigger
 */

public with sharing class AccountTriggerHandler {
    /**
    * @description: Handling the before insert cases on Account trigger. 
    * Create 5 new Cases if the Account description is updated
    */
    public static void afterUpdate(Map<Id, Account> newMap) {
        
        if(BypassControl.runTrigger(BypassControl.ACCOUNTTRIGGERLOGIC_CREATECASESAFTERDESCRIPTIONCHANGE)) {
            AccountTriggerLogic.createCasesAfterDescriptionChange(newMap);
        }
    }



    /**
     * @description: Handling the before insert cases on Account trigger

    public static void beforeInsert(List<Account> newList) {
        AccountTriggerLogic.setDescription(newList);
    }
     */
    
    /**
     * @description: Handling the before insert cases on Account trigger
    public static void beforeInsert(List<Account> newList) {
        if(BypassControl.runTrigger(BypassControl.ACCOUNTTRIGGERLOGIC_THROWNEWERROR)) {
            AccountTriggerLogic.throwNewError(newList);
        }
    }
    */
    
    /**
     * @description: Handling the before insert cases on Account trigger
    
    public static void afterInsert(Map<Id, Account> newMap) {
        AccountTriggerLogic.sendPushNotification(newMap);
    }
    */
}