require "json"

module SniplineCli::Models
  # Used for parsing authentication tokens from the API
  class Token
    include JSON::Serializable

    @[JSON::Field(key: "jwt")]
    property jwt : String

    @[JSON::Field(key: "token")]
    property token : String
  end
end
