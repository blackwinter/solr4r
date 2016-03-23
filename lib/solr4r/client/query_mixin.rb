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

    MATCH_ALL_QUERY = '*:*'

    DEFAULT_SELECT_PATH = 'select'
    DEFAULT_SPELL_PATH  = 'spell'
    DEFAULT_MLT_PATH    = 'mlt'

    MLT_DEFAULT_FL   = '*,score'
    MLT_DEFAULT_ROWS = 5
    MLT_LOCAL_PARAMS = local_params_string(%w[
      boost
      maxdf
      maxntp
      maxqt
      maxwl
      mindf
      mintf
      minwl
    ], type: :mlt, qf: '$mlt.fl')

    module QueryMixin

      def count(
          params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)

        params = params.merge(rows: 0)
        params[:q] ||= MATCH_ALL_QUERY

        get(path, params, options, &block)
      end

      def json_query(
          params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)

        json(path, params.merge(q: query_string(params[:q]), fq: Array(
          params[:fq]).map(&method(:query_string))), options, &block)
      end

      def json_document(id,
          params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)

        json_query(params.merge(q: { id: id }), options, path, &block).first
      end

      def more_like_this_h(id, fields,
          params = {}, options = {}, path = DEFAULT_MLT_PATH, &block)

        _more_like_this_query({ id: id },
          fields, params, options, path, &block)
      end

      def more_like_this_q(id, fields,
          params = {}, options = {}, path = DEFAULT_SELECT_PATH, &block)

        _more_like_this_query(MLT_LOCAL_PARAMS + id,
          fields, params, options, path, &block)
      end

      alias_method :more_like_this, :more_like_this_q

      private

      def _more_like_this_query(query, fields, params, *args, &block)
        json_query(params.merge('mlt.fl' => Array(fields).join(','),
          q:    query,
          fl:   params.fetch(:fl,   MLT_DEFAULT_FL),
          rows: params.fetch(:rows, MLT_DEFAULT_ROWS)), *args, &block)
      end

    end

    include QueryMixin

  end

end
