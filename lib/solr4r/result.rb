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

require 'forwardable'
require 'nuggets/hash/deep_fetch_mixin'

require_relative 'document'

module Solr4R

  class Result

    include Enumerable

    extend Forwardable
    def_delegators :to_hash, :fetch, :deep_fetch, :%

    def self.type_for(hash)
      constants.find { |const|
        if hash.key?(const.to_s.downcase)
          mod = const_get(const)
          return mod if mod.is_a?(Module)
        end
      }

      raise TypeError, "could not find supported type: #{hash.keys.join(', ')}"
    end

    def initialize(response, hash)
      extend(self.class.type_for(hash))
      @response, @hash = response, hash.extend(Nuggets::Hash::DeepFetchMixin)
    end

    attr_reader :response

    def to_hash
      @hash
    end

    def to_i
      0
    end

    def each(&block)
      block ? _each(&block) : enum_for(:each)
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

  end

end
