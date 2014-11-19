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

require 'logger'
require 'nuggets/module/lazy_attr'

module Solr4R

  module Logging

    DEFAULT_LOG_DEVICE = $stderr
    DEFAULT_LOG_LEVEL  = Logger::WARN
    DEFAULT_LOG_NAME   = "Solr4R/#{VERSION}"

    NULL_LOGGER = Logger.new(nil)

    class << self

      def set_log_level(logger, level = nil, default_level = nil)
        level ||= begin
          value = ENV.fetch('SOLR4R_LOG_LEVEL', '')
          value.empty? ? default_level || DEFAULT_LOG_LEVEL : value
        end

        logger.level = level.respond_to?(:upcase) ?
          Logger.const_get(level.upcase) : level
      end

    end

    lazy_accessor(:logger) { NULL_LOGGER }

    def default_logger(options = options(), mod = self.class)
      logger = Logger.new(options.fetch(:log_device, mod::DEFAULT_LOG_DEVICE))
      logger.progname = options.fetch(:log_name, mod::DEFAULT_LOG_NAME)

      Logging.set_log_level(logger, options[:log_level], mod::DEFAULT_LOG_LEVEL)

      logger
    end

    def forward_logger(object)
      object.logger = logger
      object
    end

  end

end
