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

module Solr4R

  class Client

    DEFAULT_PING_PATH             = 'admin/ping'
    DEFAULT_CORES_PATH            = '../admin/cores'
    DEFAULT_FIELDS_PATH           = 'schema/fields'
    DEFAULT_SYSTEM_PATH           = '../admin/info/system'
    DEFAULT_ANALYZE_DOCUMENT_PATH = 'analysis/document'
    DEFAULT_ANALYZE_FIELD_PATH    = 'analysis/field'

    module Admin

      def solr_version(type = :spec,
          params = {}, options = {}, path = DEFAULT_SYSTEM_PATH, &block)

        json(path, params, options, &block) % "lucene/solr-#{type}-version"
      end

      def ping(
          params = {}, options = {}, path = DEFAULT_PING_PATH, &block)

        json(path, params, options, &block) % 'status'
      end

      def cores(
          params = {}, options = {}, path = DEFAULT_CORES_PATH, &block)

        json(path, params, options, &block) % 'status'
      end

      def fields(
          params = {}, options = {}, path = DEFAULT_FIELDS_PATH, &block)

        json(path, params, options, &block) % 'fields'
      end

      def analyze_document(doc,
          params = {}, options = {}, path = DEFAULT_ANALYZE_DOCUMENT_PATH, &block)

        doc = builder.doc(doc) unless doc.is_a?(String)
        update(doc, amend_options_hash(
          options, :params, wt: :json), path, &block).result % 'analysis'
      end

      def analyze_field(analysis,
          params = {}, options = {}, path = DEFAULT_ANALYZE_FIELD_PATH, &block)

        json(path, params.merge(analysis: analysis), options, &block) % 'analysis'
      end

    end

    include Admin

  end

end
