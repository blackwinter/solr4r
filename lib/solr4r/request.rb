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

require 'net/https'

require_relative 'request_extension'
require_relative 'uri_extension'

module Solr4R

  class Request

    DEFAULT_METHOD = :get

    DEFAULT_USER_AGENT = "Solr4R/#{VERSION}"

    def initialize(base_uri, http_options = {})
      self.base_uri, self.http_options =
        URI(base_uri).extend(BaseUriExtension), http_options
    end

    def start
      self.http = Net::HTTP.start(base_uri.hostname, base_uri.port,
        { use_ssl: base_uri.scheme == 'https' }.merge(http_options))

      self
    end

    def finish
      http.finish if started?
      self
    end

    def started?
      http && http.started?
    end

    def execute(path, options = {}, &block)
      start unless started?

      self.last_response = nil

      req = prepare_request(path, options, &block)
      res = http.request(req)

      self.last_response = Response.new(
        request_body:     req.body,
        request_headers:  req.to_hash,
        request_method:   req.method.downcase.to_sym,
        request_params:   req.params,
        request_url:      req.uri.to_s,

        response_body:    res.body,
        response_charset: res.type_params['charset'],
        response_code:    res.code.to_i,
        response_headers: res.to_hash
      )
    end

    def request_line
      last_response ? last_response.request_line : "[#{base_uri}]"
    end

    def inspect
      '#<%s:0x%x %s>' % [self.class, object_id, request_line]
    end

    private

    attr_accessor :base_uri, :http_options, :http, :last_response

    def prepare_request(path, options)
      uri = make_uri(path, options.fetch(:params, {}))

      req = make_request(uri,
        options.fetch(:method, DEFAULT_METHOD),
        options.fetch(:data, {}))

      set_headers(req, options.fetch(:headers, {}))

      yield req if block_given?

      req
    end

    def make_uri(path, params)
      base_uri.merge(path).extend(RequestUriExtension).with_params(params)
    end

    def make_request(uri, method, data)
      case method
        when :get, :head
          req = request_for(method, uri)
        when :post
          req = request_for(method, uri)
          set_data(req, data)
        else
          raise ArgumentError, "method not supported: #{method}"
      end

      req
    end

    def request_for(method, uri)
      Net::HTTP.const_get(method.to_s.capitalize)
        .extend(HTTPRequestExtension).from_uri(uri)
    end

    def set_headers(req, headers)
      req['User-Agent'] = DEFAULT_USER_AGENT

      headers.each { |key, value|
        Array(value).each { |val| req.add_field(key, val) }
      }
    end

    def set_data(req, data)
      data.is_a?(String) ? req.body = data : req.form_data = data
    end

  end

end
