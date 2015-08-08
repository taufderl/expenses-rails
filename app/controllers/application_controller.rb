class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :scope_current_user  

  def scope_current_user
    if current_user
      User.logged_in = current_user.id  
    end
    yield
  end
end
