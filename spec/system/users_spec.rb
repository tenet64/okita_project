require 'rails_helper'
# ユーザーの新規登録のシステムスペックを検証する

RSpec.describe 'ユーザー新規登録機能', type: :system do
  include LoginMacros

  describe 'ユーザー新規登録の操作' do
    let(:user) { FactoryBot.build(:user) }
    context '正しい情報を入力した場合' do
      it 'ユーザーの新規登録に成功し、フラッシュメッセージが表示されること' do
        # 1. 新規登録ページにアクセス
        visit new_user_registration_path

        # 2. フォームに入力
        fill_in '名前', with: user.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password
        fill_in 'パスワード確認', with: user.password_confirmation

        # 3. 新規登録ボタンをクリック
        click_button '新規登録'

        # 4. 画面に成功メッセージが表示されているか確認
        expect(page).to have_content 'アカウント登録が完了しました'
      end
    end

    # 登録済みのメールアドレスを入力した場合のテスト
    context '登録済みのメールアドレスを入力した場合' do
      before do
        FactoryBot.create(:user, email: user.email)
      end

      it 'ユーザーの新規登録に失敗し、エラーメッセージが表示されること' do
        visit new_user_registration_path

        fill_in '名前', with: user.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password
        fill_in 'パスワード確認', with: user.password_confirmation

        click_button '新規登録'

        expect(page).to have_content 'メールアドレスはすでに存在します'
      end
    end

    context '誤った情報を入力した場合' do
      it 'ユーザーの新規登録に失敗し、エラーメッセージが表示されること' do
        visit new_user_registration_path

        fill_in '名前', with: ''
        fill_in 'メールアドレス', with: ''
        fill_in 'パスワード', with: ''
        fill_in 'パスワード確認', with: ''

        click_button '新規登録'

        expect(page).to have_content '名前を入力してください'
      end
    end
  end

  # ログインしていない状態でマイページにアクセスした場合
  describe 'マイページへのアクセス制限' do
    it 'ログインしていない状態でマイページにアクセスすると、ログインページにリダイレクトされること' do
      visit mypage_path

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'ログインもしくはアカウント登録してください'
    end
  end
end
