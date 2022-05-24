module LoginSupport
  def logged_in?
    !session[:user_id].nil?
  end
end

RSpec.configure { |config| config.include LoginSupport }
