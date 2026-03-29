import consumer from "./consumer"
console.log("WakeUpChannelのJSファイル自体は読み込まれました");

const challengeElement = document.getElementById("challenge-data");

if (challengeElement) {
  // 1. datasetから値をしっかり取得する
  const challengeId = challengeElement.dataset.challengeId;
  console.log("購読するチャレンジID:", challengeId);

  // 2. チャンネル名をRails側（WakeUpChannel）と合わせる
  consumer.subscriptions.create({ channel: "WakeUpChannel", challenge_id: challengeId }, {
    
    connected() {
      console.log("WakeUpChannelに接続しました")
    },

    disconnected() {
      // サーバー側でサブスクリプションが終了したときに呼び出されます
    },

    received(data) {
      console.log("データを受信しました！", data);
      const userRow = document.getElementById(`user_status_${data.user_id}`);
      if (userRow) {
        const statusLabel = userRow.querySelector('.status-label');
        if (statusLabel) {
          statusLabel.innerHTML = `<span class="text-green-600 font-bold">
            起床成功（${data.pressed_at}）
          </span>`;
        
          userRow.classList.add('bg-yellow-50');
          setTimeout(() => userRow.classList.remove('bg-yellow-50'), 2000);
        }
      }
    }
  }); // 3. ここで create メソッドを閉じる必要があります
}