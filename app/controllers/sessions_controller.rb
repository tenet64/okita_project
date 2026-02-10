class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create, raise: false

  def create
    user = find_or_create_from_auth_hash(auth_hash)
    if user
      sign_in user 
      redirect_to authenticated_root_path, notice: 'ログインしました'
    else
      redirect_to unauthenticated_root_path, alert: 'ログインに失敗しました'
    end
  end

  def destroy
    reset_session
    sign_out current_user if user_signed_in?
    redirect_to unauthenticated_root_path, status: :see_other, notice: 'ログアウトしました'
  end

  private

    def auth_hash
      request.env['omniauth.auth']
    end

    def find_or_create_from_auth_hash(auth_hash)
      email = auth_hash[:info][:email]
      
      provider = auth_hash[:provider]
      uid = auth_hash[:uid]
      email = auth_hash[:info][:email]
      
      User.find_or_create_by(email: email) do |user|
        user.password = Devise.friendly_token[0, 20]
        user.name = auth_hash[:info][:name] # 名前も保存する場合
      end
    end
end