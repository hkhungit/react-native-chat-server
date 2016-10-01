class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Authenticable
end
