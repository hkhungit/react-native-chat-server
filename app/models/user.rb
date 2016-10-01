class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  extend ActiveModel::SecurePassword::ClassMethods

  field :username,        type: String, required: true, unique: true
  field :fullname,        type: String, required: true
  field :password,        type: String
  field :password_digest, type: String
  field :tokens,          type: Array
  field :friends,         type: Array
  field :inviters,        type: Array

  has_many :messages
  has_secure_password

  def invited?(user)
    inviters.detect{|usr| usr['id'] == user.id} ? true : false
  end  

  def friendship?(user)
    friends.detect{|usr| usr['id'] == user.id} ? true : false
  end

  def chat_with_ids
    chatrooms.all.map { |x| x.id }
  end

  def friend_with_ids
    friends.map { |x| x['id'] }
  end  

  def chats
    Chat.where(->(doc) { doc[:users].contains(->(user) { user['id'].eq id })})
             .order_by(->(doc) { doc[:last_message][:created_at] } => :desc)
  end

  def verify_token(token)
    self.tokens.include? token
  end

  def generate_authorization
    token = SecureRandom.uuid.gsub(/\-/,'')
    self.tokens ||= []
    self.tokens << token
    save
    token
  end

  def format
    self.as_json(except: [:tokens, :password, :password_digest, :friends, :inviters])
  end  

  def format_friends
    self.as_json(except: [:tokens, :password, :password_digest])
  end  

  def format_item
    self.as_json(only: [:id, :fullname])
  end
end
