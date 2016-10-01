module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      if @current_user ||= User.where(:tokens.include => get_token).first
        @current_user
      else
        reject_unauthorized_connection
      end
    end

    def get_token
      request.params['token']
    end
  end
end
