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

  class Batch

    STEP = 10

    DEFAULT_SIZE = STEP ** 3

    def initialize(client, attributes = {},
        params = {}, options = {}, size = DEFAULT_SIZE, &block)
      @client, @args, @size, @block =
        client, [attributes, params, options], size, block

      reset
    end

    attr_reader :client

    attr_accessor :size

    def reset
      @batch, @failed = [], []
    end

    def clear
      @batch.clear
    end

    def add(*docs)
      batch(docs)
    end

    alias_method :<<, :add

    def batch(docs)
      flush unless @batch.concat(docs).size < size
    end

    def flush
      process
      clear
      @failed
    end

    def inspect
      '#<%s:0x%x @size=%p, @count=%p, @failed=%p>' % [
        self.class, object_id, size, @batch.size, @failed.size
      ]
    end

    private

    def process(docs = @batch, size = size())
      next_size = size.fdiv(STEP).ceil

      docs.each_slice(size) { |batch|
        client.add(batch, *@args, &@block).success? ? nil :
          size > 1 ? process(batch, next_size) : @failed.concat(batch)
      }
    end

  end

end
