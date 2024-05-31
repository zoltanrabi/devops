@isTest
public with sharing class testClassTest {
    @isTest
    static void testSayHello() {
        String greeting = testClass.sayHello();
        System.assertEquals('Hello, World!', greeting, 'Unexpected greeting');
    }
}