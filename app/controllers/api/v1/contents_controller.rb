module Api
  module V1
    class ContentsController < ApplicationController
      include CamelCaseHandler
      include Authenticatable

      before_action :authenticate_user!, only: [:create, :update, :destroy]

      def index
        contents = Content.all
        serialized = contents.map { |content| serialize_content(content) }
        render_camel_json({ data: serialized })
      end

      def create
        content = current_user.contents.build(content_params)
        if content.save
          render_camel_json({ data: serialize_content(content) }, status: :created)
        else
          render json: { errors: content.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        content = Content.find_by(id: params[:id])
        return render json: { error: 'Not Found' }, status: :not_found unless content

        if content.user_id != current_user.id
          return render json: { error: 'Forbidden' }, status: :forbidden
        end

        if content.update(content_params)
          render_camel_json({ data: serialize_content(content) }, status: :ok)
        else
          render json: { errors: content.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        content = Content.find_by(id: params[:id])
        return render json: { error: 'Not Found' }, status: :not_found unless content

        if content.user_id != current_user.id
          return render json: { error: 'Forbidden' }, status: :forbidden
        end

        content.destroy
        render json: { message: 'Deleted' }, status: :ok
      end

      private

      def content_params
        params.permit(:title, :body)
      end

      def serialize_content(content)
        {
          id: content.id,
          type: 'content',
          attributes: {
            title: content.title,
            body: content.body,
            created_at: content.created_at.iso8601,
            updated_at: content.updated_at.iso8601
          }
        }
      end
    end
  end
end
