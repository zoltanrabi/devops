import { wire, LightningElement, track } from 'lwc';

import getContacts from '@salesforce/apex/CertificationSummaryController.getContacts'

import { publish, MessageContext } from 'lightning/messageService';
import CERTIFICATION_FILTERED_MESSAGE from '@salesforce/messageChannel/CertificationFiltered__c';

const DELAY = 350;

export default class Cert_filter extends LightningElement {
    
    filters = {
        employeeName: ''
    };

    @track contacts = [];


    @wire(getContacts)
    Contacts({error, data}){
        if (data) {
            this.contacts.push(...this.contacts, {value: "All", label: "All"});
            for(let i = 0; i < data.length; i++) {
                this.contacts = [...this.contacts ,{value: data[i].Name, label: data[i].Name}];                                 
            }                
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    };

    get contactOptions() {
        return this.contacts;
    }

      @wire(MessageContext)
      messageContext;

    handleEmployeeNameChange(event) {
        this.filters.employeeName = event.target.value;
        this.delayedFireFilterChangeEvent();
        const evt = new CustomEvent('listfiltered');
        this.dispatchEvent(evt);
    }

    delayedFireFilterChangeEvent() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            publish(this.messageContext, CERTIFICATION_FILTERED_MESSAGE, {
                filters: this.filters
            });
        }, DELAY);
    }

}