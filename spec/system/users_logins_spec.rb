require 'rails_helper'

RSpec.describe 'ユーザーログイン機能', type: :system, js: true do
  include LoginMacros
  let(:user) { FactoryBot.create(:user) }

  describe 'ログイン画面の操作' do
    context '正しい情報を入力した場合' do
      it 'ログインに成功し、フラッシュメッセージが表示されること' do
        # 1. ログインページにアクセス
        visit new_user_session_path

        # 2. フォームに入力
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password

        # 3. ログインボタンをクリック
        click_button 'ログイン'

        # 4. 画面に成功メッセージが表示されているか確認
        expect(page).to have_content 'ログインしました'
      end
    end

    context '誤ったパスワードを入力した場合' do
      it 'ログインに失敗し、エラーメッセージが表示されること' do
        visit new_user_session_path

        fill_in 'メールアドレス', with: user.email
        # わざと間違えたパスワードを入力
        fill_in 'パスワード', with: 'wrongpassword'

        click_button 'ログイン'

        # エラーメッセージが表示されているか確認
        expect(page).to have_content 'メールアドレスまたはパスワードが違います'
      end
    end
  end
  # ログアウトボタンでログアウトできることのテストも追加
  describe 'ログアウト機能' do
    it 'ログアウトに成功し、フラッシュメッセージが表示されること' do
      # 事前にログインしておく
      login(user)
      # マイページをクリック
      within '.hidden.md\:block' do
        click_link 'マイページ'
      end

        # ログアウトボタンをクリック
        click_on 'ログアウト', visible: true

      # 画面に成功メッセージが表示されているか確認
      expect(page).to have_content 'ログアウトしました。'
    end
  end
end
