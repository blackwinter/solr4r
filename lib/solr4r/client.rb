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
          options.fetch(:collection) {
          options.fetch(:core, DEFAULT_CORE) }
        ]
      end

      def escape(*args)
        Query.escape(*args)
      end

      def query_string(*args)
        Query.new(*args).to_s
      end

      def local_params_string(*args)
        Query::LocalParams.new(*args).to_s
      end

    end

    def initialize(options = {})
      uri, options = options, {} unless options.is_a?(Hash)

      self.options, self.default_params =
        options, options.fetch(:default_params, DEFAULT_PARAMS)

      self.logger  = options.fetch(:logger)  { default_logger }

      self.builder = options.fetch(:builder) { forward_logger(
        Builder.new(self)) }

      self.request = options.fetch(:request) { forward_logger(
        Request.new(self, uri || options.fetch(:uri) { default_uri })) }

      self.endpoints = forward_logger(
        Endpoints.new(self))
    end

    attr_accessor :options, :builder, :request, :default_params, :endpoints

    alias_method :ep, :endpoints

    def_delegators 'self.class', :query_string, :local_params_string, :escape

    def_delegators :request, :request_line, :execute

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
        self.class, object_id, default_params, request_line
      ]
    end

    private

    def default_uri
      self.class.default_uri(options)
    end

    def send_request(path, options, &block)
      execute(path, amend_options_hash(
        options, :params, default_params), &block)
    end

    def amend_options_hash(options, key, value)
      options.merge(key => value.merge(options.fetch(key, {})))
    end

  end

end

require_relative 'client/update_mixin'
require_relative 'client/query_mixin'
require_relative 'client/admin_mixin'
