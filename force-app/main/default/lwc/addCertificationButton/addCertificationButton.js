import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AddCertificationButton extends NavigationMixin(LightningElement) {

    navigateToAddCertification() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Certificate_Application__c',
                actionName: 'new'
            },
            state: {
                navigationLocation: 'RELATED_LIST',
            }
        });
    }
}