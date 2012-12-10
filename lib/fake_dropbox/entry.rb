require 'time'
require 'mime/types'
require 'hashie'

module FakeDropbox

  # todo:
  # * extract dropbox_root into a proper "Dropbox Filesystem" object
  # * don't use class vars
  # * handle deletions
  #
  class Entry
    # directory on disk containing our fake dropbox
    attr_reader :dropbox_root

    # path relative to dropbox root
    attr_reader :dropbox_path

    def initialize(dropbox_root, dropbox_path)
      @dropbox_root = dropbox_root
      @dropbox_path = dropbox_path
    end

    def full_path
      File.join(dropbox_root, dropbox_path)
    end

    def directory?
      File.directory?(full_path)
    end

    def metadata(list_contents = false)
      hash = live_metadata.dup
      if directory? and list_contents
        children = Dir.entries(full_path).reject { |x| ['.', '..'].include? x }
        hash[:contents] = children.map do |child_path|
          Entry.new(dropbox_root, File.join(dropbox_path, child_path)).metadata
        end
      end
      hash
    end

    # Gets (or creates) metadata for this path, and returns a pointer to the
    # live hash inside our storage. This allows clever clients to change
    # metadata field values.
    def live_metadata
      metadatas[full_path] ||= build_metadata
    end

    def save_revision
      metadatas[full_path] = build_metadata
    end

    def metadatas
      # todo: don't use class vars -- we need it because Sinatra loses instance data between requests
      @@metadatas ||= {}
    end

    def build_metadata
      raise Errno::ENOENT, full_path unless File.exists?(full_path)

      bytes = directory? ? 0 : File.size(full_path)

      metadata = Hashie::Mash.new({
        thumb_exists: false,
        bytes: bytes,
        modified: File.mtime(full_path).rfc822,
        path: File.join('/', dropbox_path),
        is_dir: directory?,
        size: "#{bytes} bytes",
        icon: "page_white",
        root: "dropbox"
      })

      if directory?
        metadata[:icon] = "folder"
      else
        mime_type = MIME::Types.type_for(File.extname(dropbox_path)).first.to_s
        metadata[:mime_type] = mime_type
        is_image = mime_type.split('/').first == "image"
        if is_image
          metadata[:thumb_exists] = true
          metadata[:icon] = "page_white_picture"
        elsif mime_type == "application/pdf"
          metadata[:icon] = "page_white_acrobat"
          # todo: other file type to icon mappings
        end
        metadata[:rev] = rand(100000000).to_s(16)
      end

      metadata
    end
  end
end
