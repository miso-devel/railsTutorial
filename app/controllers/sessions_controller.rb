class SessionsController < ApplicationController
  def new; end
  def create
    # session paramsがUserの中にいるか確かめる
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in(user)

      # これ使ってんのmodelのforget? helperのforgetやとcookieがないのでdeleteされずエラー吐き出しそう
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
