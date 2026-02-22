import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="research-hub"
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.tabTargets.forEach(tab => {
      tab.setAttribute("role", "tab")
      const isSelected = tab.classList.contains("border-accent")
      tab.setAttribute("aria-selected", isSelected)
      tab.setAttribute("tabindex", isSelected ? "0" : "-1")
    })
    this.panelTargets.forEach(panel => {
      panel.setAttribute("role", "tabpanel")
      panel.setAttribute("tabindex", "0")
    })
  }

  switchTab(event) {
    this.activateTab(event.currentTarget.dataset.tab)
  }

  keydown(event) {
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    let newIndex
    switch (event.key) {
      case "ArrowRight": newIndex = (currentIndex + 1) % this.tabTargets.length; break
      case "ArrowLeft": newIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length; break
      case "Home": newIndex = 0; break
      case "End": newIndex = this.tabTargets.length - 1; break
      default: return
    }
    event.preventDefault()
    this.tabTargets[newIndex].focus()
    this.activateTab(this.tabTargets[newIndex].dataset.tab)
  }

  activateTab(selectedTab) {
    this.tabTargets.forEach(tab => {
      const isSelected = tab.dataset.tab === selectedTab
      tab.classList.toggle("border-transparent", !isSelected)
      tab.classList.toggle("text-content-muted", !isSelected)
      tab.classList.toggle("border-accent", isSelected)
      tab.classList.toggle("text-content", isSelected)
      tab.setAttribute("aria-selected", isSelected)
      tab.setAttribute("tabindex", isSelected ? "0" : "-1")
    })
    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.panel !== selectedTab)
    })
  }
}
