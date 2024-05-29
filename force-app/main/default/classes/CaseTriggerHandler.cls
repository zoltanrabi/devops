/**
 * @author: Zoltan Rabi - Accenture
 * @date: 2022.01.07.
 * @description: Handler to the Case trigger
 */

public with sharing class CaseTriggerHandler {


    /**
     * @description: Set description of related account after case is created
     */
    public static void afterInsert(Map<Id, Case> newMap) {
        if(BypassControl.runTrigger(BypassControl.CASETRIGGERLOGIC_SETDESCRIPTIONFORACCOUNT)) {
            CaseTriggerLogic.setDescriptionForAccount(newMap);
        }
    }

    /** 
    public static void afterInsert(Map<Id, Case> newMap) {
        CaseTriggerLogic.sendEmailToAccountWhenCaseCreated(newMap);
    }
    */

}