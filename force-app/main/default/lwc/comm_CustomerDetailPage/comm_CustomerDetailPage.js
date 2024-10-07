import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/Comm_CustomerDetailPage.getDetails'
import updateAccountDetails from '@salesforce/apex/Comm_CustomerDetailPage.updateAccountDetails';

export default class Comm_CustomerDetailPage extends LightningElement {
    //ui controll variables
    @track dataLoaded = false;
    @track recordFound = true;
    @track errorMessage = '';
    @track messageClass = '';

    //input variables
    @track recordId;
    @track name;
    @track phone = '';
    @track dob = '';
    @track tshirtSize = '';
    @track shoeSize = '';

    // Load the current customer record fields
    connectedCallback() {
        const queryParams = new URLSearchParams(window.location.search);

        // Fetch the recordId and name from the URL
        this.recordId = queryParams.get('recordId');
        var lastName = queryParams.get('name');

        if (this.recordId && lastName) {
            getDetails({ recordId: this.recordId, LastName: lastName })
                .then(result => {
                    if (result) {
                        console.log('result--->' + result);
                        result = JSON.parse(result);
                        if (result.Profile_Completed__c) {
                            this.errorMessage = 'Information Already updated !!!';
                            this.messageClass = 'sucess-message';
                            this.recordFound = false;
                        }
                        else {
                            this.name = result.Name;
                            this.phone = result.Phone;
                            this.tshirtSize = result.T_shirt_size__c;
                            this.shoeSize = result.Shoe_Size__c;
                            this.dob = result.Date_Of_Birth__c;
                            this.recordFound = true;
                        }
                    } else {
                        console.log('record not found')
                        this.errorMessage = 'Account Not Found Please Contact Support !!!';
                        this.messageClass = 'error-message';
                        this.recordFound = false;
                    }
                    this.dataLoaded = true;
                })
                .catch(error => {
                    this.dataLoaded = true;
                    this.errorMessage = 'Account Not Found Please Contact Support !!!';
                    this.messageClass = 'error-message';
                    this.recordFound = false;
                    console.log('error----->' + error);
                })
        } else {
            console.log('error----->');
        }
    }
    // Handle input changes
    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'phone') {
            this.phone = event.target.value;
        } else if (field === 'dob') {
            this.dob = event.target.value;
        } else if (field === 'tshirtSize') {
            this.tshirtSize = event.target.value;
        } else if (field === 'shoeSize') {
            this.shoeSize = event.target.value;
        }
    }
    // Update the record
    handleSave() {
        // Get all required lightning-input elements
        const requiredInputs = this.template.querySelectorAll('.required1');

        let allValid = true;
        requiredInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });
        if (allValid) {
            updateAccountDetails({ recordId: this.recordId,phone:this.phone, tshirtSize: this.tshirtSize, shoeSize: this.shoeSize, dob: this.dob })
                .then(result => {
                    console.log('result--->' + result)
                    if (result.includes('successfully')) {
                        this.showToast('Success', 'Profile Updated Successfully', 'success');
                        this.messageClass = 'sucess-message';
                        this.errorMessage = 'Information stored successfully';
                        this.recordFound = false;
                    } else {
                        this.showToast('Error updating record', result, 'error');
                    }
                })
                .catch(error => {
                    this.showToast('Error updating record', error.body.message, 'error');
                });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            }),
        );
    }

    get tshirtSizeOptions() {
        return [
            { label: 'XS', value: 'XS' },
            { label: 'S', value: 'S' },
            { label: 'M', value: 'M' },
            { label: 'L', value: 'L' },
            { label: 'XL', value: 'XL' },
            { label: 'XXL', value: 'XXL' },
        ];
    }

    get shoeSizeOptions() {
        const sizes = [];
        for (let size = 6; size <= 16; size += 0.5) {
            sizes.push({ label: size.toString(), value: size.toString() });
        }
        return sizes;
    }
}