class Chef
  module Mixin
    module OpenDKIMHelpers
      def opendkim_postfix_milter_address
        if node.attribute?('opendkim') && node['opendkim'].attribute?('socket')
          opendkim_socket = node['opendkim']['socket']

          protocol, socket = opendkim_socket.split(/:/)
          protocol.gsub!(/local/, 'unix')
          protocol.gsub!(/inet[6]?/, 'inet')

          listen = case protocol
                   when 'inet'
                     port, addr = socket.split(/@/)
                     addr ||= 'localhost'

                     "#{protocol}:#{addr}:#{port}"
                   when 'unix'
                     "#{protocol}:#{socket}"
                   end

          listen
        else
          nil
        end
      end
    end
  end
end
