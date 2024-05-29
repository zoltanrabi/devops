import { LightningElement, wire, api, track} from 'lwc';
import getCertificationsForAll from '@salesforce/apex/CertificationSummaryController.getCertificationsForAll';

export default class Sidebar extends LightningElement {
    //@track allCertData;
    //@api allCertData;
    @api certtype;
    allCertData;
    certtype;

    @wire(getCertificationsForAll)
    getCertificationsForAll({error, data}) {
        if (data) {
            console.log(data);
            this.allCertData = data;
            console.log(this.allCertData);
        }
    };

    _certTypeName = undefined;
    
    set certTypeName(value) {
        this._certTypeName = value;
        console.log(value);
        let certTypeOwners = [];
        let badgeImage;
        if (value != undefined) {
            
            for(let i = 0; i < this.allCertData.length; i++){
                if (this.allCertData[i].certName == value) {
                    certTypeOwners.push(this.allCertData[i]);
                    badgeImage = this.allCertData[i].badgeImage;
                }
            }
            this.certtype = 
            {   typeName: value,
                owners: certTypeOwners,
                badgeImage: badgeImage
            }
            console.log(this.certtype);
        }
    }
        
    @api get certTypeName(){
        return this._certTypeName;
    }

}