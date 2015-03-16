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

module Solr4R

  class Document

    extend Forwardable

    def initialize(result, hash)
      @result, @hash = result, hash
    end

    attr_reader :result

    def_delegators :result, :client

    def_delegators :to_hash, :[], :each, :fetch, :to_json

    def to_hash
      @hash
    end

    def id
      fetch('id')
    end

    def more_like_this_h(*args, &block)
      client.more_like_this_h(id, *args, &block)
    end

    def more_like_this_q(*args, &block)
      client.more_like_this_q(id, *args, &block)
    end

    alias_method :more_like_this, :more_like_this_q

  end

end
