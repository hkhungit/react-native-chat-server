class UsersChannel < ApplicationCable::Channel
  def subscribed
    reject and return if current_user.is_a? String
    @channel_stream = "users_#{current_user.id}"
    stream_from @channel_stream
    stream_for_messages
  end

  def unsubscribed
    stop_all_streams
    @ch_new_message.close      if @ch_new_message
  end

  private

  def stream_for_messages
    @ch_new_message = Message.where({:users.include => current_user.id}).all.raw.changes(include_types: true)
    Thread.new do
      @ch_new_message.each do |change|
        if change['type'] == 'add'
          response_data = { model: :message, status: :success, data: change['new_val'] }
          broadcast_user_channel(response_data)
        end
      end
    end
  end

  def broadcast_user_channel(response_data)
    ActionCable.server.broadcast @channel_stream, response_data
  end
end