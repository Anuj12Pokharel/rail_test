module Api
  module V1
    class UsersController < ApplicationController
      include CamelCaseHandler

      def signup
        user = User.new(user_params)
        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render_camel_json(serialize_user(user, token), status: :created)
        else
          # Sign-Up Validation Error returns 422 with empty body
          head :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :email, :password, :country)
      end

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
