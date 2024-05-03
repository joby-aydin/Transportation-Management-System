public with sharing class FleetManagementController {

    @AuraEnabled(cacheable = true)
    public static List < Bus__c > getBusList() {
        return [SELECT Id, Name, ImageUrl__c, Year__c, Maximum_Capacity__c, Odometer_Reading__c, Air_Conditioning__c, Current_Status__c
                FROM Bus__c WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static void updateBus(String busId, Map<String, Object> busData) {
        // Convert the received data to a Bus__c sObject
        Bus__c busToUpdate = new Bus__c(Id = busId);
        busToUpdate.Name = (String)busData.get('Name');
        busToUpdate.Odometer_Reading__c = (Decimal)busData.get('Odometer_Reading__c');
    
        // Perform the update
        try {
            update busToUpdate;
            System.debug('new value of Odometer + '+ busToUpdate.Odometer_Reading__c);
        } catch (DmlException e) {
            // Propagate the exception to the client
            throw new AuraHandledException('Cannot update bus: ' + e.getMessage());
        }
    }
}