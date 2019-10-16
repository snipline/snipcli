require "json"

module SniplineCli::Models
  class Token
    include JSON::Serializable

    @[JSON::Field(key: "jwt")]
    property jwt : String

    @[JSON::Field(key: "token")]
    property token : String
  end
end
