import { LightningElement, track, wire, api} from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { subscribe, MessageContext } from 'lightning/messageService';

import getCertificationsByType from '@salesforce/apex/CertificationSummaryController.getCertificationsByType'
import CERTIFICATION_FILTERED_MESSAGE from '@salesforce/messageChannel/CertificationFiltered__c';


export default class List extends LightningElement {
    @track certDataByType;
    @track filters;
    numberOfCertificates;

    wiredData;
    certDataByType;
    @track filtered;
    certCount;
    filters = {};


    @wire(MessageContext) messageContext;

    certificationFilterSubscription;

    connectedCallback() {
        this.certificationFilterSubscription = subscribe(
            this.messageContext,
            CERTIFICATION_FILTERED_MESSAGE,
            (message) => this.handleFilterChange(message)
        );
    }

    @wire(getCertificationsByType, {
        filters: '$filters'
    })
    async certificationsByType(response){
        this.wiredData = response;
        const {error, data} = response;
        if (data){
            this.certDataByType = data;
            if (this.certDataByType.length > 0) {
                this.filtered=this.certDataByType[0].filtered;
            } else if (this.certDataByType.length == 0){
                this.filtered=true;
            }
            
            this.certCount=data.length;
            await this.countCert();
            if (!this.filtered) {
                let gauge = this.template.querySelector('c-cert_gauge');
                gauge.checkGauge(this.numberOfCertificates);
            }

        } else if (error) {
        }
    };

    countCert() {
        let counter = 0;
        for (let i = 0; i < this.certDataByType.length; i++) {
            counter += this.certDataByType[i].count;
        }
        this.numberOfCertificates = counter;

    }

    handleTileClick(evt) {
        const event = new CustomEvent('certselected',
        {detail: evt.detail}
        );
        this.dispatchEvent(event);
    }

    handleFilterChange(message) {
        this.filters = { ...message.filters };
    }

    @api refreshTypes() {
        refreshApex(this.wiredData);
    };

}