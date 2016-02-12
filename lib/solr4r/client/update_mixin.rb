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

  class Client

    DEFAULT_BATCH_SIZE = 1000

    DEFAULT_UPDATE_TYPE = 'text/xml'

    DEFAULT_UPDATE_PATH = 'update'

    module UpdateMixin

      def update(data,
          params = {}, options = {},
          path = DEFAULT_UPDATE_PATH,
          type = DEFAULT_UPDATE_TYPE, &block)

        post(path, data, params, amend_options_hash(
          options, :headers, 'Content-Type' => type), &block)
      end

      # See Builder#add.
      def add(doc, attributes = {},
          params = {}, options = {}, &block)

        update(builder.add(doc, attributes), params, options, &block)
      end

      def add_batch(docs, attributes = {},
          params = {}, options = {}, batch_size = DEFAULT_BATCH_SIZE, &block)

        failed = []

        docs.each_slice(batch_size) { |batch|
          add(batch, attributes, params, options, &block).success? ||
            failed.concat(batch_size == 1 ? batch : add_batch(batch,
              attributes, params, options, batch_size / 10, &block))
        }

        failed
      end

      # See Builder#commit.
      def commit(attributes = {},
          params = {}, options = {}, &block)

        update(builder.commit(attributes), params, options, &block)
      end

      # See Builder#optimize.
      def optimize(attributes = {},
          params = {}, options = {}, &block)

        update(builder.optimize(attributes), params, options, &block)
      end

      # See Builder#rollback.
      def rollback(
          params = {}, options = {}, &block)

        update(builder.rollback, params, options, &block)
      end

      # See Builder#delete.
      def delete(hash,
          params = {}, options = {}, &block)

        update(builder.delete(hash), params, options, &block)
      end

      # See #delete.
      def delete_id(id,
          params = {}, options = {}, &block)

        delete({ id: id }, params, options, &block)
      end

      # See #delete.
      def delete_query(query,
          params = {}, options = {}, &block)

        delete({ query: query }, params, options, &block)
      end

      # See #delete_query.
      def delete_all(
          params = {}, options = {}, &block)

        delete_query(MATCH_ALL_QUERY, params, options, &block)
      end

      alias_method :clear, :delete_all

    end

    include UpdateMixin

  end

end
