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

    def_delegators :response, :to_i
    def_delegators :to_hash,  :%, :deep_fetch

    def initialize(response, hash)
      @response, @hash = response, hash.extend(Nuggets::Hash::DeepFetchMixin)
      extend(Error) if hash.key?('error')
    end

    attr_reader :response

    def to_hash
      @hash
    end

    def each
      return enum_for(:each) unless block_given?

      deep_fetch('response/docs').each { |hash|
        yield Document.new(self, hash)
      }
    end

    def error?
      is_a?(Error)
    end

    module Error

      def to_i
        0
      end

      def each
        []
      end

    end

  end

end
