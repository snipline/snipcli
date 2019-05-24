require "baked_file_system"

module SniplineCli
  module Services

    # FileStorage is used for baking in web assets into the final executable.
    class FileStorage
      extend BakedFileSystem

      bake_folder "../../../public"
    end
  end
end
