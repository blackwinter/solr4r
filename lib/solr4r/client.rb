# encoding: utf-8

#--
###############################################################################
#                                                                             #
# solr4r -- A Ruby client for Apache Solr                                     #
#                                                                             #
# Copyright (C) 2014 Jens Wille                                               #
#                                                                             #
# Mir is free software: you can redistribute it and/or modify it under the    #
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

  class Client

    include Logging

    DEFAULT_HOST = 'localhost'
    DEFAULT_PATH = 'solr'
    DEFAULT_PORT = 8983

    DEFAULT_PARAMS = {
      wt: :json
    }

    DEFAULT_BATCH_SIZE = 1000

    DEFAULT_ENDPOINTS = %w[select query spell suggest terms] <<
      ['ping', path: 'admin/ping', method: :head] <<
      ['dump', path: 'debug/dump']

    DEFAULT_SELECT_PATH = 'select'

    DEFAULT_UPDATE_PATH = 'update'

    SYSTEM_INFO_PATH = 'admin/info/system'

    MATCH_ALL_QUERY = '*:*'

    def initialize(options = {})
      uri, options = options, {} unless options.is_a?(Hash)

      self.options = options

      uri ||= options.fetch(:uri, default_uri)

      self.logger = options.fetch(:logger, default_logger)

      self.builder = options.fetch(:builder) { forward_logger(Builder.new) }
      self.request = options.fetch(:request) { forward_logger(Request.new(uri)) }

      self.default_params = options.fetch(:default_params, DEFAULT_PARAMS)

      register_endpoints(options.fetch(:endpoints, DEFAULT_ENDPOINTS))
    end

    attr_accessor :options, :builder, :request, :default_params

    def register_endpoints(endpoints)
      endpoints.each { |args| register_endpoint(*args) } if endpoints
      self
    end

    def register_endpoint(path, options = {})
      name, path = path, options.fetch(:path, path)

      if error = invalid_endpoint?(name.to_s)
        raise ArgumentError, "invalid endpoint: #{name} (#{error})"
      else
        define_singleton_method(name) { |_params = {}, _options = {}, &block|
          send_request(path, options.merge(_options.merge(
            params: options.fetch(:params, {}).merge(_params))), &block)
        }
      end

      self
    end

    def json(path, params = {}, options = {}, &block)
      get(path, params.merge(wt: :json), options, &block).result
    end

    def get(path, params = {}, options = {}, &block)
      send_request(path, options.merge(method: :get, params: params), &block)
    end

    def post(path, data = nil, options = {}, &block)
      send_request(path, options.merge(method: :post, data: data), &block)
    end

    def head(path, params = {}, options = {}, &block)
      send_request(path, options.merge(method: :head, params: params), &block)
    end

    def update(data, options = {}, path = DEFAULT_UPDATE_PATH, &block)
      options = amend_options(options, :headers, 'Content-Type' => 'text/xml')
      post(path, data, options, &block)
    end

    # See Builder#add.
    def add(doc, attributes = {}, options = {}, &block)
      update(builder.add(doc, attributes), options, &block)
    end

    def add_batch(docs, attributes = {}, options = {}, batch_size = DEFAULT_BATCH_SIZE, &block)
      failed = []

      docs.each_slice(batch_size) { |batch|
        unless add(batch, attributes, options, &block).success?
          failed.concat(batch_size == 1 ? batch : add_batch(
            batch, attributes, options, batch_size / 10, &block))
        end
      }

      failed
    end

    # See Builder#commit.
    def commit(attributes = {}, options = {}, &block)
      update(builder.commit(attributes), options, &block)
    end

    # See Builder#optimize.
    def optimize(attributes = {}, options = {}, &block)
      update(builder.optimize(attributes), options, &block)
    end

    # See Builder#rollback.
    def rollback(options = {}, &block)
      update(builder.rollback, options, &block)
    end

    # See Builder#delete.
    def delete(hash, options = {}, &block)
      update(builder.delete(hash), options, &block)
    end

    # See #delete.
    def delete_by_id(id, options = {}, &block)
      delete({ id: id }, options, &block)
    end

    # See #delete.
    def delete_by_query(query, options = {}, &block)
      delete({ query: query }, options, &block)
    end

    # See #delete_by_query.
    def delete_all!(options = {}, &block)
      delete_by_query(MATCH_ALL_QUERY, options, &block)
    end

    def count(params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)
      params = params.merge(rows: 0)
      params[:q] ||= MATCH_ALL_QUERY
      get(path, params, options, &block)
    end

    def json_query(params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)
      json(path, params.merge(q: query_string(params[:q])), options, &block)
    end

    def query_string(query)
      case query
        when nil
          # ignore
        when String
          query.gsub('&', '%26')
        when Array, Hash
          query.flat_map { |key, values|
            Array(values).map { |value|
              query_string("#{key}:#{value}")
            }
          }.join(' ')
        else
          query_string(query.to_s)
      end
    end

    def solr_version(type = :spec)
      json(SYSTEM_INFO_PATH) % "lucene/solr-#{type}-version"
    end

    def inspect
      '#<%s:0x%x @default_params=%p %s>' % [
        self.class, object_id, default_params, request.request_line
      ]
    end

    private

    def default_uri
      'http://%s:%d/%s' % [
        options.fetch(:host, DEFAULT_HOST),
        options.fetch(:port, DEFAULT_PORT),
        options.fetch(:path, DEFAULT_PATH)
      ]
    end

    def amend_options(options, key, value)
      options.merge(key => value.merge(options.fetch(key, {})))
    end

    def send_request(path, options, &block)
      request.execute(path,
        amend_options(options, :params, default_params), &block)
    end

    def invalid_endpoint?(name)
      'method already defined' if respond_to?(name) || (
        respond_to?(name, true) && !DEFAULT_ENDPOINTS.flatten.include?(name))
    end

  end

end
