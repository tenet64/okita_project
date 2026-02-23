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
end