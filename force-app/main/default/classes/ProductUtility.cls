/**
 * QTC CDEMO Template Org Product Utility 
 * @author Matthew Seeger
 *
 * Modified by sean crowe November 21 2017
 *
 */
public class ProductUtility {
    public static void BeforeTriggerProcessor(List<Product2> allProds) {

        Id DefaultBilling = [SELECT Id FROM blng__BillingRule__c WHERE Name = 'Invoice w/ Special Treatment' LIMIT 1].Id;
        Id DefaultRevRec = [SELECT Id FROM blng__RevenueRecognitionRule__c WHERE Name = '100% Ratable (Monthly)' LIMIT 1].Id;
        Id DefaultTax = [SELECT Id FROM blng__TaxRule__c WHERE Name = 'Standard Tax Rule' LIMIT 1].Id;

        for (Product2 thisProd : allProds) {
            if (thisProd.Description == '' || thisProd.Description == null) {
                thisProd.Description = thisProd.Name;
            }

            if (!thisProd.IsActive) {
                thisProd.IsActive = true;
            }
            if (thisProd.SBQQ__ChargeType__c == '' || thisProd.SBQQ__ChargeType__c == null) {
                thisProd.SBQQ__ChargeType__c = 'One-Time';
            }
            if (thisProd.blng__BillingRule__c == null) {
                thisProd.blng__BillingRule__c = DefaultBilling;
            }
            if (thisProd.blng__RevenueRecognitionRule__c == null) {
                thisProd.blng__RevenueRecognitionRule__c = DefaultRevRec;
            }
            if (thisProd.blng__TaxRule__c == null) {
                thisProd.blng__TaxRule__c = DefaultTax;
            }
        }
    }

    /**
     * Process all of the trigger items if After
     * @author Matthew Seeger
     *
     * Modified on October 13 2017 to separate clones vs net new
     */
    public static void AfterTriggerProcessor(List<Product2> allProds, Boolean isInsert) {
        List<Product2> prodsWithoutDescription = new List<Product2>();
        List<Product2> prodsWithPrice = new List<Product2>();
        List<Product2> netNewProducts = new List<Product2>();
        List<Product2> cloneProducts = new List<Product2>();

        for (Product2 thisProd : allProds) {

            if (thisProd.Standard_Pricebook_Price__c != null) {
                prodsWithPrice.add(thisProd);
            }

            if (thisProd.isClone()) {
                cloneProducts.add(thisProd);
            } else {
                netNewProducts.add(thisProd);
            }
        }

        if (prodsWithPrice.size() > 0) {
            ProductUtility.CreatePricebookEntries(prodsWithPrice);
        }

        if (isInsert) {
            if (netNewProducts.size() > 0) {
                ProductUtility.AddApprovalThresholds(netNewProducts);
            }
            if (cloneProducts.size() > 0) {
                ProductUtility.CloneApprovalThresholds(cloneProducts);
            }
        }
    }


    public static void AddApprovalThresholds(List<Product2> prods) {

        Q2C_Demo_Settings__c settings = Q2C_Demo_Settings__c.getOrgDefaults();

        List<Approval_Threshold__c> thresholdsToAdd = new List<Approval_Threshold__c>();

        //Discount
        for (Product2 prod : prods) {
            thresholdsToAdd.add(new Approval_Threshold__c(Product__c = prod.Id, Threshold_Type__c = 'Discount', Approval_Level__c = 0, Lower_Bound_Percent__c = 0.0, Upper_Bound_Percent__c = settings.Default_Approval_Tier_1__c));
            thresholdsToAdd.add(new Approval_Threshold__c(Product__c = prod.Id, Threshold_Type__c = 'Discount', Approval_Level__c = 1, Lower_Bound_Percent__c = settings.Default_Approval_Tier_1__c, Upper_Bound_Percent__c = settings.Default_Approval_Tier_2__c));
            thresholdsToAdd.add(new Approval_Threshold__c(Product__c = prod.Id, Threshold_Type__c = 'Discount', Approval_Level__c = 2, Lower_Bound_Percent__c = settings.Default_Approval_Tier_2__c, Upper_Bound_Percent__c = settings.Default_Approval_Tier_3__c));
            thresholdsToAdd.add(new Approval_Threshold__c(Product__c = prod.Id, Threshold_Type__c = 'Discount', Approval_Level__c = 3, Lower_Bound_Percent__c = settings.Default_Approval_Tier_3__c, Upper_Bound_Percent__c = 999.0));
        }

        Database.insert(thresholdsToAdd);
    }

