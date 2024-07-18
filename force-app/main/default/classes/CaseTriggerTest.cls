@isTest
public with sharing class CaseTriggerTest {
    @IsTest
    static void testSayHi() {
        // Arrange
        CaseTrigger hw = new CaseTrigger();
        
        // Act
        String result = hw.sayHi();
        
        // Assert
        System.assertEquals('Hello, Hi!', result, 'The sayHello method should return "Hello, World!"');
    }
}