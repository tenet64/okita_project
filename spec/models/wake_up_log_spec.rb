# spec/models/wake_up_log_spec.rb
require 'rails_helper'

RSpec.describe WakeUpLog, type: :model do
  describe 'バリデーションと基本機能' do
    it 'ユーザー、チャレンジ、対象日があれば有効であること' do
      log = FactoryBot.build(:wake_up_log)
      expect(log).to be_valid
    end

    it '同じユーザーが同じチャレンジ・同じ日に2回ログを作れないこと（ユニーク制約）' do
      user = FactoryBot.create(:user)
      # バリデーション回避のため「明日」で作成する
      challenge = FactoryBot.create(:challenge, user: user, target_date: Date.tomorrow)

      # 1回目の記録
      FactoryBot.create(:wake_up_log, user: user, challenge: challenge, target_date: Date.tomorrow)

      # 2回目の記録（エラーになることを期待）
      duplicate_log = FactoryBot.build(:wake_up_log, user: user, challenge: challenge, target_date: Date.tomorrow)
      duplicate_log.valid?
      expect(duplicate_log.errors[:user_id]).to include("はすでに存在します")
    end
  end

  describe 'ポイント付与ロジック（grant_points）' do
    let(:host) { FactoryBot.create(:user) }

    # 常に「明日」をターゲットにする
    let(:target_date) { Date.tomorrow }

    context 'ソロモードの場合' do
      let(:solo_challenge) { FactoryBot.create(:challenge, mode: :solo, user: host, target_date: target_date, status: :ready) }

      it '成功ログを作成すると、ユーザーに1ポイントが付与されること' do
        expect {
          # 起床ログも「明日」として作成
          FactoryBot.create(:wake_up_log, user: host, challenge: solo_challenge, target_date: target_date, status: :success)
        }.to change { host.total_points }.by(1)
      end
    end

    context 'マルチモードの場合' do
      let(:participant) { FactoryBot.create(:user) }
      let(:multi_challenge) { FactoryBot.create(:challenge, mode: :multi, capacity: 2, user: host, target_date: target_date, status: :ready) }

      before do
        # 参加者をチャレンジに参加させる
        FactoryBot.create(:participation, user: participant, challenge: multi_challenge)
      end

      it '1人だけが成功しても、まだポイントは付与されないこと' do
        expect {
          # ホストだけが起きる
          FactoryBot.create(:wake_up_log, user: host, challenge: multi_challenge, target_date: target_date, status: :success)
        }.to change { host.total_points }.by(0)
         .and change { participant.total_points }.by(0)
      end

      it '全員が成功すると、全員に「1ポイント」が付与されること' do
        # 1人目（ホスト）が起きる（この時点ではポイント0）
        FactoryBot.create(:wake_up_log, user: host, challenge: multi_challenge, target_date: target_date, status: :success)

        # 2人目（参加者）が起きた瞬間、全員成功と判定されて1ポイントずつ入る！
        expect {
          FactoryBot.create(:wake_up_log, user: participant, challenge: multi_challenge, target_date: target_date, status: :success)
        }.to change { host.total_points }.by(1)
         .and change { participant.total_points }.by(1)
      end
    end
  end
end
