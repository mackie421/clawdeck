import { Controller } from "@hotwired/stimulus"

// Manages sidebar open/collapsed state with localStorage persistence.
// On mobile (<768px), sidebar overlays content and dismisses on outside click.
// On desktop, sidebar pushes content with a margin transition.
export default class extends Controller {
  static targets = ["sidebar", "content", "overlay"]

  connect() {
    this.mediaQuery = window.matchMedia("(min-width: 768px)")
    this.handleResize = this.handleResize.bind(this)
    this.mediaQuery.addEventListener("change", this.handleResize)

    // Restore state from localStorage (default: open on desktop, closed on mobile)
    const stored = localStorage.getItem("sidebar-open")
    if (this.mediaQuery.matches) {
      this.isOpen = stored === null ? true : stored === "true"
    } else {
      this.isOpen = false
    }

    this.applyState(false)

    // Mark sidebar as ready (removes initial hidden state from CSS)
    document.documentElement.classList.add("sidebar-ready")
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.handleResize)
    document.documentElement.classList.remove("sidebar-ready", "sidebar-open")
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.applyState(true)
    if (this.mediaQuery.matches) {
      localStorage.setItem("sidebar-open", this.isOpen)
    }
  }

  close() {
    if (!this.mediaQuery.matches && this.isOpen) {
      this.isOpen = false
      this.applyState(true)
    }
  }

  handleResize() {
    if (this.mediaQuery.matches) {
      // Desktop: restore stored state, hide overlay
      const stored = localStorage.getItem("sidebar-open")
      this.isOpen = stored === null ? true : stored === "true"
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
    } else {
      // Mobile: always start closed
      this.isOpen = false
    }
    this.applyState(false)
  }

  applyState(animate) {
    if (this.isOpen) {
      document.documentElement.classList.add("sidebar-open")
      if (!this.mediaQuery.matches && this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("hidden")
      }
    } else {
      document.documentElement.classList.remove("sidebar-open")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.add("hidden")
      }
    }
  }
}
