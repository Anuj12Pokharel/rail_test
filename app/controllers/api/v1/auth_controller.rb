module Api
  module V1
    class AuthController < ApplicationController
      include CamelCaseHandler

      def signin
        auth_params = params[:auth] || {}
        user = User.find_by(email: auth_params[:email])
        if user&.authenticate(auth_params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render_camel_json(serialize_user(user, token), status: :created)
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      private

      def serialize_user(user, token)
        {
          data: {
            id: user.id,
            type: "users",
            attributes: {
              token: token,
              email: user.email,
              name: user.name,
              country: user.country,
              created_at: user.created_at.iso8601,
              updated_at: user.updated_at.iso8601
            }
          }
        }
      end
    end
  end
end
