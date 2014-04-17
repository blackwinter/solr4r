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

require 'cgi'

module Solr4R

  module BaseUriExtension

    def self.extended(uri)
      uri.path << '/' unless uri.path.end_with?('/')
    end

  end

  module RequestUriExtension

    attr_accessor :params

    def with_params(params)
      self.params, query = params, [self.query].compact

      params.each { |key, value|
        key = URI.escape(key.to_s)
        Array(value).each { |val| query << "#{key}=#{CGI.escape(val.to_s)}" }
      }

      self.query = query.join('&') unless query.empty?

      self
    end

  end

end
