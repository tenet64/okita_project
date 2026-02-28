require 'rails_helper'

RSpec.describe Challenge, type: :model do
  describe 'バリデーションのテスト' do
    context '正常系' do
      it 'ソロモードの場合、タイトル、日付、時間があれば有効であること' do
        challenge = FactoryBot.build(:challenge)
        expect(challenge).to be_valid
      end

      it 'マルチモードの場合、定員(capacity)が2以上なら有効であること' do
        challenge = FactoryBot.build(:challenge, :multi, capacity: 2)
        expect(challenge).to be_valid
      end
    end

    context '異常系（共通・ソロ）' do
      it '過去の日時を設定すると無効であること' do
        challenge = FactoryBot.build(:challenge, target_date: 1.day.ago.to_date)
        challenge.valid?
        expect(challenge.errors[:target_time]).to include("は現在時刻より後を選択してください")
      end

      it 'ソロモードで定員(capacity)を入力しても、保存前に自動でnilになること' do
        # clear_capacity_for_solo コールバックのテスト
        challenge = FactoryBot.build(:challenge, mode: :solo, capacity: 5)
        challenge.valid? # バリデーションを走らせるとコールバックが発動する
        expect(challenge.capacity).to be_nil
      end
    end

    context '異常系（マルチ）' do
      it 'マルチモードで定員が1人の場合は無効であること' do
        challenge = FactoryBot.build(:challenge, :multi, capacity: 1)
        challenge.valid?
        expect(challenge.errors[:capacity]).to include("は2以上の値にしてください")
      end

      it 'マルチモードで定員が空欄の場合は無効であること' do
        challenge = FactoryBot.build(:challenge, :multi, capacity: nil)
        challenge.valid?
        expect(challenge.errors[:capacity]).to include("を入力してください")
      end
    end
  end

  describe 'インスタンスメソッド（時間計算）のテスト' do
    let(:user) { FactoryBot.build(:user) }
    let(:challenge) do
      FactoryBot.build(:challenge, user: user, target_date: Date.new(2026, 4, 1), target_time: Time.zone.parse("06:30:00"))
    end

    it 'target_atが日付と時間を組み合わせた正しいTimeオブジェクトを返すこと' do
      expect(challenge.target_at).to eq Time.zone.parse("2026-04-01 06:30:00")
    end

    it 'wakeup_window_startが目標時刻の5分前を返すこと' do
      expect(challenge.wakeup_window_start).to eq Time.zone.parse("2026-04-01 06:25:00")
    end

    it 'wakeup_window_endが目標時刻の5分後を返すこと' do
      expect(challenge.wakeup_window_end).to eq Time.zone.parse("2026-04-01 06:35:00")
    end
  end

  describe '時間経過に伴う状態変化のテスト' do
    # タイムトラベル（時間を固定・移動する機能）を有効にする
    include ActiveSupport::Testing::TimeHelpers

    let(:user) { FactoryBot.build(:user) }
    let(:challenge) do
      # わかりやすく「今日の06:30」に設定
      FactoryBot.build(:challenge, user: user, target_date: Date.today, target_time: Time.zone.parse("06:30:00"), status: :ready)
    end

    # 起床ウィンドウは target_time の前後5分（06:25:00 〜 06:35:00）

    it '6:24の時点では「待機中(waiting_for_wakeup?)」であること' do
      # travel_to を使うと、ブロックの中だけ時間がその時刻でストップします
      travel_to Time.zone.parse("06:24:59") do
        expect(challenge.waiting_for_wakeup?).to be true
        expect(challenge.wakeup_available?).to be false
      end
    end

    it '6:30の時点では「起床可能(wakeup_available?)」であること' do
      travel_to Time.zone.parse("06:30:00") do
        expect(challenge.waiting_for_wakeup?).to be false
        expect(challenge.wakeup_available?).to be true
        expect(challenge.wakeup_missed?).to be false
      end
    end

    it '6:36の時点では「失敗/押しそびれ(wakeup_missed?)」であること' do
      travel_to Time.zone.parse("06:35:01") do
        expect(challenge.wakeup_available?).to be false
        expect(challenge.wakeup_missed?).to be true
      end
    end
  end

  describe 'アクション権限（action_state_for）のテスト（ソロモード）' do
    include ActiveSupport::Testing::TimeHelpers

    # 権限やログの判定にはデータベースの検索が絡むため create を使用
    let(:host) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:user) }
    # 常に「明日」をターゲットにする
    let(:target_date) { Date.tomorrow }
    
    let(:challenge) do
      FactoryBot.create(:challenge, user: host, target_date: target_date, target_time: Time.zone.parse("06:30:00"), mode: :solo, status: :ready)
    end

    it '他人が見た場合は :ready_no_permission が返ること' do
      expect(challenge.action_state_for(other_user)).to eq :ready_no_permission
    end

    it 'ホストが起床時間前に見た場合は :ready_waiting が返ること' do
      travel_to Time.zone.parse("#{target_date} 06:20:00") do
        expect(challenge.action_state_for(host)).to eq :ready_waiting
      end
    end

    it 'ホストが起床時間中に見た場合は :ready_can_wake が返ること' do
      travel_to Time.zone.parse("#{target_date} 06:30:00") do
        expect(challenge.action_state_for(host)).to eq :ready_can_wake
      end
    end

    it 'ホストが既に起床ボタンを押した後に見た場合は :success が返ること' do
      # 起床ログを作成して「すでに起きた」状態を再現する
      challenge.wake_up_logs.create!(user: host, target_date: target_date, pressed_at: Time.current, status: :success)

      travel_to Time.zone.parse("#{target_date} 06:30:00") do
        expect(challenge.action_state_for(host)).to eq :success
      end
    end
  end
end