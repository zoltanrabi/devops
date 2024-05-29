public with sharing class BypassControl {
   
    public static final String ACCOUNTTRIGGER_ALL = 'AccountTrigger.all';
    public static final String ACCOUNTTRIGGERLOGIC_THROWNEWERROR = 'AccountTriggerLogic.throwNewError';
    public static final String  ACCOUNTTRIGGERLOGIC_CREATECASESAFTERDESCRIPTIONCHANGE = 'AccountTriggerLogic.createCasesAfterDescriptionChange';

    public static final String CASETRIGGER_ALL = 'CaseTrigger.all';
    public static final String CASETRIGGERLOGIC_SETDESCRIPTIONFORACCOUNT = 'CaseTriggerLogic.setDescriptionForAccount';

    private static Set<String> bypassMe = new Set<String>();
    
    /**
     * @description: Checking whether the logic should run in the current transaction
     */
    public static boolean runTrigger(String methodName){
        return !bypassMe.contains(methodName);
    }
    
    /**
     * @description: Adding a method to the bypass list
     */
    public static void addBypass(String methodName){
        bypassMe.add(methodName);
    }
    
    /**
     * @description: Removing a method from the bypass list
     */
    public static void removeBypass(String methodName){
        bypassMe.remove(methodName);
    }
}