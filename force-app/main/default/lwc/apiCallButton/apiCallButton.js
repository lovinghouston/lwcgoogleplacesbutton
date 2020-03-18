import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import searchPlace from '@salesforce/apex/GooglePlaces.searchPlace';
import BillingPostalCode from '@salesforce/schema/Account.BillingPostalCode';
import BillingLongitude from '@salesforce/schema/Account.BillingLongitude';
import BillingLatitude from '@salesforce/schema/Account.BillingLatitude';
import { NavigationMixin } from 'lightning/navigation';


const FIELDS = [
    'Account.BillingPostalCode',
    'Account.BillingLatitude',
    'Account.BillingLongitude',
];

const columns = [
    {label: 'CSP Link', fieldName: 'Id', type: 'url'},
    {label: 'School', fieldName: 'School_Name__c'},
    {label: 'Church', fieldName: 'Church_Name__c'},
    {label: 'Status', fieldName: 'Status__c'},
    {label: 'Name', fieldName: 'Name'}
];

export default class ApiCallButton extends NavigationMixin(LightningElement) {

    @track showCSPs = false;
    @track noCSPs = false;
    @api recordId;
    @track csps;
    @track columns = columns;
    @track loading = false;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    account;

    /*
    postalCode = getFieldValue(this.account., BillingPostalCode);
    billingLatitude = getFieldValue(this.account.fields, BillingLatitude);
    billingLongitude = getFieldValue(this.account.fields, BillingLongitude);
    */

    handleFindChurchesClick() {
        this.loading = true;
        searchPlace({
            account: this.recordId,
            longitude: this.account.data.fields.BillingLongitude.value,
            latitude: this.account.data.fields.BillingLatitude.value,
            radius: 5,
            type: 'church',
            key: 'AIzaSyBJYW5TNtGJ10l9CxUoy0RHJSb6zlbilPk'
        }).then(result => {
            console.log('Result: ' + result);
            if (result.length === 0) {
                this.noCSPs = true;
                this.showCSPs = false;
            } else {
                this.noCSPs = false;
                this.csps = result;
                console.log('CSPs: ' + this.csps);
                this.generateURLs(this.csps);
                this.showCSPs = true;
            }
            this.loading = false;
        })
        .catch(error => {
            console.log('Error: ' + error);
        });
    }

    generateURLs(partnerships) {

        let entries = Object.entries(partnerships);
        console.log('generating URL: ');
        for (let [key, value] of Object.entries(partnerships)) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: value.Id,
                    actionName: 'view',
                },
            }).then(url => {
                console.log(value);
                value.Id = url;
            });
        }
    }
}