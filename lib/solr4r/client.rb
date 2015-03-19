# encoding: utf-8

#--
###############################################################################
#                                                                             #
# solr4r -- A Ruby client for Apache Solr                                     #
#                                                                             #
# Copyright (C) 2014-2015 Jens Wille                                          #
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

require 'forwardable'

module Solr4R

  class Client

    include Logging

    extend Forwardable

    DEFAULT_URI = 'http://%s:%d/%s/%s'

    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 8983
    DEFAULT_PATH = 'solr'
    DEFAULT_CORE = 'collection1'

    DEFAULT_PARAMS = { wt: :json }

    class << self

      def default_uri(options = {})
        DEFAULT_URI % [
          options.fetch(:host, DEFAULT_HOST),
          options.fetch(:port, DEFAULT_PORT),
          options.fetch(:path, DEFAULT_PATH),
          options.fetch(:core, DEFAULT_CORE)
        ]
      end

      def query_string(query, escape = true)
        case query
          when nil
            # ignore
          when String
            escape(query, escape) unless query.empty?
          when Array
            if query.last.is_a?(Hash)
              lp, qs = query_from_hash((query = query.dup).pop, escape)
              query << qs if qs
            end

            query_with_params(lp, query_string(query.join(' '), escape))
          when Hash
            query_with_params(*query_from_hash(query, escape))
          else
            type_error(query)
        end
      end

      def local_params_string(local_params, hash = {}, escape = true)
        case local_params = expand_local_params(local_params, hash.dup)
          when nil
            # ignore
          when String
            escape("{!#{local_params}}", escape) unless local_params.empty?
          when Array
            local_params_string(local_params.join(' '), {}, escape)
          when Hash
            local_params_string(local_params.map { |key, value|
              "#{key}=#{value =~ /\s/ ? %Q{"#{value}"} : value}" }, {}, escape)
          else
            type_error(local_params)
        end
      end

      def escape(string, escape = true)
        escape ? string.gsub('&', '%26') : string
      end

      private

      def query_from_hash(query, escape)
        local_params = query.key?(lp = :_) &&
          local_params_string((query = query.dup).delete(lp), {}, escape)

        [local_params, query_string(query.flat_map { |key, values|
          Array(values).map { |value| "#{key}:#{value}" } }, escape)]
      end

      def query_with_params(local_params, query_string)
        local_params ? local_params + query_string : query_string
      end

      def expand_local_params(local_params, hash)
        case type = hash[:type]
          when nil
            local_params
          when String, Symbol
            type_error(local_params, Array) unless local_params.is_a?(Array)

            local_params.each { |param| hash[param] = "$#{type}.#{param}" }
            hash
          else
            type_error(type, %w[String Symbol])
        end
      end

      def type_error(obj, types = %w[String Array Hash])
        types = Array(types).join(' or ')
        raise TypeError, "#{types} expected, got #{obj.class}", caller(1)
      end

    end

    def initialize(options = {})
      uri, options = options, {} unless options.is_a?(Hash)

      self.options, self.default_params =
        options, options.fetch(:default_params, DEFAULT_PARAMS)

      self.logger  = options.fetch(:logger)  { default_logger }

      self.builder = options.fetch(:builder) { forward_logger(Builder.new) }

      self.request = options.fetch(:request) { forward_logger(Request.new(
        self, uri || options.fetch(:uri) { default_uri })) }

      self.endpoints = forward_logger(Endpoints.new(self))
    end

    attr_accessor :options, :builder, :request, :default_params, :endpoints

    alias_method :ep, :endpoints

    def_delegators 'self.class', :query_string, :local_params_string, :escape

    def json(path,
        params = {}, options = {}, &block)

      get(path, params.merge(wt: :json), options, &block).result
    end

    def get(path,
        params = {}, options = {}, &block)

      send_request(path, options.merge(
        method: :get, params: params), &block)
    end

    def post(path, data = nil,
        params = {}, options = {}, &block)

      send_request(path, options.merge(
        method: :post, params: params, data: data), &block)
    end

    def head(path,
        params = {}, options = {}, &block)

      send_request(path, options.merge(
        method: :head, params: params), &block)
    end

    def inspect
      '#<%s:0x%x @default_params=%p %s>' % [
        self.class, object_id, default_params, request.request_line
      ]
    end

    private

    def default_uri
      self.class.default_uri(options)
    end

    def amend_options_hash(options, key, value)
      options.merge(key => value.merge(options.fetch(key, {})))
    end

    def amend_options_array(options, key, *value)
      options.merge(key => Array(options[key]) + value)
    end

    def send_request(path, options, &block)
      request.execute(path, amend_options_hash(
        options, :params, default_params), &block)
    end

  end

end

require_relative 'client/update'
require_relative 'client/query'
require_relative 'client/admin'
