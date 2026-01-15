import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"]
  static values = { targetAt: String }

  connect() {
    this.targetTime = new Date(this.targetAtValue)
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  tick() {
    const now = new Date()
    let diff = Math.floor((this.targetTime - now) / 1000)

    if (diff <= 0) {
      this.update(0, 0, 0)
      clearInterval(this.timer)
      return
    }

    const days = Math.floor(diff / 86400) 
    diff %= 86400
    const hours = Math.floor(diff / 3600)
    diff %= 3600
    const minutes = Math.floor(diff / 60)
    const seconds = diff % 60

    this.update(days, hours, minutes, seconds)
  }

  update(d, h, m, s) {
    this.daysTarget.textContent = String(d).padStart(2, "0")
    this.hoursTarget.textContent = String(h).padStart(2, "0")
    this.minutesTarget.textContent = String(m).padStart(2, "0")
    this.secondsTarget.textContent = String(s).padStart(2, "0")
  }
}