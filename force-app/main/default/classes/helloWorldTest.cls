@isTest
public with sharing class helloWorldTest {
    @IsTest
    static void testSayHello() {
        // Arrange
        helloWorld hw = new helloWorld();
        
        // Act
        String result = hw.sayHello();
        
        // Assert
        System.assertEquals('Hello, World!', result, 'The sayHello method should return "Hello, World!"');
    }
} 