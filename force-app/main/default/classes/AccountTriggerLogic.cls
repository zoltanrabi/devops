/**
 * @author: Zoltan Rabi - Accenture
 * @date: 2022.01.06.
 * @description: Handler to the Account trigger
 */

public with sharing class AccountTriggerLogic {

    public class MyException extends Exception {}

    /**
     * @description: Throwing an Error
     */
    public static void throwNewError(List<Account> newList) {
        throw new MyException('Ooops');
    }

    /**
     * @description: Create 5 new Cases if the Account description is updated
     */
    public static void createCasesAfterDescriptionChange(Map<Id, Account> newMap) {
        List<Case> newCases = new List<Case>(); 
        for (Account acc : newMap.values()) {
            newCases.add(new Case(AccountId = acc.Id, Subject = 'integration', Description = '1.'));
            newCases.add(new Case(AccountId = acc.Id, Subject = 'internal', Description = '2.'));
            newCases.add(new Case(AccountId = acc.Id, Subject = 'karate', Description = '3.'));
            newCases.add(new Case(AccountId = acc.Id, Subject = 'wrong', Description = '4.'));
            newCases.add(new Case(AccountId = acc.Id, Subject = 'quote', Description = '5.'));
        }
    
        try {
            Database.insert(newCases);
        } catch (Exception e) {
            System.debug('uwu');
            System.debug(e.getMessage());
        }
    }

    /**
     * @description: Set automatic description
    
    public static void setDescription(List<Account> newList) {
        for (Account acc : newList) {
            acc.Description = acc.Name + ' is very good';
        }
    }
     */

    /**
     * @description: Send push notification to current user if Account name is Bela
    public static void sendPushNotification(Map<Id, Account> newMap) {
        Id currentUser = System.UserInfo.getUserId();
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Notify_About_Bela'
        ];

        List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();

        for(Account acc : newMap.values()) {
            if('Bela'.equals(acc.Name)) {
                notificationList.add(createNotification(acc.Name, notificationType));

            }
        }

        try {
            for(Messaging.CustomNotification notif : notificationList) {
                notif.send(new Set<String>{currentUser});
            }
        } 
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    private static Messaging.CustomNotification createNotification(String accountName, CustomNotificationType notificationType) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('New Account');
        notification.setBody('name is: ' + accountName);
        notification.setNotificationTypeId(notificationType.id);
        notification.setTargetId('000000000000000AAA');

        return notification;
    }
     */
}