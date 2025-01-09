import { Controller } from "@hotwired/stimulus"
import debounce from "lodash-es/debounce"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.suggestionsVisible = false
    this.selectedIndex = -1
    this.debouncedSearch = debounce(this.performSearch.bind(this), 500)
    this.isLoading = false
    this.inputTarget.addEventListener('focus', this.handleFocus.bind(this))
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener('click', this.boundHandleClickOutside)
  }

  search(event) {
    const query = this.inputTarget.value
    if (query.length < 3) {
      this.hideSuggestions()
      return
    }

    this.showLoadingState()
    this.debouncedSearch()
  }

  showLoadingState() {
    this.isLoading = true
    this.suggestionsTarget.innerHTML = '<div class="p-2">Loading...</div>'
    this.suggestionsTarget.classList.remove("hidden")
  }

  async performSearch() {
    const query = this.inputTarget.value.trim()
    if (query.length < 3) {
      this.hideSuggestions()
      return
    }

    try {
      const response = await fetch(`/forecast/address_suggestions?query=${encodeURIComponent(query)}`)
      const { suggestions, cache_age } = await response.json()
      this.showSuggestions(suggestions, cache_age)
    } catch (error) {
      console.error("Error fetching suggestions:", error)
      this.suggestionsTarget.innerHTML = '<div class="p-2 text-red-500">Error loading suggestions</div>'
    } finally {
      this.isLoading = false
    }
  }

  showSuggestions(suggestions, cacheAge) {
    if (suggestions.length === 0) {
      this.suggestionsTarget.innerHTML = '<div class="p-2 text-gray-500">No results found</div>'
      this.suggestionsTarget.classList.remove("hidden")
      this.suggestionsVisible = true
      return
    }

    const countryCodeToFlag = (countryCode) => {
      if (!countryCode || countryCode === "unknown") return "🏳️ "
      const codePoints = countryCode
        .toUpperCase()
        .split('')
        .map(char => 127397 + char.charCodeAt())
      return String.fromCodePoint(...codePoints)
    }

    this.suggestionsTarget.classList.add("fixed")

    this.suggestionsTarget.innerHTML = suggestions
      .map(suggestion => {
        const flag = countryCodeToFlag(suggestion.country_code)
        return `<div class="suggestion p-2 hover:bg-gray-100  dark:hover:bg-gray-900 cursor-pointer" data-coordinates="${suggestion.coordinates}" data-country-code="${suggestion.country_code}">
          ${flag} ${suggestion.label}
        </div>`
      })
      .join("")

    this.suggestionsTarget.classList.remove("hidden")
    this.suggestionsVisible = true
    this.addSuggestionListeners()
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsVisible = false
  }

  addSuggestionListeners() {
    this.suggestionsTarget.querySelectorAll(".suggestion").forEach(element => {
      element.addEventListener("click", (e) => {
        const suggestion = e.target.closest('.suggestion')
        this.selectSuggestion(suggestion)
      })
    })
  }

  selectSuggestion(suggestion) {
    this.inputTarget.value = suggestion.textContent.trim()
    this.selectedCoordinates = suggestion.dataset.coordinates
    this.hideSuggestions()
    window.location.href = `/forecast/${this.selectedCoordinates}`
  }

  handleKeydown(event) {
    if (!this.suggestionsVisible) return

    const suggestions = this.suggestionsTarget.querySelectorAll(".suggestion")

    switch(event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, suggestions.length - 1)
        this.highlightSuggestion()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.highlightSuggestion()
        break
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          this.selectSuggestion(suggestions[this.selectedIndex])
        }
        break
      case "Escape":
        this.hideSuggestions()
        break
    }
  }

  highlightSuggestion() {
    const suggestions = this.suggestionsTarget.querySelectorAll(".suggestion")
    suggestions.forEach((el, index) => {
      if (index === this.selectedIndex) {
        el.classList.add("bg-gray-100", "dark:bg-gray-900")
      } else {
        el.classList.remove("bg-gray-100", "dark:bg-gray-900")
      }
    })
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  handleFocus() {
    const query = this.inputTarget.value
    if (query.length >= 3) {
      this.showLoadingState()
      this.performSearch()
    }
  }

  disconnect() {
    this.debouncedSearch.cancel()
    this.inputTarget.removeEventListener('focus', this.handleFocus.bind(this))
    document.removeEventListener('click', this.boundHandleClickOutside)
  }
}
