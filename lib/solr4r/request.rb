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

require 'curl'

module Solr4R

  class Request < Curl::Easy

    DEFAULT_VERB = :get

    DEFAULT_USER_AGENT = "Solr4R/#{VERSION}"

    RESPONSE_ATTRIBUTES = {
      # request
      headers:            :request_headers,
      last_effective_url: :request_url,
      post_body:          :post_body,
      params:             :request_params,
      verb:               :request_verb,

      # response
      body_str:           :response_body,
      content_type:       :content_type,
      header_str:         :response_header,
      response_code:      :response_code
    }

    def initialize(options = {})
      if block_given?
        raise ArgumentError,
          'block argument not supported, use options hash instead'
      end

      super()

      self.options = options.merge(params: nil, verb: nil)
      set_options
    end

    attr_accessor :options, :params, :verb

    def execute(request_url, options = {}, &block)
      prepare_request(request_url, options, &block)

      send("http_#{verb}")

      Response.new { |response|
        RESPONSE_ATTRIBUTES.each { |attribute, key|
          response.send("#{key}=", send(attribute))
        }
      }
    end

    def reset
      super.tap {
        set_options
        headers['User-Agent'] ||= DEFAULT_USER_AGENT
      }
    end

    def inspect
      '#<%s:0x%x @options=%p, @verb=%p, @url=%p, @response_code=%p>' % [
        self.class, object_id, options, verb, url, response_code
      ]
    end

    private

    def set_options
      options.each { |key, value| send("#{key}=", value) }
    end

    def prepare_request(request_url, options)
      reset

      self.url = Curl.urlalize(request_url.to_s,
        self.params = options.fetch(:params, {}))

      case self.verb = options.fetch(:method, DEFAULT_VERB)
        when :get, :head
          # ok
        when :post, :delete, :patch
          self.post_body = Curl.postalize(options[:data])
        when :put
          self.put_data = Curl.postalize(options[:data])
        else
          raise ArgumentError, "verb not supported: #{verb}"
      end

      headers.update(options[:headers]) if options[:headers]

      yield self if block_given?

      self
    end

  end

end
