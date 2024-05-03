import { LightningElement, wire, track } from 'lwc';
import getReservations from '@salesforce/apex/ReservationController.getReservations';
import createReservation from '@salesforce/apex/ReservationController.createReservation';

export default class Reservation extends LightningElement {
    @track reservations;
    @track showCreateForm = false;
    @track newReservationName = '';
    @track newReservationBus = '';
    @track newReservationPickupDate = '';
    @track newReservationReturnDate = '';

    @track columns = [
        {
            label: 'Bus Name',
            fieldName: 'busLink',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name' // replace with your actual field name
                },
                target: '_blank'
            },
            sortable: true
        },
        {
            label: 'Current Status',
            fieldName: 'Current_Status__c', // replace with your actual field name
            type: 'text',
            sortable: true
        },
        {
            label: 'Year',
            fieldName: 'Year__c', // replace with your actual field name
            type: 'text',
            sortable: true,
        },
        {
            label: 'Odometer',
            fieldName: 'Odometer_Reading__c', // replace with your actual field name
            type: 'number',
            sortable: true
        }
    ];

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        console.log('Row action clicked', row.Id);
        // Add logic here for what happens when you click on the link
    }
    
    // Fetch reservations from the server
    @wire(getReservations)
    wiredReservationsResult({ error, data }) {
        if (data) {
            // Process and map data if needed
            this.reservations = data.map(reservation => {
                // Process each reservation record as needed
                // For example, construct the busLink URL
                return {
                    ...reservation,
                    busLink: `/${reservation.Bus__c}`,
                    Current_Status__c: reservation.Bus__r.Current_Status__c, // Current status of the Bus
                    Year__c: reservation.Bus__r.Year__c.toString(), // Year of the Bus
                    Odometer_Reading__c: reservation.Bus__r.Odometer_Reading__c // Odometer reading of the Bus
                };
            });
        } else if (error) {
            // Handle error, for example, log to console or display a message to the user
            console.error('Error fetching reservations:', error);
        }
    }
    
    createNewReservation() {
        // Use the imported `createReservation` method from Apex
        createReservation({
            name: this.newReservationName,
            busId: this.newReservationBus,
            pickupDateTime: this.newReservationPickupDate,
            returnDateTime: this.newReservationReturnDate
        })
        .then(() => {
            // If reservation is created successfully, show a success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Reservation created successfully',
                    variant: 'success'
                })
            );
            // Call refreshApex to refresh the data
            return refreshApex(this.wiredReservationsResult);
        })
        .catch(error => {
            // Handle the error if the reservation creation failed
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating reservation',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}