    /**
     * When a product was inserted through cloning, use the approval thresholds form the cloned product instead
     * Added October 13 2017
     * @author Matthew Seeger
     *
     */
    public static void CloneApprovalThresholds(List<Product2> prods) {
        List<Approval_Threshold__c> thresholdsToAdd = new List<Approval_Threshold__c>();
        Set<Id> cloneIds = new Set<Id>();
        Map<Id, Id> cloneToNewId = new Map<Id, Id>();

        for (Product2 prod : prods) {
            cloneIds.add(prod.getCloneSourceId());
            cloneToNewId.put(prod.getCloneSourceId(), prod.Id);
        }
        List<Approval_Threshold__c> oldThresholds = [SELECT Product__c, Threshold_Type__c, Approval_Level__c, Lower_Bound_Percent__c, Upper_Bound_Percent__c FROM Approval_Threshold__c WHERE Product__c IN :cloneIds];
        for (Approval_Threshold__c at : oldThresholds) {
            Approval_Threshold__c atClone = at.clone(false, false, false, false);
            atClone.Product__c = cloneToNewId.get(at.Product__c);
            thresholdsToAdd.add(atClone);
        }
        Database.insert(thresholdsToAdd);
    }


    public static void CreatePricebookEntries(List<Product2> prods) {
        Map<String, Decimal> conversionRateMap = new Map<String, Decimal>();
        String corporateCurrency = null;
        Decimal currencyCount = 0;
        List<CurrencyType> currencies = [SELECT ConversionRate, DecimalPlaces, IsCorporate, IsoCode FROM CurrencyType WHERE IsActive = TRUE];
        Set<Id> productIdsInThisLoad = new Set<Id>();
        Q2C_Demo_Settings__c settings = Q2C_Demo_Settings__c.getOrgDefaults();
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE];

        for (CurrencyType curr : currencies) {
            if (curr.IsCorporate) {
                corporateCurrency = curr.IsoCode;
            }
            conversionRateMap.put(curr.IsoCode, curr.ConversionRate);
            currencyCount = currencyCount + 1;
        }

        //List<SBQQ__Cost__c> costsToUpsert = new List<SBQQ__Cost__c>();
        List<SBQQ__Cost__c> costsToUpdate = new List<SBQQ__Cost__c>();
        List<SBQQ__Cost__c> costsToInsert = new List<SBQQ__Cost__c>();

        List<PricebookEntry> pbesToUpdate = new List<PricebookEntry>();
        List<PricebookEntry> pbesToInsert = new List<PricebookEntry>();

        for (Product2 prod : prods) {

            productIdsInThisLoad.add(prod.Id);

        }

        List<PricebookEntry> existingPBEs = [SELECT Id, Product2Id, UnitPrice, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN :productIdsInThisLoad];
        Map<String, PricebookEntry> utilityKeyToPbeMap = new Map<String, PricebookEntry>();

        for (PricebookEntry pbe : existingPBEs) {
            utilityKeyToPbeMap.put(pbe.Product2Id + pbe.CurrencyIsoCode, pbe);
        }


        Decimal costFactor = (1 - settings.Default_Approval_Tier_3__c / 100) - (Math.random() * settings.Default_Approval_Tier_1__c) / 100;

        List<SBQQ__Cost__c> existingCosts = [SELECT Id, SBQQ__Product__c, SBQQ__UnitCost__c, CurrencyIsoCode FROM SBQQ__Cost__c WHERE SBQQ__Product__c IN :productIdsInThisLoad];
        Map<String, SBQQ__Cost__c> utilityKeyToCostMap = new Map<String, SBQQ__Cost__c>();
        for (SBQQ__Cost__c cost : existingCosts) {
            utilityKeyToCostMap.put(cost.SBQQ__Product__c + cost.CurrencyIsoCode, cost);
        }
        List<SBQQ__Cost__c> costsToClone = new List<SBQQ__Cost__c>();

