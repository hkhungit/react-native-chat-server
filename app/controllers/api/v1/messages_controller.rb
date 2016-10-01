class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_with_token!

  def index
    if chat = Chat.find(chat_id)
      render json: {
        operation: :index,
        status: :success,
        data: chat,
      }
    else
      render json: {
        operation: :create,
        status: :failed,
      }
    end
  end

  def create
    message = Message.new(message_params.merge!({sender_id: current_user.id}))
    render json: message.save
  end

  private
  
  def message_params
    params.require(:message).permit(:content, :chat_id).to_h
  end

  def chat_id
    params.require(:message).permit(:chat_id).to_h
  end
end
