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

  class Query

    class << self

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
          (values.respond_to?(:to_ary) ? values : [values])
            .map { |value| "#{key}:#{value}" } }, escape)]
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

    def initialize(*args)
      @args = args
    end

    def to_s
      self.class.query_string(*@args)
    end

    class LocalParams

      def initialize(*args)
        @args = args
      end

      def to_s
        Query.local_params_string(*@args)
      end

    end

  end

end
