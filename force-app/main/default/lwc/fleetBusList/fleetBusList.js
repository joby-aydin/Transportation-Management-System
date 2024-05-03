import {LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateBus from '@salesforce/apex/FleetManagementController.updateBus';
import getBusList from '@salesforce/apex/FleetManagementController.getBusList';
import {NavigationMixin} from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const FIELDS = ['Id','Name', 'Year__c', 'Maximum_Capacity__c', 'Odometer_Reading__c'];

export default class FleetBusList extends NavigationMixin(LightningElement) {
    @track busList;
    @track selectedBus;
    @track resaleValue;
    @track editMode = false;
    @track forceUpdate = 0;
    @track wiredBusResult;
    refreshNeeded = false;

    @api
    refreshBusList() {
        return refreshApex(this.wiredBusResult);
    }

    renderedCallback() {
        if (this.refreshNeeded ==true) {
            refreshApex(this.wiredBusResult);
            this.refreshNeeded = false; // Reset the flag to prevent multiple refreshes
        }
    }

    // Fetch the list of buses
    @wire(getBusList)
    wiredBusList(result) {
        this.wiredBusResult = result;  
        if (result.data) {
            this.busList = result.data;
        } else if (result.error) {
            this.handleError(result.error);
        }
    }

    // Handle click on a bus card
    handleBusClick(event) {
        const busId = event.currentTarget.dataset.busid;
        this.selectedBus = {...this.busList.find(bus => bus.Id === busId)};
        console.log('Selected Bus: ', JSON.stringify(this.selectedBus));
        this.editMode = false;
        this.calculateResaleValue();
    }

    // Handle edit button click
    handleEditClick() {
        this.editMode = !this.editMode;
    }

    handleBusInputChange(event) {
        const fieldName = event.target.name;
        const value = fieldName === 'Odometer_Reading__c' || fieldName === 'Year__c' 
                        ? parseInt(event.target.value, 10) 
                        : event.target.value;
    
        this.selectedBus = {
            ...this.selectedBus,
            [fieldName]: value
        };
    
        // Recalculate the resale value only for fields that affect it
        if (['Odometer_Reading__c', 'Maximum_Capacity__c', 'Year__c', 'Air_Conditioning__c', 'Current_Status__c'].includes(fieldName)) {
            this.calculateResaleValue();
        }
    }

    handleSaveClick() {
        const fields = {};
        FIELDS.forEach((field) => {
            fields[field] = this.selectedBus[field];
        });
    
        updateBus({ busId: this.selectedBus.Id, busData: this.selectedBus })
            .then(() => {
                this.editMode = false;
    
                // Refresh the bus list using refreshApex
                return refreshApex(this.wiredBusResult);
            })
            .then(() => {
                // Create a copy of the busList for modification
                let updatedBusList = [...this.busList];
    
                // Find the index of the bus in the copied list
                const index = updatedBusList.findIndex(bus => bus.Id === this.selectedBus.Id);
                if (index !== -1) {
                    updatedBusList[index] = {...this.selectedBus};  // Update the specific bus in the copied list
                    this.busList = updatedBusList;  // Assign the updated copy back to busList
                }
    
                // Refresh the selectedBus with updated data
                this.selectedBus = {...updatedBusList.find(bus => bus.Id === this.selectedBus.Id)};
    
                // Recalculate the resale value locally
                this.calculateResaleValue();
            })
            .catch((error) => {
                this.handleError(error);
            });
    }
    
    // Handle cancel button click
    handleCancelClick() {
        this.editMode = false;
        this.selectedBus = null;
    }

    // Handle name click on non edit mode
    handleNameClick(event) {
        const recordId = this.selectedBus.Id; 
        console.log('record id is: ' + recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                actionName: "view",
                recordId: recordId
            }
        }, {
            target: '_blank'
        });
    }

    handleError(error) {
        console.error('An error occurred:', error);
        // Show a toast message for better user feedback
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error updating bus',
                message: error.body ? error.body.message : error.message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    get computedBusList() {
        this.forceUpdate;
        return this.busList;
    }

    get availableForRent() {
        return this.selectedBus && this.selectedBus.Current_Status__c === 'Ready for use';
    }

    calculateResaleValue() {
        if (this.selectedBus.Current_Status__c !== 'Ready for use') {
            console.log('current status: ',this.selectedBus.Current_Status__c );
            this.resaleValue = 'Not ready for resale';
            return;
        }
    
        let startingPrice = 0;
        if (this.selectedBus.Maximum_Capacity__c === 24) {
            startingPrice = 120000;
        } else if (this.selectedBus.Maximum_Capacity__c === 36) {
            startingPrice = 160000;
        } else {
            this.resaleValue = 'Unknown capacity!';
            return;
        }
    
        let mileageReduction = Math.max(this.selectedBus.Odometer_Reading__c - 100000, 0) * 0.10;
        let resaleValue = startingPrice - mileageReduction;
    
        if (this.selectedBus.Air_Conditioning__c) {
            resaleValue += startingPrice * 0.03;
        }
    
        if (this.selectedBus.Year__c <= 1972) {
            resaleValue += startingPrice * 0.34;
        }
    
        this.resaleValue = `$ ${new Intl.NumberFormat('en-US').format(resaleValue)}`;
    }

    handleCreateReservationClick() {
        const defaultValues = encodeDefaultFieldValues({
            Bus__c: this.selectedBus.Id,
        });
    
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Reservation__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
}