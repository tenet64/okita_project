require 'rails_helper'
require 'ostruct'

RSpec.describe User, type: :model do
  describe 'バリデーションテスト' do
    context '正常系（保存できる場合）' do
      it '名前、メールアドレス、パスワードがあれば有効であること' do
        user = FactoryBot.build(:user)
        expect(user).to be_valid
      end

      it 'Googleログインのユーザー（uidとproviderがある）も有効であること' do
        user = FactoryBot.build(:user, :google_user)
        expect(user).to be_valid
      end
    end

    context '異常系（保存できない場合）' do
      it '名前が空欄だと無効であること' do
        user = FactoryBot.build(:user, name: nil)
        user.valid? # バリデーションを実行してエラーを生成
        expect(user.errors[:name]).to include("を入力してください")
      end

      it 'メールアドレスが空欄だと無効であること' do
        user = FactoryBot.build(:user, email: nil)
        user.valid?
        expect(user.errors[:email]).to include("を入力してください")
      end

      it '同じproviderとuidの組み合わせは重複して登録できないこと' do
        # 1人目を作成
        FactoryBot.create(:user, uid: '12345', provider: 'google_oauth2')
        # 2人目も同じuidとproviderで作成しようとする
        user = FactoryBot.build(:user, uid: '12345', provider: 'google_oauth2')
        user.valid?
        expect(user.errors[:uid]).to include("はすでに存在します")
      end
    end
  end

  describe 'アソシエーションのテスト' do
    it 'ユーザーが削除されたら、紐づく「チャレンジ」も一緒に削除されること' do
      user = FactoryBot.create(:user)
      # ユーザーに紐づくチャレンジを作成
      target_at = 2.hours.from_now
      user.challenges.create!(title: "テスト", target_date: target_at.to_date, target_time: target_at, mode: :solo, status: :ready)

      # ユーザーを削除すると、Challengeの件数が -1 されることを期待
      expect { user.destroy }.to change(Challenge, :count).by(-1)
    end
  end

 describe 'インスタンスメソッドのテスト' do
    it 'total_pointsが、紐づくpoint_transactionsの合計を正しく返すこと' do
      user = FactoryBot.create(:user)

      # 1. 2つの異なるチャレンジ（実績）を作成する
      challenge1 = FactoryBot.create(:challenge, user: user)
      challenge2 = FactoryBot.create(:challenge, user: user)

      # 2. それぞれ別のチャレンジに対してポイントを付与する
      user.point_transactions.create!(
        points: 10, reason: :solo_success, source: challenge1, target_date: Date.today
      )
      user.point_transactions.create!(
        points: 5,  reason: :solo_success, source: challenge2, target_date: Date.today
      )

      expect(user.total_points).to eq(15)
    end
  end
  describe 'バッジ獲得ロジック（check_all_badges）のテスト' do
    let(:user) { FactoryBot.create(:user) }

    # 👈 過去日時エラー回避のため、常に「明日」を使用する
    let(:target_date) { Date.tomorrow }

    # テストを実行する前に、必要なバッジのマスターデータをDBに用意しておく
    before do
      FactoryBot.create(:badge, condition_key: 'total_success_1', name: '初めの一歩')
      FactoryBot.create(:badge, condition_key: 'total_success_10', name: '継続は力なり')
      FactoryBot.create(:badge, condition_key: 'solo_success_10', name: '孤高の早起き')
      FactoryBot.create(:badge, condition_key: 'multi_success_1', name: 'チームプレイヤー')
    end

    context '合計成功回数（total_success）の判定' do
      it '成功したチャレンジが1回の場合、total_success_1 のバッジを1つ獲得すること' do
        # 成功したチャレンジを1つ作成 (target_dateを使用)
        FactoryBot.create(:challenge, user: user, status: :success, target_date: target_date)

        # バッジが1つ増えることを期待
        expect { user.check_all_badges }.to change { user.badges.count }.by(1)
        expect(user.badges.pluck(:condition_key)).to include('total_success_1')
      end

      # テストのタイトルを実態に合わせて修正
      it '成功したチャレンジが10回（ソロ）の場合、合計3つのバッジを獲得すること' do
        FactoryBot.create_list(:challenge, 10, user: user, status: :success, target_date: target_date)

        # 期待値を by(2) から by(3) に変更！
        expect { user.check_all_badges }.to change { user.badges.count }.by(3)

        # 獲得したバッジのリストに solo_success_10 を追加！
        expect(user.badges.pluck(:condition_key)).to include('total_success_1', 'total_success_10', 'solo_success_10')
      end
    end

    context 'モード別成功回数（solo / multi）の判定' do
      it 'マルチモードで1回成功した場合、multi_success_1 のバッジを獲得すること' do
        # 👈 マルチモードには定員(capacity)が必須なので、capacity: 2 を追加！
        FactoryBot.create(:challenge, user: user, mode: :multi, capacity: 2, status: :success, target_date: target_date)

        # total_success_1 と multi_success_1 の2つを同時に獲得する
        expect { user.check_all_badges }.to change { user.badges.count }.by(2)
        expect(user.badges.pluck(:condition_key)).to include('multi_success_1')
      end
    end

    describe '重複付与の防止（award_badge!）' do
      it 'すでに持っているバッジは、再度条件を満たしても二重で付与されないこと' do
        FactoryBot.create(:challenge, user: user, status: :success, target_date: target_date)

        # 1回目の判定（ここでバッジを1つ獲得する）
        user.check_all_badges
        expect(user.badges.count).to eq 1

        # アプリを開き直すなどして、もう一度判定が走ったとする
        # すでに持っているので、バッジの数は一切増えない（変化しない）ことを期待
        expect { user.check_all_badges }.not_to change { user.badges.count }
      end
    end
  end

  describe 'Googleログイン' do
    let(:auth) do
      OpenStruct.new(
        provider: 'google_oauth2',
        uid: 'oauth-uid-1',
        info: OpenStruct.new(
          name: 'OAuth User',
          email: 'oauth-user@example.com'
        )
      )
    end

    it '該当ユーザーが存在しない場合は新規作成すること' do
      expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)

      user = described_class.find_by(provider: 'google_oauth2', uid: 'oauth-uid-1')
      expect(user.name).to eq('OAuth User')
      expect(user.email).to eq('oauth-user@example.com')
    end

    it '該当ユーザーが存在する場合は既存ユーザーを返すこと' do
      existing = create(:user, :google_user, provider: 'google_oauth2', uid: 'oauth-uid-1', email: 'oauth-user@example.com')

      expect { described_class.from_omniauth(auth) }.not_to change(described_class, :count)
      expect(described_class.from_omniauth(auth).id).to eq(existing.id)
    end
  end

  describe '連続起床回数' do
    let(:user) { create(:user) }
    let(:challenge) { create(:challenge, user: user, target_date: Date.tomorrow) }

    it '今日から連続して成功している日数を返すこと' do
      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: Date.current,
        pressed_at: Time.zone.now.change(hour: 6, min: 10)
      )
      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: Date.yesterday,
        pressed_at: 1.day.ago.change(hour: 6, min: 20)
      )

      expect(user.current_streak).to eq(2)
    end
  end

  describe '平均起床時間' do
    let(:user) { create(:user) }
    let(:challenge) { create(:challenge, user: user, target_date: Date.tomorrow) }

    it '直近7日間の平均起床時刻を HH:MM で返すこと' do
      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: Date.yesterday,
        pressed_at: 1.day.ago.change(hour: 6, min: 0)
      )
      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: Date.current,
        pressed_at: Time.zone.now.change(hour: 7, min: 0)
      )

      expect(user.average_wake_up_time_last_7_days).to eq('06:30')
    end
  end

  describe '習慣起床グラフ' do
    let(:user) { create(:user) }
    let(:challenge) { create(:challenge, user: user, target_date: Date.tomorrow) }
    let(:start_date) { Date.current - 6.days }

    it '7日分のラベルと起床時刻を返し、ログがない日は nil になること' do
      day1 = start_date + 1.day
      day2 = start_date + 3.days

      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: day1,
        pressed_at: day1.in_time_zone.change(hour: 6, min: 30)
      )
      create(
        :wake_up_log,
        user: user,
        challenge: challenge,
        status: :success,
        target_date: day2,
        pressed_at: day2.in_time_zone.change(hour: 7, min: 0)
      )

      chart = user.wake_up_time_chart(start_date)

      expect(chart.size).to eq(7)
      expect(chart.find { |label, _| label == day1.strftime('%-m/%-d') }).to eq([ day1.strftime('%-m/%-d'), 6.5 ])
      expect(chart.find { |label, _| label == day2.strftime('%-m/%-d') }).to eq([ day2.strftime('%-m/%-d'), 7.0 ])

      missing_day = start_date + 2.days
      expect(chart.find { |label, _| label == missing_day.strftime('%-m/%-d') }).to eq([ missing_day.strftime('%-m/%-d'), nil ])
    end
  end
end
