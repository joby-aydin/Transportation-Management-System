public class BusHelper {
    public static void updateBusAvailability(List<Bus__c> buses) {
        // Query active reservations for the buses being updated
        Map<Id, List<Reservation__c>> busReservationsMap = new Map<Id, List<Reservation__c>>();
        for (Bus__c bus : buses) {
            busReservationsMap.put(bus.Id, new List<Reservation__c>());
        }
        
        for (Reservation__c reservation : [SELECT Id, Bus__c
                                            FROM Reservation__c
                                            WHERE Bus__c IN :busReservationsMap.keySet()
                                                AND (Status__c = 'Confirmed' OR Status__c = 'In Progress')
                                                AND Pickup_Date_Time__c <= :System.now()
                                                AND Return_Date_Time__c >= :System.now()]) {
            busReservationsMap.get(reservation.Bus__c).add(reservation);
        }
        
        update buses;
    }
}
