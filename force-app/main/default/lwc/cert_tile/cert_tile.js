import { LightningElement, api } from 'lwc';

export default class Tile extends LightningElement {
    @api certtypedata;

    tileClick() {
        const event = new CustomEvent('tileclick', {

            detail: this.certtypedata
        });

        this.dispatchEvent(event);
    }
}