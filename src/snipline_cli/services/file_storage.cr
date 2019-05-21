require "baked_file_system"

module SniplineCli
  module Services
    class FileStorage
      extend BakedFileSystem

      bake_folder "../../../public"
    end
  end
end
