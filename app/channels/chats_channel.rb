class ChatsChannel < ApplicationCable::Channel
  def subscribed
    reject and return if current_user.is_a? String
    @channel_stream = "chat_#{params[:room_id]}"
    @room           = Chat.find(params[:room_id])
    stream_for_message
  end

  def unsubscribed
    @db_cursor.close          if @db_cursor
    stop_all_streams
  end

  private

  def stream_for_message
    @db_cursor = Message.where({chat_id: @room.id}).all.raw.changes(include_types: true)
    Thread.new do
      @db_cursor.each do |change|
        if change['type'] == 'add'
          message = Message.find(change['new_val']['id'])
          response_data = { operation: :message,  model: :message, status: :success, data: message }
          broadcast_chatschannel(response_data)
        end
      end
    end
  end

  def broadcast_chatschannel(response_data)
    ActionCable.server.broadcast @channel_stream, response_data
  end
end