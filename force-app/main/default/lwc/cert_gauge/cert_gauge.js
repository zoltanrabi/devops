import { api, LightningElement, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import Gauge from '@salesforce/resourceUrl/gauge';

export default class DataQualityGauge extends LightningElement {
    @api recordId;
    certificationDatas;
    @track numberofcertificates;
    @track gauge;



gaugeInitialized = false;

@api checkGauge(value) {
    this.numberofcertificates = value;
    if (this.gaugeInitialized && this.numberofcertificates) {
        this.gauge.set(this.numberofcertificates);
        return;
    } else if (this.gaugeInitialized || !this.numberofcertificates) {
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
                labels: [0, 20, 40, 60, 75, 87],  // Print labels at these values
                color: "#000000",  // Optional: Label text color
                fractionDigits: 0  // Optional: Numerical precision. 0=round off.
              },
            staticZones: [
                {strokeStyle: "rgb(255,0,0)", min: 0, max: 20, height: 1},
                {strokeStyle: "rgb(200,100,0)", min: 20, max: 40, height: 1},
                {strokeStyle: "rgb(150,150,0)", min: 40, max: 60, height: 1},
                {strokeStyle: "rgb(100,200,0)", min: 60, max: 75, height: 1},
                {strokeStyle: "rgb(0,255,0)", min: 75, max: 87, height: 1}
              ],
          };
          var ctx = this.template.querySelector(".gauge"); // your canvas element
          this.gauge = new window.Gauge(ctx).setOptions(opts); // create sexy gauge!
          this.gauge.animationSpeed = 32; // set animation speed (32 is default value)
          this.gauge.maxValue = 87; // set max gauge value
          this.gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
          this.gauge.set(this.numberofcertificates); // set actual value
    }

    
}