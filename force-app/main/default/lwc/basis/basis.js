import { api, LightningElement, track, wire } from 'lwc';

export default class Basis extends LightningElement {
    certTypeName;

    handleCertSelected(evt) {
        this.certTypeName = evt.detail;
    }
}