class StaticPagesController < ApplicationController
  def index
    if user_signed_in?
      redirect_to current_user
    end
  end
end

#fixme add integration test
