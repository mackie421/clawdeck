import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="research-hub"
export default class extends Controller {
  static targets = ["tab", "panel"]

  switchTab(event) {
    const selectedTab = event.currentTarget.dataset.tab

    // Update tab styles
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === selectedTab) {
        tab.classList.remove("border-transparent", "text-content-muted")
        tab.classList.add("border-accent", "text-content")
      } else {
        tab.classList.remove("border-accent", "text-content")
        tab.classList.add("border-transparent", "text-content-muted")
      }
    })

    // Show/hide panels
    this.panelTargets.forEach(panel => {
      if (panel.dataset.panel === selectedTab) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }
}
