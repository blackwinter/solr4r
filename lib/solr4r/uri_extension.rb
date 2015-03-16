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

      params.each { |key, value| query_pairs(key, value).each { |k, v|
        query << "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
      } }

      self.query = query.join('&') unless query.empty?

      self
    end

    private

    def query_pairs(key, value, pairs = [])
      if value.is_a?(Hash)
        kv = value.fetch(vk = :_, true)
        pairs << [key, kv] unless kv.nil?

        value.each { |sub, val|
          query_pairs("#{key}.#{sub}", val, pairs) unless sub == vk }
      else
        Array(value).each { |val| pairs << [key, val] unless val.nil? }
      end

      pairs
    end

  end

end
