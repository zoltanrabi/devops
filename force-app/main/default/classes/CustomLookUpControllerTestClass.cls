@isTest
private class CustomLookUpControllerTestClass {

    testMethod static void testProductSearch(){
        List < sObject > returnList = new List < sObject > ();
        returnList = CustomLookUpController.fetchLookUpValues('anomaly', 'product2');
        Integer size = returnList.size(); 
        System.assertEquals(0,size);
    }
}