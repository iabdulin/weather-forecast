import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["temperature", "wind", "metricBtn", "imperialBtn"]

  connect() {
    this.metric = undefined
    if (localStorage.getItem('units') === 'metric') {
      this.setMetric()
    } else {
      // default to imperial
      this.setImperial()
    }
  }

  setMetric() {
    this.toggleUnits(true)
  }

  setImperial() {
    this.toggleUnits(false)
  }

  toggleUnits(isMetric) {
    if (this.metric !== isMetric) {
      this.metric = isMetric
      localStorage.setItem('units', isMetric ? 'metric' : 'imperial')
      this.updateDisplay()
      this.updateButtonStates()
    }
  }

  updateButtonStates() {
    this.metricBtnTarget.disabled = this.metric
    this.imperialBtnTarget.disabled = !this.metric
    this.metricBtnTarget.classList.toggle('bg-blue-500', this.metric)
    this.metricBtnTarget.classList.toggle('text-white', this.metric)
    this.imperialBtnTarget.classList.toggle('bg-blue-500', !this.metric)
    this.imperialBtnTarget.classList.toggle('text-white', !this.metric)
  }

  updateDisplay() {
    this.temperatureTargets.forEach(element => {
      const celsius = parseFloat(element.dataset.celsius)
      element.textContent = this.metric ?
        `${Math.round(celsius)}°C` :
        `${this.celsiusToFahrenheit(celsius)}°F`
    })

    this.windTargets.forEach(element => {
      const kph = parseFloat(element.dataset.kph)
      element.textContent = this.metric ?
        `${Math.round(kph)} km/h` :
        `${this.kphToMph(kph)} mph`
    })
  }

  celsiusToFahrenheit(celsius) {
    return Math.round(celsius * 9/5 + 32)
  }

  kphToMph(kph) {
    return Math.round(kph * 0.621371)
  }
}