        List<SBQQ__Cost__c> costsCloned = new List<SBQQ__Cost__c>();

        for (Product2 prod : prods) {

            /**  if(costsToUpsert.size() + currencyCount >= 200){
                  database.upsert(costsToUpsert, SBQQ__Cost__c.Product_Utility_Key__c, TRUE);
                  costsToUpsert = new List<SBQQ__Cost__c>();
              }**/
            if (costsToInsert.size() + currencyCount >= 200) {
                Database.insert(costsToInsert);
                costsToInsert = new List<SBQQ__Cost__c>();
            }
            if (costsToUpdate.size() + currencyCount >= 200) {
                Database.update(costsToUpdate);
                costsToUpdate = new List<SBQQ__Cost__c>();
            }

            if (pbesToInsert.size() + currencyCount >= 200) {
                Database.insert(pbesToInsert);
                pbesToInsert = new List<PricebookEntry>();
            }
            if (pbesToUpdate.size() + currencyCount >= 200) {
                Database.update(pbesToUpdate);
                pbesToUpdate = new List<PricebookEntry>();
            }


            Decimal corporateCurrencyPrice = prod.Standard_Pricebook_Price__c / conversionRateMap.get(prod.CurrencyIsoCode);
            Decimal corporateCurrencyCost = corporateCurrencyPrice * costFactor;

            for (String currencyCode : conversionRateMap.keySet()) {
                Decimal thisPrice = corporateCurrencyPrice * conversionRateMap.get(currencyCode);
                Decimal thisCost = corporateCurrencyCost * conversionRateMap.get(currencyCode);

                //costsToUpsert.add(new SBQQ__Cost__c(CurrencyIsoCode=currencyCode, SBQQ__Active__c=true, SBQQ__Product__c=prod.Id, SBQQ__UnitCost__c=thisCost, Product_Utility_Key__c = prod.Id + currencyCode));

                if (!prod.isClone()) {
                    if (utilityKeyToCostMap.containsKey(prod.Id + currencyCode)) {
                        costsToUpdate.add(new SBQQ__Cost__c(Id = utilityKeyToCostMap.get(prod.Id + currencyCode).Id, SBQQ__UnitCost__c = thisPrice * costFactor, SBQQ__Active__c = true));
                    } else {
                        costsToInsert.add(new SBQQ__Cost__c(SBQQ__Product__c = prod.Id, SBQQ__UnitCost__c = thisCost, CurrencyIsoCode = currencyCode, SBQQ__Active__c = true));
                    }
                }
                if (prod.isClone()) {

                    // costsToInsert.add(new SBQQ__Cost__c(SBQQ__Product__c = prod.Id, SBQQ__UnitCost__c=thisCost, CurrencyIsoCode=currencyCode, SBQQ__Active__c=true));
                    //costsToClone= [Select SBQQ__UnitCost__c from SBQQ__Cost__c where SBQQ__Product__c=:prod.getCloneSourceId()];
                    /** costsToClone= [Select SBQQ__UnitCost__c, SBQQ__Product__c, SBQQ__Active__c from SBQQ__Cost__c where SBQQ__Product__c=:prod.getCloneSourceId()];
                    for(integer i =0; i<costsToClone.size();i++){
                        SBQQ__Cost__c Cost = costsToClone.get(i).clone(false,true);
                        //SBQQ__Cost__c Cost= new SBQQ__Cost__c();
                        Cost.SBQQ__Product__c= prod.Id;

                        costsCloned.add(Cost);


                    }**/


                }
                if (!prod.isClone()) {
                    if (utilityKeyToPbeMap.containsKey(prod.Id + currencyCode)) {
                        pbesToUpdate.add(new PricebookEntry(Id = utilityKeyToPbeMap.get(prod.Id + currencyCode).Id, Pricebook2Id = standardPB.Id, UnitPrice = thisPrice, IsActive = true));
                    } else {
                        pbesToInsert.add(new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = standardPB.Id, UnitPrice = thisPrice, CurrencyIsoCode = currencyCode, IsActive = true));
                    }
                }
            }


        }
        Database.insert(costsCloned);
        Database.insert(costsToInsert);
        Database.update(costsToUpdate);
        Database.insert(pbesToInsert);
        Database.update(pbesToUpdate);
    }
}