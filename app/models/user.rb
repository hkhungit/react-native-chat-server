class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  extend ActiveModel::SecurePassword::ClassMethods

  field :username,        type: String, required: true, unique: true
  field :fullname,        type: String, required: true
  field :status,          type: String
  field :password,        type: String
  field :password_digest, type: String
  field :tokens,          type: Array, default: []
  field :friends,         type: Array, default: []
  field :inviters,        type: Array, default: []

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

  def add_friend(user, host = false)
    friends.push(user.format) unless friendship?(user)
    inviters.delete_if{|usr| usr['id'] == user.id}
    user.add_friend(self) if host
    save
  end

  def add_inviter(user)
    inviters.push(user.format_friends) unless invited?(user)
    save
  end 

  def invite_remove(user)
    inviters.delete_if{|usr| usr['id'] == user.id} && save
  end

  def strangers
    User.where(not: {:id.in => friend_with_ids})
        .where(not: {id: id})
        .map{|stranger| {}.merge({invited: stranger.invited?(self)}.merge(stranger.format_item))}
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
    self.as_json(only: [:id, :username, :fullname, :status])
  end
end
