public class AccountManager {
    public static void createAccount(String accountName) {
        Account acc = new Account(Name = accountName);
        insert acc;
    }

    public static void updateAccountName(Id accountId, String newName) {
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        acc.Name = newName;
        update acc;
    }

    public static void deleteAccount(Id accountId) {
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        delete acc;
    }
} 