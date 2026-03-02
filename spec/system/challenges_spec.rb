require 'rails_helper'

RSpec.describe 'チャレンジ管理', type: :system, js: true  do
  include LoginMacros
  let(:user) { FactoryBot.create(:user) }
  let(:challenge) { FactoryBot.create(:challenge, user: user) }

  describe 'ログイン前' do
    it 'チャレンジの一覧ページにアクセスできないこと' do
      visit challenges_path
      expect(page).to have_content 'ログインもしくはアカウント登録してください。'
    end

    it 'チャレンジの詳細ページにアクセスできないこと' do
      visit challenge_path(challenge)
      # save_and_open_page
      expect(page).to have_content 'ログインもしくはアカウント登録してください。'
    end
  end

  describe 'ログイン後' do
    before do
      login(user)
    end

    it 'チャレンジの一覧ページにアクセスできること' do
      challenge
      visit challenges_path
      # save_and_open_page
      expect(page).to have_content challenge.title
    end

    it 'チャレンジの詳細ページにアクセスできること' do
      visit challenge_path(challenge)
      expect(page).to have_content challenge.title
    end
  end
end
