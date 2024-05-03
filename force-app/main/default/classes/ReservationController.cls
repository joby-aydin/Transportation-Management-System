public with sharing class ReservationController {
    // This method fetches a list of reservation records and their related bus fields
    @AuraEnabled(cacheable=true)
    public static List<Reservation__c> getReservations() {
        // It's important to note that we are querying fields from the related Bus__c object
        // by using the relationship name 'Bus__r'
        return [
            SELECT 
                Id, 
                Name, // Reservation name
                Bus__c, // ID of the related bus
                Bus__r.Name, // Name of the related bus
                Bus__r.Current_Status__c, // Current status of the related bus
                Bus__r.Year__c, // Year of the related bus
                Bus__r.Odometer_Reading__c, // Odometer reading of the related bus
                Pickup_Date_Time__c, // Pickup date and time for the reservation
                Return_Date_Time__c, // Return date and time for the reservation
                Total_Price__c  // Total price for the reservation
            FROM
                Reservation__c
        ];
    }

    // This method creates a new reservation record
    @AuraEnabled
    public static void createReservation(
        String name, 
        String busId, // Changed parameter name to busId for clarity
        DateTime pickupDateTime, // Changed type to DateTime to include time
        DateTime returnDateTime // Changed type to DateTime to include time
    ) {
        // Create a new instance of Reservation__c
        Reservation__c newReservation = new Reservation__c(
            Name = name,
            Bus__c = busId, // Use the bus ID to relate the reservation to a bus
            Pickup_Date_Time__c = pickupDateTime,
            Return_Date_Time__c = returnDateTime
            // Add more fields as needed
        );
        // Insert the new reservation record into the database
        insert newReservation;
    }
}
