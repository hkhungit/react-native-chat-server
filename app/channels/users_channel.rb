class UsersChannel < ApplicationCable::Channel
  def subscribed
    reject and return if current_user.is_a? String
    @channel_stream = "users_#{current_user.id}"
    stream_from @channel_stream
    stream_for_chatsroom
    stream_for_current_user
  end

  def unsubscribed
    stop_all_streams
    @ch_new_cursor.close      if @ch_new_cursor
    @ch_current_cursor.close  if @ch_current_cursor
  end

  private

  def stream_for_current_user
    @ch_current_cursor = User.where({id: current_user.id}).all.raw.changes({include_types: true})
    Thread.new do
      @ch_current_cursor.each do |change|
        response_data = {
          action: :user_change,
          model: :user,
          status: :success,
          data: current_user.reload.format_friends
        }
        broadcast_user_channel(response_data)
      end
    end
  end

  def stream_for_chatsroom
    @ch_new_cursor = Chat.where(->(doc) { doc[:users].contains(->(user) { user['id'].eq current_user.id })}).all.raw.changes(include_types: :true)
    Thread.new do
      @ch_new_cursor.each do |change|
        handle_stream_chatroom(change)
      end
    end
  end

  def handle_stream_chatroom(change)
    response_data = { action: change['type'], model: :chat, status: :success }
    case change['type']
    when "add"
      response_data.merge!({ data: change['new_val']})
    when "remove"
      response_data.merge!({ data: change['old_val']})
    when "change"
      response_data.merge!({ data: change['new_val']})
    end
    broadcast_user_channel(response_data) if response_data[:data].present?
  end

  def broadcast_user_channel(response_data)
    ActionCable.server.broadcast @channel_stream, response_data
  end
end