import { LightningElement } from 'lwc';

export default class Basis extends LightningElement {
    certTypeName;
    certTrainingMaterial;

    handleCertSelected(evt) {
        this.certTypeName = evt.detail.name;
        this.certTrainingMaterial = evt.detail.trainingMaterial;
    }

    refreshTypes() {
        let list = this.template.querySelector('c-cert_list');
        list.refreshTypes();
    }
    listFiltered() {
        this.certTypeName = undefined;
    }
}