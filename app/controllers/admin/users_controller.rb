class Admin::UsersController < ApplicationController
  before_action :require_superadmin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:quiz_attempts).order(:email)
    @users_with_stats = @users.map do |user|
      {
        user: user,
        total_attempts: user.quiz_attempts.count,
        correct_attempts: user.quiz_attempts.correct.count,
        accuracy: user.overall_accuracy,
        last_activity: user.quiz_attempts.recent.first&.answered_at
      }
    end
  end

  def show
    @quiz_attempts = @user.quiz_attempts.recent.limit(20)
    @stats = {
      total_attempts: @user.total_attempts,
      correct_attempts: @user.total_correct,
      accuracy: @user.overall_accuracy,
      attempts_by_level: @user.quiz_attempts.group(:level).count,
      attempts_by_type: @user.quiz_attempts.group(:quiz_type).count
    }
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end
