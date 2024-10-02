// tsaarnio 4-17-2020
// billing automation trigger v2.0 will set fields: legal entity(from account), finance book for accounting(from account), billing/tax treatments, billing/tax gl rules, and billing/tax gl treatments

trigger Billing_Automation_v2_0 on OrderItem (after insert) {
    boolean debug = false;
    List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
    List<OrderItem> itemsWithCurrentDetails = [select id, OrderId, blng__BillingRule__c, blng__TaxRule__c from OrderItem where Id IN :Trigger.newMap.keySet()];
    if(debug){ system.debug('***** Billing Automation Debug ***** Current Items::: ' + itemsWithCurrentDetails.size() + ' ' + itemsWithCurrentDetails); }
    
    // get Account Id
    Id orderId = itemsWithCurrentDetails[0].OrderId;
    if(debug){ system.debug('***** Billing Automation Debug ***** Order Id ::: ' + orderId); }
    List<Order> orderAccIDs = [SELECT AccountId From Order Where Id =: orderId];
    if(debug){ system.debug('***** Billing Automation Debug ***** Account ID List ID::: ' + orderAccIDs[0].AccountId); }
    Id defaultAcc;
        if(orderAccIDs[0].AccountId != NULL){
            defaultAcc = orderAccIDs[0].AccountId;
        }
    if(debug){ system.debug('***** Billing Automation Debug ***** Account ID::: ' + defaultAcc); }
    
    // get Legal Entity
    // get backup legal entity that's active from database
    Id defaultEntity;
    List<blng__LegalEntity__c> LEList = [SELECT Id From blng__LegalEntity__c Where blng__Active__c = true];    
        if(LEList[0].Id != NULL){
            defaultEntity = LEList[0].Id;
        }
    // get legal entity from the order's account
    List<Account> accLE = [SELECT Legal_Entity__c From Account Where Id =: defaultAcc];
        if(accLE[0].Legal_Entity__c != NULL){
            defaultEntity = accLE[0].Legal_Entity__c;
        }
    if(debug){ system.debug('***** Billing Automation Debug ***** Legal Entity::: ' + defaultEntity); }
    
    // get Accounting Finance Book
    // get backup accounting finance book that's active from database
    Id defaultFBook; 
    List<blng__FinanceBook__c> finBooks = [SELECT Id,Name From blng__FinanceBook__c Where blng__PeriodType__c = 'Accounting' AND Default__c = True];
        if(finBooks[0].Id != NULL){
            defaultFBook = finBooks[0].Id;
        }
   // get accounting finance book from the order's account
    List<Account> accFB = [SELECT Accounting_Finance_Book__c From Account Where Id =: defaultAcc];
        if(accFB[0].Accounting_Finance_Book__c != NULL){
            defaultFBook = accFB[0].Accounting_Finance_Book__c;
        }   
    if(debug){ system.debug('***** Billing Automation Debug ***** Default Finance Book::: ' + defaultFBook);}

    // Define ID Sets to hold billing rule and tax rule IDs
    Set<Id> bRuleIds = new Set<Id>(), 
        tRuleIds = new Set<Id>();
    for(OrderItem itemRecord: Trigger.new) {
        bRuleIds.add(itemRecord.blng__BillingRule__c);
        tRuleIds.add(itemRecord.blng__TaxRule__c);
    }
    
    // grab billing treatment details and build a map
    List<blng__BillingTreatment__c> bTreats = [SELECT Id, blng__BillingGLRule__c, blng__BillingRule__c From blng__BillingTreatment__c];
       Map<ID, blng__BillingTreatment__c> bMap = new Map<ID, blng__BillingTreatment__c>();
       for(blng__BillingTreatment__c btreater: bTreats){
        bMap.put(bTreater.blng__BillingRule__c, bTreater);
    }
    
    // grab tax treatment details and build a map
    List<blng__TaxTreatment__c> tTreats = [SELECT Id, blng__TaxGLRule__c, blng__TaxRule__c From blng__TaxTreatment__c Where blng__TaxLegalEntity__c =: defaultEntity AND blng__TaxRule__c IN : tRuleIds];
    Map<ID, blng__TaxTreatment__c> tMap = new Map<ID, blng__TaxTreatment__c>();
    for(blng__TaxTreatment__c tTreater: tTreats){
        tMap.put(tTreater.blng__TaxRule__c, tTreater);
    }

    // grab GL treatment details and build a map
    List<blng__GLTreatment__c> bGLTreat = [SELECT Id, blng__GLRule__c FROM blng__GLTreatment__c WHERE blng__GLLegalEntity__c =: defaultEntity];
    Map<Id,Id > bGLMap = new Map<ID, Id>();
    for(blng__GLTreatment__c bgl: bGLTreat){
        bGLMap.put(bgl.blng__GLRule__c, bgl.Id);
    }

    // loop through items and update fields
    for(OrderItem ori: itemsWithCurrentDetails){                
        /* set Account */
        ori.blng__BillingAccount__c = defaultAcc;
       
        /* set Legal Entity */
        ori.blng__LegalEntity__c = defaultEntity;

        /* set Finance Book */
        ori.blng__FinanceBookAccounting__c = defaultFBook;
        
        /* grab billing treatment */
        blng__BillingTreatment__c billTreat = bMap.get(ori.blng__BillingRule__c);
        
        // set Billing Treatment
        ori.blng__BillingTreatment__c = billTreat.Id;
        if(debug){ system.debug('***** Billing Automation Debug ***** Billing Treatment ID::: ' + billTreat.Id);}
        
        // set Billing GL Rule
        ori.blng__BillingGLRule__c = billTreat.blng__BillingGLRule__c;            
        if(debug){ system.debug('***** Billing Automation Debug ***** Billing GL Rule ID::: ' + billTreat.blng__BillingGLRule__c);}
        
        // set Billing GL Treatment
        ori.blng__BillingGLTreatment__c = bGLMap.get(ori.blng__BillingGLRule__c);
        if(debug){ system.debug('***** Billing Automation Debug ***** Billing GL Treatment ID::: ' + bGLMap.get(ori.blng__BillingGLRule__c));}
        
        
        /* grab tax treatment */        
        blng__TaxTreatment__c taxTreat = tMap.get(ori.blng__TaxRule__c);
        
        // set Tax Treatment
        ori.blng__TaxTreatment__c = taxTreat.Id;
        if(debug){ system.debug('***** Billing Automation Debug ***** Tax Treatment ID::: ' + taxTreat.Id);}
        
        // set Tax GL Rule
        ori.blng__TaxGLRule__c = taxTreat.blng__TaxGLRule__c;            
        if(debug){ system.debug('***** Billing Automation Debug ***** Tax GL Rule ID::: ' + taxTreat.blng__TaxGLRule__c);}
        
        // set Tax GL Treatment
        ori.blng__TaxGLTreatment__c = bGLMap.get(ori.blng__TaxGLRule__c);
        if(debug){ system.debug('***** Billing Automation Debug ***** Tax GL Treatment ID::: ' + bGLMap.get(ori.blng__TaxGLRule__c));} 
                
        // Add updated item to list to update      
        orderItemsToUpdate.add(ori);                
    }

    // Update the list if changes were made
    if(orderItemsToUpdate.size() > 0){
        update orderItemsToUpdate;
    }
}