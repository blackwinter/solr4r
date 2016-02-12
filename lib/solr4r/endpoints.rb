# encoding: utf-8

#--
###############################################################################
#                                                                             #
# solr4r -- A Ruby client for Apache Solr                                     #
#                                                                             #
# Copyright (C) 2014-2016 Jens Wille                                          #
#                                                                             #
# solr4r is free software: you can redistribute it and/or modify it under the #
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation, either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# solr4r is distributed in the hope that it will be useful, but WITHOUT ANY   #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with solr4r. If not, see <http://www.gnu.org/licenses/>.              #
#                                                                             #
###############################################################################
#++

module Solr4R

  class Endpoints

    include Logging

    DEFAULT_ENDPOINTS = %w[select query export spell suggest terms debug/dump]

    def initialize(client, options = client.options)
      @client, @endpoints = client, []
      register(options.fetch(:endpoints, DEFAULT_ENDPOINTS))
    end

    attr_reader :client

    def register(path, options = {})
      case path
        when nil
          # ignore
        when Symbol
          register(path.to_s, options)
        when Array
          path.each { |args| register(*args) }
        when Hash
          path.each { |_path, _options| register(_path,
            _options.is_a?(Hash) ? _options : { path: _options }) }
        when String
          name, path = File.basename(path), options.fetch(:path, path).to_s

          error = invalid_endpoint?(name) and
            raise ArgumentError, "invalid endpoint: #{name} (#{error})"

          @endpoints << [name, path]

          define_singleton_method(name) { |_params = {}, _options = {}, &block|
            client.send(:send_request, path, options.merge(_options.merge(
              params: options.fetch(:params, {}).merge(_params))), &block)
          }
        else
          raise TypeError, "unexpected type #{path.class}"
      end

      self
    end

    def inspect
      '#<%s:0x%x [%s]>' % [self.class, object_id,
        @endpoints.map { |ep| ep.uniq.join('=') }.join(', ')]
    end

    private

    def invalid_endpoint?(name)
      'method already defined' if respond_to?(name) || (
        respond_to?(name, true) &&
          DEFAULT_ENDPOINTS.all? { |ep,| ep.to_s != name })
    end

  end

end
