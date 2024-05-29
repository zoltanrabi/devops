import { api, LightningElement, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import Gauge from '@salesforce/resourceUrl/gauge';
import getCertificationsForAll from '@salesforce/apex/CertificationController.getCertificationsForAll'
import getCertificationsByType from '@salesforce/apex/CertificationController.getCertificationsByType'


export default class DataQualityGauge extends LightningElement {
    @api recordId;
    @track accountName;
    certificationDatas;
    @track totalNumberOfCertifications;

    @wire(getCertificationsForAll)
    certifications({error, data}){
        
        if (data){
            this.certificationDatas = data;
            this.totalNumberOfCertifications = data.length;
        }
    };

    @wire(getCertificationsByType)
    certificationsByType({error, data}){
        
        if (data){

            this.accountName = data;
        }
    };

    

gaugeInitialized = false;

renderedCallback() {
    if (this.gaugeInitialized || !this.certificationDatas) {
        return;
    }
    this.gaugeInitialized = true;

    loadScript(this, Gauge).then(() =>{this.initializeGauge()})
}

initializeGauge() {
var opts = {
    angle: -0.1, // The span of the gauge arc
    lineWidth: 0.2, // The line thickness
    radiusScale: 0.85, // Relative radius
    pointer: {
      length: 0.58, // // Relative to gauge radius
      strokeWidth: 0.047, // The thickness
      color: '#000000' // Fill color
    },
            limitMax: false,     // If false, max value increases automatically if value > maxValue
            limitMin: false,     // If true, the min value of the gauge will be fixed
            colorStart: '#6F6EA0',   // Colors
            colorStop: '#C0C0DB',    // just experiment with them
            strokeColor: '#EEEEEE',  // to see which ones work best for you
            generateGradient: true,
            highDpiSupport: true,     // High resolution support
            staticLabels: {
                font: "16px sans-serif",  // Specifies font
                labels: [0, 30, 60, 90, 120, 150],  // Print labels at these values
                color: "#000000",  // Optional: Label text color
                fractionDigits: 0  // Optional: Numerical precision. 0=round off.
              },
            staticZones: [
                {strokeStyle: "rgb(255,0,0)", min: 0, max: 30, height: 1},
                {strokeStyle: "rgb(200,100,0)", min: 30, max: 60, height: 1},
                {strokeStyle: "rgb(150,150,0)", min: 60, max: 90, height: 1},
                {strokeStyle: "rgb(100,200,0)", min: 90, max: 120, height: 1},
                {strokeStyle: "rgb(0,255,0)", min: 120, max: 150, height: 1}
              ],
          };
          var ctx = this.template.querySelector(".gauge"); // your canvas element
          var gauge = new window.Gauge(ctx).setOptions(opts); // create sexy gauge!
          gauge.animationSpeed = 32; // set animation speed (32 is default value)
          gauge.maxValue = 150; // set max gauge value
          gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
          gauge.set(this.certificationDatas.length); // set actual value
    }

    
}