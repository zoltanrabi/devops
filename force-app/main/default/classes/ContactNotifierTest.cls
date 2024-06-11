@isTest
public class ContactNotifierTest {
    @isTest
    static void testNotifyContactOwner() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.mydevorg',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a contact owned by the test user
        Contact contact = new Contact(LastName = 'Test Contact', OwnerId = testUser.Id, Email = 'test@contact.com');
        insert contact;

        Test.startTest();
        Integer emailInvocationsBefore = Limits.getEmailInvocations();
        ContactNotifier.notifyContactOwner(contact.Id, 'Test message');
        Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'Email should be sent');
    }
}