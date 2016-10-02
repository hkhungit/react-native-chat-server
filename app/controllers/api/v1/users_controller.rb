class Api::V1::UsersController < ApplicationController
  before_action :authenticate_with_token!, except: [:create]
  def create
    user = User.new(user_params)
    user.username.downcase! if user.username
    if user.save
      render json: {
        status: :success,
        data: user
      }
    else
      render json: {
        status: :failed,
        data: user.errors,
      }
    end
  end

  def inviters
    render json: {
      operation: :inviters,
      status: :success,
      data: current_user.inviters
    }
  end

  def chats
    render json: {
      operation: :chatrooms,
      status: :success,
      data: current_user.chats
    }
  end
 
  def friends
    render json: {
      operation: :friends,
      status: :success,
      data: current_user.friends
    }
  end 
  
  def strangers
    render json: {
      operation: :strangers,
      status: :success,
      data: current_user.strangers
    }
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :fullname).to_h
  end
end