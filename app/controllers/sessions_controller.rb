class SessionsController < ApplicationController
  before_action :authenticate_with_token!, except: [:login]

  def login
    user = User.where(:username.eq(username)).first
    if user && user.authenticate(password)
      render json: {
        status: :success,
        data: {
          user: user.format,
          token: user.generate_authorization
        },
      }
    else
      errors = {}
      errors[:username] = []
      errors[:password] = []
      errors[:username] << "can't be blank" if !username
      errors[:username] << "incorrect" if !user && username
      errors[:password] << "can't be blank" if !password
      errors[:password] << "incorrect" if user && password
      render json: {
        status: :failed,
        data: errors
      }
    end
  end

  private

  def username
    username = params.permit(:username)[:username]
    username.downcase if username
  end

  def password
    params.permit(:password)[:password]
  end

  def token
    request.headers['Authorization']
  end
end