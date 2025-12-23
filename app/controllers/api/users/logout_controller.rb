class Api::Users::LogoutController < ApplicationController
  def destroy
    sign_out(:user)
    head :no_content
  end
end
