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

require 'json'
require 'ostruct'
require 'webrick'

module Solr4R

  class Response

    CHARSET_RE = %r{;\s*charset=([\w-]+)}

    REQUEST_LINE = %r{\AHTTP/.*\r?\n?}

    DEFAULT_CHARSET = 'UTF-8'

    ATTRIBUTES = {
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

    def initialize(request)
      ATTRIBUTES.each { |attribute, key|
        send("#{key}=", request.send(attribute))
      }
    end

    attr_accessor *ATTRIBUTES.values

    def result(options = {})
      @result ||= evaluate_result(options)
    end

    def response_headers
      @response_headers ||= evaluate_header
    end

    def num_found
      @num_found ||= evaluate_count('numFound')
    end

    def charset
      @charset ||= response_headers.fetch('content-type')[0][CHARSET_RE, 1]
    end

    def to_s
      @to_s ||= response_body.to_s.force_encoding(charset || DEFAULT_CHARSET)
    end

    def inspect
      '#<%s:0x%x @request_url=%p, @request_headers=%p, @response_headers=%p, @response_code=%p>' % [
        self.class, object_id, request_url, request_headers, response_headers, response_code
      ]
    end

    private

    def evaluate_result(options)
      case wt = request_params[:wt]
        when String then to_s
        when :ruby  then eval(to_s)
        when :json  then JSON.parse(to_s, options)
        else raise 'The response cannot be evaluated: wt=%p not supported.' % wt
      end
    end

    def evaluate_header
      WEBrick::HTTPUtils.parse_header(response_header.sub(REQUEST_LINE, ''))
    end

    def evaluate_count(name)
      case wt = request_params[:wt]
        # numFound="35"
        when 'xml'        then Integer(result[/\s#{name}="(\d+)"/, 1])
        # 'numFound'=>35
        when 'ruby'       then Integer(result[/'#{name}'=>(\d+)/, 1])
        # "numFound":35
        when 'json'       then Integer(result[/"#{name}":(\d+)/, 1])
        # { 'response' => 'numFound' } OR { :response => :numFound }
        when :ruby, :json then result.fetch(key = 'response') {
          name = name.to_sym; result.fetch(key.to_sym) }.fetch(name)
        else raise 'The count cannot be extracted: wt=%p not supported.' % wt
      end
    end

  end

end
