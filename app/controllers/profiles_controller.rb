class ProfilesController < ApplicationController
  def show; end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      flash.now[:alert] = "プロフィールの更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  private


  def user_params
    params.require(:user).permit(:email, :name)
  end
end
