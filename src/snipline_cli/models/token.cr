require "json"

module SniplineCli
    class Token
        include JSON::Serializable

        @[JSON::Field(key: "jwt")]
        property jwt : String

    end
end

