module CamelCaseHandler
  extend ActiveSupport::Concern

  included do
    before_action :underscore_params!
  end

  private

  def underscore_params!
    # Convert parameters to unsafe hash, deep underscore all keys, and re-wrap
    new_params = params.to_unsafe_h.deep_transform_keys(&:underscore)
    @_underscored_params = ActionController::Parameters.new(new_params)
  end

  def params
    @_underscored_params || super
  end

  def render_camel_json(data, status: :ok)
    json_ready = data.respond_to?(:as_json) ? data.as_json : data
    render json: camelize_keys(json_ready), status: status
  end

  def camelize_keys(data)
    case data
    when Hash
      data.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    when Array
      data.map { |item| camelize_keys(item) }
    else
      data
    end
  end
end
