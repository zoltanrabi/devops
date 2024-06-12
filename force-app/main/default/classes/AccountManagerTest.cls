@isTest
public class AccountManagerTest {
    @isTest
    static void testCreateAccount() {
        Test.startTest();
        AccountManager.createAccount('Test Account');
        Test.stopTest();

        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.assertNotEquals(null, acc, 'Account should be created');
    }

    @isTest
    static void testUpdateAccountName() {
        Account acc = new Account(Name = 'Initial Name');
        insert acc;

        Test.startTest();
        AccountManager.updateAccountName(acc.Id, 'Updated Name');
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Updated Name', updatedAcc.Name, 'Account name should be updated');
    }

    @isTest
    static void testDeleteAccount() {
        Account acc = new Account(Name = 'Delete Me');
        insert acc;

        Test.startTest();
        AccountManager.deleteAccount(acc.Id);
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, count, 'Account should be deleted');
    }
}  