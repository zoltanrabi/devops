@isTest
public with sharing class MyCustomObjectTriggerHandlerTest {
    @IsTest
    static void testSayWhat() {
        // Arrange
        MyCustomObjectTriggerHandler hw = new MyCustomObjectTriggerHandler();
        
        // Act
        String result = hw.sayWhat();
        
        // Assert
        System.assertEquals('Hello, What!', result, 'The sayHello method should return "Hello, World!"');
    }
}