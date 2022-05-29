module SessionsHelper
  # 渡されたユーザーでログインする
  # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成されます
  def log_in(user)
    session[:user_id] = user.id
  end

  # もしsessionにuser_idがあるなら@current_userにuser_idの番号を代入する
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  def log_out
    forget(current_user) if logged_in?
    session.delete(:user_id)
    @current_user = nil
  end

  # cookie
  # 暗号化してcookieに保存、取り出す際は暗号化を解除する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user?(user)
    user && user == current_user
  end

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
