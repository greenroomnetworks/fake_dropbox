require 'time'

module FakeDropbox
  module Utils
    def metadata(dropbox_path, list_contents = false)
      FakeDropbox::Entry.new(@dropbox_dir, dropbox_path).metadata(list_contents)
    end

    def save_revision(dropbox_path)
      FakeDropbox::Entry.new(@dropbox_dir, dropbox_path).save_revision
    end

    def safe_path(path)
      path.gsub(/(\.\.\/|\/\.\.)/, '')
    end

    def to_bool(value)
      return true if value == true || value =~ /(true|t|yes|y|1)$/i
      return false if value == false || value.nil? || value =~ /(false|f|no|n|0)$/i
      raise ArgumentError.new("Invalid value for Boolean: \"#{value}\"")
    end

    def full_path dropbox_path
      File.join(@dropbox_dir, dropbox_path)
    end

    def if_exists dropbox_path
      if File.exists?(full_path(dropbox_path))
        yield
      else
        content_type :json
        [404, {error: "Path '#{dropbox_path}' not found"}.to_json]
      end
    end

  end
end
