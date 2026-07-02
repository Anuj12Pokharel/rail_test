class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV["SECRET_KEY_BASE"] || "fallback_secret_key_for_testing_1234567890"

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError
    nil
  end
end
