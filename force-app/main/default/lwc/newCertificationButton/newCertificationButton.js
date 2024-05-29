import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NewCertificationButton extends NavigationMixin(LightningElement) {
    navigateToNewCertification() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Certification__c',
                actionName: 'new'                
            },
            state : {
                navigationLocation: 'RELATED_LIST'
            }
          });
}
}