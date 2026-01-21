import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mode", "capacityWrap", "capacity"]

  connect() {
    this.update()
    this.modeTarget.addEventListener("change", () => this.update())
  }

  update() {
    const isSolo = this.modeTarget.value === "solo"

    // ソロなら「見せない」
    this.capacityWrapTarget.classList.toggle("hidden", isSolo)

    if (isSolo) {
      // 送信されないように無効化 + 値を消す
      this.capacityTarget.value = ""
      this.capacityTarget.disabled = true
    } else {
      this.capacityTarget.disabled = false
    }
  }
}