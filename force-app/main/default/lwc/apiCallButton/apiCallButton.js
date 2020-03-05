import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import searchPlace from '@salesforce/apex/GooglePlaces.searchPlace';
import BillingPostalCode from '@salesforce/schema/Account.BillingPostalCode';
import BillingLongitude from '@salesforce/schema/Account.BillingLongitude';
import BillingLatitude from '@salesforce/schema/Account.BillingLatitude';


const FIELDS = [
    'Account.BillingPostalCode',
    'Account.BillingLatitude',
    'Account.BillingLongitude',
];

const columns = [
    {label: 'CSP Id', fieldName: 'Id'},
    {label: 'School', fieldName: 'School_Name__c'},
    {label: 'Church', fieldName: 'Church_Name__c'},
    {label: 'Status', fieldName: 'Status__c'},
    {label: 'Name', fieldName: 'Name'}
];

export default class ApiCallButton extends LightningElement {

    @track showCSPs = false;
    @api recordId;
    @track csps;
    @track columns = columns;

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    account;

    /*
    postalCode = getFieldValue(this.account., BillingPostalCode);
    billingLatitude = getFieldValue(this.account.fields, BillingLatitude);
    billingLongitude = getFieldValue(this.account.fields, BillingLongitude);
    */

    handleFindChurchesClick() {
        console.log(this.account.BillingPostalCode);
        searchPlace({
            account: this.recordId,
            longitude: this.account.data.fields.BillingLongitude.value,
            latitude: this.account.data.fields.BillingLatitude.value,
            radius: 5,
            type: 'church',
            key: 'AIzaSyBJYW5TNtGJ10l9CxUoy0RHJSb6zlbilPk'
        }).then(result => {
            console.log(result);
            this.csps = result;
            this.showCSPs = true;
        })
        .catch(error => {
            console.log(error);
        });
    }
}