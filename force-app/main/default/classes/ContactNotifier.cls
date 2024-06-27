public class ContactNotifier {
    public static void notifyContactOwner(Id contactId, String message) {
        Contact contact = [SELECT Id, OwnerId, Email FROM Contact WHERE Id = :contactId];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(contact.OwnerId);
        email.setSubject('Notification');
        email.setPlainTextBody(message);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}  