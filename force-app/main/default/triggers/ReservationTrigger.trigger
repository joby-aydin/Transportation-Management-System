trigger ReservationTrigger on Reservation__c (before insert, before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ReservationHelper.updateReservationTotalPrice(Trigger.new);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate || Trigger.isInsert) {
            ReservationHelper.updateBusStatus(Trigger.new);
        }
    }
}