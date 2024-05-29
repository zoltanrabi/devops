import { LightningElement, wire, api, track} from 'lwc';
import getCertificationsForAll from '@salesforce/apex/CertificationSummaryController.getCertificationsForAll';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import CERTIFICATE_APPLICATION_OBJECT from '@salesforce/schema/Certificate_Application__c';
import CERTIFICATION_FIELD from '@salesforce/schema/Certificate_Application__c.Certification__c';
import CONTACT_FIELD from '@salesforce/schema/Certificate_Application__c.Contact__c';
import NAME_FIELD from '@salesforce/schema/Certificate_Application__c.Name';


export default class Sidebar extends LightningElement {
    @track certtype;
    @api training;
    @track certificationByTypes;
    @track isButtonDisabled = false;
    certificationByTypes;
    allCertData;
    certtype;
    wiredData;
    isNameFieldValid = true;

    certificateApplicationObject = CERTIFICATE_APPLICATION_OBJECT;
    certificationField = CERTIFICATION_FIELD;
    contactField = CONTACT_FIELD;
    nameField = NAME_FIELD;

    handleCertificationCreated(){
        const inputField = this.template.querySelector('.needReset');
        inputField.reset();
        refreshApex(this.wiredData);
        let event = new CustomEvent('refreshtypes');
        this.dispatchEvent(event);
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        console.log(this.isNameFieldValid);
        if (this.isNameFieldValid == false) {
            let message = event.detail.detail;
            const inputField = this.template.querySelector('.needReset');
            inputField.reset();
            message = "Something went wrong!";
            this.showToast('DUPLICATE', 'This employee already acquired this type of certificate', 'error');
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            if(this.recordId !== null){
                this.dispatchEvent(new ShowToastEvent({
                        title: "SUCCESS!",
                        message: "New record has been created.",
                       variant: "success",
                    }),  
               );    
             }
        }
    }
    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
     this.dispatchEvent(event);
    }


    nameValidation() {
        const contactName = this.template.querySelector('.needReset').value;
        const certTypeField = this.template.querySelector('.certTypeField').value;
        
        for (let i = 0; i < this.allCertData.length; i++) {
            if(this.allCertData[i].nameId == contactName && certTypeField == this.allCertData[i].Id) {
                this.isNameFieldValid = false;
                return;
            }
        }
        this.isNameFieldValid = true;
    }

    @wire(getCertificationsForAll)
    getCertificationsForAll(response) {
        this.wiredData = response;
        const {error, data} = response;
        if (data) {
            
            this.allCertData = data;
            if (this._certTypeName) {
                this.certTypeName = this._certTypeName;
            }

        }
    };

    _certTypeName = undefined;
    
    set certTypeName(value) {
        this._certTypeName = value;
        let certTypeOwners = [];
        let badgeImage;
        let autoNumbers = [];
        let id;
        if (!this.certTypeName) {
            this.certtype = undefined;
        }
        if (value) {          
            for(let i = 0; i < this.allCertData.length; i++){
                if (this.allCertData[i].certName == value) {
                    certTypeOwners.push(this.allCertData[i]);
                    id = this.allCertData[i].Id;
                    badgeImage = this.allCertData[i].badgeImage;
                }
                autoNumbers.push(parseInt(this.allCertData[i].autoNumber.substring(5, 10), 10));
            }
            let nextCertAutoNumber = Math.max(...autoNumbers) + 1;
            let nextCertAutoNumberName;
            if(nextCertAutoNumber < 100) {
                nextCertAutoNumberName = 'CERT-00'.concat(nextCertAutoNumber);
            } else if(nextCertAutoNumber >= 100 && nextCertAutoNumber < 1000) {
                nextCertAutoNumberName = 'CERT-0'.concat(nextCertAutoNumber);
            } else {
                nextCertAutoNumberName = 'CERT-'.concat(nextCertAutoNumber);
            }
            
            this.certtype = 
            {   typeName: value,
                owners: certTypeOwners,
                badgeImage: badgeImage,
                certTypeId: {'Id': id},
                certAutoNumber: nextCertAutoNumberName
            }
        }
    }
        
    @api get certTypeName(){
        return this._certTypeName;
    }

}