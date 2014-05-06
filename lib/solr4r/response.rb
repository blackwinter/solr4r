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
require 'nuggets/hash/deep_fetch_mixin'

module Solr4R

  class Response

    DEFAULT_CHARSET = 'UTF-8'

    EVALUATE_METHODS = [:get, :post]

    def initialize(options)
      options.each { |key, value| send("#{key}=", value) }
      @evaluate = EVALUATE_METHODS.include?(request_method)
    end

    attr_accessor :response_body, :response_charset, :response_code, :response_headers,
      :request_body, :request_method, :request_params, :request_url, :request_headers

    def request_line
      '"%s %s" %d' % [request_method.upcase, request_url, response_code]
    end

    def result
      @result ||= evaluate_result if @evaluate
    end

    def num_found
      @num_found ||= evaluate_count('numFound') if @evaluate
    end

    alias_method :to_i, :num_found

    def to_s
      @to_s ||= response_body.to_s.force_encoding(response_charset || DEFAULT_CHARSET)
    end

    def inspect
      '#<%s:0x%x @request_url=%p, @request_headers=%p, @response_headers=%p, @response_code=%p>' % [
        self.class, object_id, request_url, request_headers, response_headers, response_code
      ]
    end

    private

    def evaluate_result
      case wt = request_params[:wt]
        when String then to_s
        when :ruby  then extend_hash(eval(to_s))
        when :json  then extend_hash(JSON.parse(to_s))
        else raise 'The response cannot be evaluated: wt=%p not supported.' % wt
      end
    end

    def evaluate_count(name)
      case wt = request_params[:wt]
        when 'xml'  then extract_int(name, '\s%s="%s"')  #  numFound="35"
        when 'ruby' then extract_int(name, "'%s'=>%s")   # 'numFound'=>35
        when 'json' then extract_int(name, '"%s":%s')    # "numFound":35
        when Symbol then result % ['response', name]     # {"response"=>{"numFound"=>35}}
        else raise 'The count cannot be extracted: wt=%p not supported.' % wt
      end
    end

    def extract_int(name, pattern)
      Integer(result[Regexp.new(pattern % [name, '(\d+)']), 1])
    end

    def extend_hash(object)
      object.is_a?(Hash) ? object.extend(Nuggets::Hash::DeepFetchMixin) : object
    end

  end

end
