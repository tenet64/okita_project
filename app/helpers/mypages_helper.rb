module MypagesHelper
  # 成功率の表示整形（分母が0なら '--' を返す）
  def format_success_rate(rate, attempts)
    return "--" if attempts.to_i.zero?
    rate
  end

  # 平均起床時刻（nilなら '--:--' を返す）
  def format_avg_time(time_str)
    time_str || "--:--"
  end


  # バッジカードのCSSクラス（獲得状況でスタイルを切り替え）
  def badge_card_classes(is_earned)
    base_classes = "relative flex flex-col items-center p-3 border rounded-xl text-center transition-all duration-300"

    if is_earned
      "#{base_classes} bg-white border-yellow-400 shadow-sm"
    else
      "#{base_classes} bg-gray-50 border-gray-200 grayscale opacity-60"
    end
  end

  # バッジ名の文字色
  def badge_name_color(is_earned)
    is_earned ? "text-gray-800" : "text-gray-500"
  end

  # 説明文の文字色
  def badge_desc_color(is_earned)
    is_earned ? "text-gray-600" : "text-gray-400"
  end


  # 結果（成功/失敗）に応じた文字色クラス
  def log_status_color(status)
    status == "success" ? "text-green-600" : "text-red-600"
  end
end
