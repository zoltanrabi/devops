import { LightningElement, track, wire, api} from 'lwc';
import getCertificationsByType from '@salesforce/apex/CertificationSummaryController.getCertificationsByType'
import getCertificationsForAll from '@salesforce/apex/CertificationSummaryController.getCertificationsForAll'

export default class List extends LightningElement {
    @track certDataByType;
    certDataByType;

    @wire(getCertificationsByType)
    certificationsByType({error, data}){
        if (data){

            this.certDataByType = data;
        }
    };


    handleTileClick(evt) {
        const event = new CustomEvent('certselected',
        {detail: evt.detail}
        );
        this.dispatchEvent(event);
    }

}