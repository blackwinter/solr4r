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

require 'time'

module Solr4R

  class Query

    LOCAL_PARAMS_KEY = :_

    class << self

      def query_string(*args)
        new(*args).to_s
      end

      def local_params_string(*args)
        new.local_params_string(*args)
      end

      def escape(string, escape = true)
        escape ? string.gsub('&', '%26') : string
      end

      def quote(string, quote = string =~ /\s/)
        quote ? %Q{"#{string}"} : string
      end

      def convert_value(value, escape = true)
        case value
          when DateTime
            convert_value(value.to_time, escape)
          when Time
            value.getutc.xmlschema.tap { |val|
              val.gsub!(/:/, '\\\\\&') if escape }
          when Range
            "[#{[value.begin, value.end].map { |val|
              convert_value(val, false) }.join(' TO ')}]"
          else
            value.to_s
        end
      end

    end

    def initialize(query = '', escape = true)
      @query, @escape = query, escape
    end

    attr_reader :query

    attr_writer :escape

    def escape?
      @escape
    end

    def escape(string, escape = escape?)
      self.class.escape(string, escape)
    end

    def quote(*args)
      self.class.quote(*args)
    end

    def convert_value(*args)
      self.class.convert_value(*args)
    end

    def to_s(escape = escape?)
      query_string(query, escape)
    end

    def query_string(query = query(), escape = escape?)
      case query
        when nil
          # ignore
        when String
          escape(query, escape) unless query.empty?
        when Array
          if query.last.is_a?(Hash)
            query = query.dup

            local_params, query_string = query_from_hash(query.pop, escape)
            query << query_string if query_string
          end

          query_with_params(local_params, query_from_array(query, escape))
        when Hash
          query_with_params(*query_from_hash(query, escape))
        else
          type_error(query)
      end
    end

    def local_params_string(local_params, hash = {}, escape = escape?)
      case local_params = expand_local_params(local_params, hash)
        when nil
          # ignore
        when String
          escape("{!#{local_params}}", escape) unless local_params.empty?
        when Array
          local_params_string(local_params.join(' '), {}, escape)
        when Hash
          local_params_string(local_params.map { |key, value|
            "#{key}=#{quote(value)}" }, {}, escape)
        else
          type_error(local_params)
      end
    end

    private

    def query_from_array(query, escape)
      query_string(query.map { |value|
        convert_value(value) }.join(' '), escape)
    end

    def query_from_hash(query, escape)
      if query.key?(LOCAL_PARAMS_KEY)
        query = query.dup

        local_params = local_params_string(
          query.delete(LOCAL_PARAMS_KEY), {}, escape)
      end

      query = query.flat_map { |key, values|
        block = lambda { |value| "#{key}:#{convert_value(value)}" }
        values.respond_to?(:to_ary) ? values.map(&block) : block[values] }

      [local_params, query_string(query, escape)]
    end

    def query_with_params(local_params, query_string)
      local_params ? local_params + query_string : query_string
    end

    def expand_local_params(local_params, hash)
      case type = hash[:type]
        when nil
          local_params
        when String, Symbol
          type_error(local_params) unless local_params.is_a?(Array)

          hash = hash.dup
          local_params.each { |param| hash[param] = "$#{type}.#{param}" }
          hash
        else
          type_error(type)
      end
    end

    def type_error(obj)
      raise TypeError, "unexpected type #{obj.class}", caller(1)
    end

  end

end
