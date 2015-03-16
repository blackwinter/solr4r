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
require 'nuggets/hash/deep_fetch_mixin'
require 'nuggets/string/camelscore_mixin'

require_relative 'document'

module Solr4R

  class Result

    include Enumerable

    extend Forwardable

    def self.types_for(hash, mix = Nuggets::String::CamelscoreMixin)
      constants.map { |const|
        if hash.key?(const.to_s.extend(mix).underscore!)
          mod = const_get(const)
          mod if mod.is_a?(Module)
        end
      }.compact
    end

    def initialize(response, hash)
      types = self.class.types_for(hash); extend(*types) unless types.empty?
      @response, @hash = response, hash.extend(Nuggets::Hash::DeepFetchMixin)
    end

    attr_reader :response

    def_delegators :response, :client

    def_delegators :to_hash, :%, :deep_fetch, :fetch

    def to_hash
      @hash
    end

    def to_i
      0
    end

    def each(&block)
      block ? _each(&block) : enum_for(__method__)
    end

    def empty?
      to_i.zero?
    end

    def error?
      is_a?(Error)
    end

    private

    def _each
      []
    end

    module Error
    end

    module Response

      def to_i
        response.to_i
      end

      private

      def _each
        deep_fetch('response/docs').each { |hash|
          yield Document.new(self, hash)
        }
      end

    end

    module Terms

      def to_i
        fetch('terms').size
      end

      private

      def _each
        fetch('terms').each { |key, value|
          yield key, Hash[*value]
        }
      end

    end

    module FacetCounts

      def facet_counts
        fetch(__method__.to_s)
      end

      def facet_fields
        return enum_for(__method__) unless block_given?

        facet_counts.fetch(__method__.to_s).each { |key, value|
          yield key, Hash[*value]
        }
      end

      def facet_ranges
        return enum_for(__method__) unless block_given?

        facet_counts.fetch(__method__.to_s).each { |key, value|
          yield key, value.merge('counts' => Hash[*value['counts']])
        }
      end

    end

  end

end
