class Message
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :content,        :type => String
  field :users,          :type => Array

  belongs_to :user,       index: true, foreign_key: :sender_id
  belongs_to :chat,       index: true, foreign_key: :chat_id

  before_create :set_users
  after_create  :set_data_chat

  private

  def set_users
    self.users = chat.users.map{ |user| user[:id] }  
  end

  def set_data_chat
    chat.last_message  = self
    chat.save
  end
end
