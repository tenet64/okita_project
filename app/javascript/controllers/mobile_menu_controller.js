import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 操作対象のパーツ（メニュー本体、開くアイコン、閉じるアイコン）
  static targets = [ "menu", "openIcon", "closeIcon" ]

  connect() {
    // 念のため初期状態は閉じておく
    this.menuTarget.classList.add("hidden")
  }

  // メニューの開閉を切り替える
  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.openIconTarget.classList.toggle("hidden")
    this.closeIconTarget.classList.toggle("hidden")
  }

  // リンクをクリックしたらメニューを閉じる
  close() {
    this.menuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }
}