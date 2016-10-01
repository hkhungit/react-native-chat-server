module Authenticable
  def authenticate_with_token!
    render json: { errors: "Not authenticated" },
                status: :unauthorized unless current_user.present?
  end

  def current_user
    token = request.headers['Authorization'] || params[:token]
    @current_user ||= User.where(:tokens.include => token).first
  end

  def user_signed_in?
    current_user.present?
  end
end