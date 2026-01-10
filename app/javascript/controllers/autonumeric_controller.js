import { Controller } from '@hotwired/stimulus'
import AutoNumeric from 'autonumeric'

export default class extends Controller {
  static values = {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 999999.99 },
    currency: { type: String, default: '€' }
  }

  connect() {
    const autoNumericOptions = {
      decimalCharacter: '.',
      decimalPlaces: 2,
      digitGroupSeparator: ',',
      minimumValue: this.minValue,
      maximumValue: this.maxValue,
      unformatOnSubmit: true,
      currencySymbol: this.currencyValue,
      currencySymbolPlacement: 'p', // 'p' for prefix
      modifyValueOnWheel: false,
      rawValueDivisor: 0.01,
      outputFormat: 'number'
    }

    new AutoNumeric(this.element, autoNumericOptions)
  }
}
