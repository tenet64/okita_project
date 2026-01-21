import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["date", "time"]

  connect() {
    this.update()
    this.dateTarget.addEventListener("change", () => this.update())
  }

  update() {
    if (!this.dateTarget.value) {
      this.timeTarget.removeAttribute("min")
      return
    }

    const now = new Date()
    const yyyy = now.getFullYear()
    const mm = String(now.getMonth() + 1).padStart(2, "0")
    const dd = String(now.getDate()).padStart(2, "0")
    const todayStr = `${yyyy}-${mm}-${dd}`

    if (this.dateTarget.value === todayStr) {
      const hh = String(now.getHours()).padStart(2, "0")
      const mi = String(now.getMinutes()).padStart(2, "0")
      const minStr = `${hh}:${mi}`

      this.timeTarget.min = minStr

      // すでに過去時刻が入ってたら min に寄せる（任意だけど親切）
      if (this.timeTarget.value && this.timeTarget.value < minStr) {
        this.timeTarget.value = minStr
      }
    } else {
      this.timeTarget.removeAttribute("min")
    }
  }
}