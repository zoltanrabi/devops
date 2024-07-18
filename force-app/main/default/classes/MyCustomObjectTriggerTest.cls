@isTest
public with sharing class MyCustomObjectTriggerTest {
    @IsTest
    static void testSayBro() {
        // Arrange
        MyCustomObjectTrigger hw = new MyCustomObjectTrigger();
        
        // Act
        String result = hw.sayBro();
        
        // Assert
        System.assertEquals('Hello, Bro!', result, 'The sayHello method should return "Hello, World!"');
    }
}