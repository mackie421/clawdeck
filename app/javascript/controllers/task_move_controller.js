import { Controller } from "@hotwired/stimulus"

// Mobile-only status picker for moving tasks between kanban columns.
// Visible on small screens where drag-and-drop isn't practical.
export default class extends Controller {
  static targets = ["menu"]
  static values = {
    url: String,
    taskId: String,
    currentStatus: String
  }

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    this.closeMenu()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.openMenu(event.currentTarget)
    } else {
      this.closeMenu()
    }
  }

  openMenu(button) {
    const menu = this.menuTarget
    menu.classList.remove("hidden")
    menu.style.visibility = "hidden"
    menu.style.position = "fixed"
    menu.style.left = "0"
    menu.style.top = "0"

    // Measure menu size
    const rect = menu.getBoundingClientRect()
    const btnRect = button.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight

    // Position above or below the button
    let left = btnRect.left
    let top = btnRect.bottom + 4

    // Flip above if it would overflow bottom
    if (top + rect.height > viewportHeight - 8) {
      top = btnRect.top - rect.height - 4
    }

    // Keep within horizontal bounds
    if (left + rect.width > viewportWidth - 8) {
      left = viewportWidth - rect.width - 8
    }
    if (left < 8) left = 8
    if (top < 8) top = 8

    menu.style.left = `${left}px`
    menu.style.top = `${top}px`
    menu.style.visibility = "visible"

    document.addEventListener("click", this.handleClickOutside)
    document.addEventListener("keydown", this.handleKeydown)
  }

  closeMenu() {
    const menu = this.menuTarget
    menu.classList.add("hidden")
    menu.style.position = ""
    menu.style.left = ""
    menu.style.top = ""
    menu.style.visibility = ""
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleKeydown)
  }

  async move(event) {
    event.preventDefault()
    event.stopPropagation()

    const newStatus = event.currentTarget.dataset.status
    if (newStatus === this.currentStatusValue) {
      this.closeMenu()
      return
    }

    const oldStatus = this.currentStatusValue
    this.closeMenu()

    // Optimistically update column counts
    this.updateColumnCount(oldStatus, -1)
    this.updateColumnCount(newStatus, 1)

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ task_id: this.taskIdValue, status: newStatus })
      })

      if (!response.ok) {
        // Revert counts on failure
        this.updateColumnCount(oldStatus, 1)
        this.updateColumnCount(newStatus, -1)
        console.error("Failed to move task")
      }
    } catch (error) {
      // Revert counts on error
      this.updateColumnCount(oldStatus, 1)
      this.updateColumnCount(newStatus, -1)
      console.error("Error moving task:", error)
    }
  }

  updateColumnCount(status, delta) {
    const countEl = document.getElementById(`column-${status}-count`)
    if (countEl) {
      countEl.textContent = Math.max(0, (parseInt(countEl.textContent, 10) || 0) + delta)
    }
    const headerCountEl = document.getElementById(`header-${status}-count`)
    if (headerCountEl) {
      headerCountEl.textContent = Math.max(0, (parseInt(headerCountEl.textContent, 10) || 0) + delta)
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeMenu()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.closeMenu()
    }
  }
}
