# frozen_string_literal: true

class SessionSerializer
  def self.json(user, token)
    user_serializer = UserSerializer.new(user, params: { current_user: user }).serializable_hash
    included_token = [
      {
        "type": 'session',
        "attributes": {
          "token": token
        }
      }
    ]
    user_serializer['included'] = included_token
    user_serializer
  end
end
