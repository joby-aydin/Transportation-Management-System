public class ReservationHelper {
    public static void updateReservationTotalPrice(List<Reservation__c> reservations) {
        Map<Id, Bus__c> busMap = new Map<Id, Bus__c>();

        // Collect the Bus__c record IDs from the Reservation__c records
        Set<Id> busIds = new Set<Id>();
        for (Reservation__c res : reservations) {
            busIds.add(res.Bus__c); // Assuming Bus__c is the lookup field on Reservation__c
        }

        // Query the Bus__c records related to the reservations
        for (Bus__c bus : [SELECT Id, Bus_Type__c FROM Bus__c WHERE Id IN :busIds]) {
            busMap.put(bus.Id, bus);
        }

        // Calculate total price for each reservation based on rental duration and bus type
        for (Reservation__c res : reservations) {
            Bus__c bus = busMap.get(res.Bus__c);
            if (bus != null) {
                // Calculate rental duration in days
                Integer rentalDays = res.Pickup_Date_Time__c.date().daysBetween(res.Return_Date_Time__c.date());
                
                // Add your logic here to calculate total price based on rental duration and bus type
                Decimal totalPrice = calculateTotalPrice(rentalDays, bus.Bus_Type__c);

                // Update the Reservation__c record with the calculated total price
                res.Total_Price__c = totalPrice;
            }
        }
    }

    // Example method to calculate total price based on rental duration and bus type
    private static Decimal calculateTotalPrice(Integer rentalDays, String busType) {
        Decimal totalPrice = 0;
        
        // Define pricing based on bus type
        Decimal miniBusPricePerDay = 100; // Example price for Mini Bus per day
        Decimal midiBusPricePerDay = 150; // Example price for Midi Bus per day
        
        // Calculate total price based on rental duration and bus type
        if (busType == 'Mini Bus') {
            totalPrice = rentalDays * miniBusPricePerDay;
        } else if (busType == 'Midi Bus') {
            totalPrice = rentalDays * midiBusPricePerDay;
        } else {
            // Handle other bus types if necessary
        }
        return totalPrice;
    }

    public static void updateBusStatus(List<Reservation__c> reservations) {
        Set<Id> confirmedReservationIds = new Set<Id>();
        
        // Collect confirmed reservation IDs
        for (Reservation__c res : reservations) {
            if (res.Status__c == 'Confirmed') {
                confirmedReservationIds.add(res.Bus__c);
            }
        }

        // Update Bus Status to "Rented" for buses with confirmed reservations
        List<Bus__c> busesToUpdate = [SELECT Id, Current_Status__c FROM Bus__c WHERE Id IN :confirmedReservationIds];
        for (Bus__c bus : busesToUpdate) {
            bus.Current_Status__c = 'Rented';
        }

        update busesToUpdate;
    }
}
