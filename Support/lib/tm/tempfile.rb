module TextMate
  module IO
    class << self
      # Allows use with a block or without.
      # 
      # Block usage:
      # 
      # Requires a file ext and takes an optional leading name string.
      #
      #     TextMate::IO.tempfile('diff', 'foo') { |file|
      #       file.write(diff)
      #       `mate -w #{e_sh(file.path)}`
      #     }
      #
      # Note: If you want to use mate to open the result you will need
      # to use the -w option.
      # 
      # Standalone usage:
      # 
      # Returns the open file as a file handle, the file will be
      # unlinked when the script exits.
      # 
      #   file = TextMate::IO.tempfile('diff', 'foo')
      # 
      def tempfile(ext, name=nil)
        require 'tmpdir'

        begin
          file = File.new(
            '%s/%s_%s.%s' % [Dir::tmpdir, name || 'untitled', rand(1679615).to_s(36), ext],
            File::RDWR|File::CREAT|File::EXCL, 0600
          )
          
          file.sync = true
          
          if block_given?
            res = yield(file)

            file.close
            File.unlink(file.path)
            
            return res
          else
            at_exit {
              file.close
              File.unlink(file.path)              
            }
            return file
          end
        rescue Errno::EEXIST
          retry
        end
      end
    end
  end
end
