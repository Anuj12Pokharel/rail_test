module Authenticatable
  extend ActiveSupport::Concern

  def current_user
    @current_user ||= authorize_request
  end

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    return nil if header.blank?

    token = header.split(' ').last
    return nil if token.blank?

    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    User.find_by(id: decoded[:user_id])
  end
end
