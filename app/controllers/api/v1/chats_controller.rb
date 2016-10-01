class Api::V1::ChatsController < ApplicationController
  before_action :authenticate_with_token!
  def index
    users = User.pluck(:id, :username, :fullname).where(:not => [{id: current_user.id}])
    
    render json: {
      status: :success,
      data: users
    }
  end
end