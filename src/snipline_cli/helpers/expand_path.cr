require "file"

module SniplineCli::Helpers
  extend self

  def expand_path(path)
    {% if flag?(:static_linux) %}
      File.expand_path(path)
    {% else %}
      File.expand_path(path, home: true)
    {% end %}
  end
end
