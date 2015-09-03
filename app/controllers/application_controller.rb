class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def pagination(page)
    page = page.to_i
    page = params[:page] = 1 if page < 1
    { size: PER_PAGE, from: PER_PAGE * (page - 1) }
  end
end
