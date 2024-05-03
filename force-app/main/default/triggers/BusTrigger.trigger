trigger BusTrigger on Bus__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
    }
}