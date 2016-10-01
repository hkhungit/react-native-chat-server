class Chat
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  extend Enumerize

  field :users,          type: Array, default: []
  field :last_message,   type: Hash, default: {}
  field :type,           type: String

  has_many :messages, dependent: :destroy,  foreign_key: :chat_id
  enumerize :type, in: [:single, :group], default: :single

  before_create :generate_type, :sort_users


  def self.find_by_users(users, single = true)
    type      = single ? :single : :group
    _users    = users.map{|user| user.id }
    chatroom  = ChatRoom.where(->(doc) { doc[:users].map(->(user) { user[:id]} ).eq _users.sort }).where({type: type}).first
    chatroom  = ChatRoom.create({users: users}) if chatroom.nil?
    chatroom
  end

  private

  def sort_users
    users.map!{ |user| user.format_item.merge({ last_seen: nil, message_count: 0})}
    users.sort_by!{|user| user[:id]}
  end

  def generate_type
    self.type = :group if type == :single && users.size > 2
  end
end
