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

require 'nokogiri'
require 'time'

module Solr4R

  class Builder < Nokogiri::XML::Builder

    include Logging

    class Document < Nokogiri::XML::Document

      def document
        self
      end

    end

    DEFAULT_OPTIONS = { encoding: 'UTF-8' }

    ILLEGAL_CHAR_RE = /[\x00-\x08\x0B\x0C\x0E-\x1F]/

    class << self

      def convert_value(value)
        case value
          when Time     then value.getutc.xmlschema
          when DateTime then convert_value(value.to_time)
          when Date     then convert_value(value.to_datetime)
          else               value
        end
      end

    end

    def initialize(client = Client, options = nil)
      raise ArgumentError,
        'block argument not supported, use options hash instead' if block_given?

      @client = client

      @solr4r_doc = doc = Document.new
      @solr4r_opt = opt = DEFAULT_OPTIONS.dup

      options ||= client.respond_to?(:options) ? client.options : {}
      options.each { |k, v| opt[k.to_sym] = v if doc.respond_to?("#{k}=") }

      super(@solr4r_opt, @solr4r_doc)
    end

    attr_reader :client

    # See Schema[https://wiki.apache.org/solr/UpdateXmlMessages#add.2Freplace_documents].
    #
    # ==== Examples:
    #
    # ===== Single document
    #
    #   add(employeeId: '05991', office: 'Bridgewater', skills: %w[Perl Java])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add>
    #     <doc>
    #       <field name="employeeId">05991</field>
    #       <field name="office">Bridgewater</field>
    #       <field name="skills">Perl</field>
    #       <field name="skills">Java</field>
    #     </doc>
    #   </add>
    #
    # ===== Multiple documents
    #
    #   add([{ employeeId: '05992', office: 'Blackwater' }, { employeeId: '05993', skills: 'Ruby' }])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add>
    #     <doc>
    #       <field name="employeeId">05992</field>
    #       <field name="office">Blackwater</field>
    #     </doc>
    #     <doc>
    #       <field name="employeeId">05993</field>
    #       <field name="skills">Ruby</field>
    #     </doc>
    #   </add>
    #
    # ===== Add attributes
    #
    #   add([id: 42, text: 'blah'], commitWithin: 23)
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add commitWithin="23">
    #     <doc>
    #       <field name="id">42</field>
    #       <field name="text">blah</field>
    #     </doc>
    #   </add>
    #
    # ===== Document attributes
    #
    #   add([[{ id: 42, text: 'blah' }, boost: 10.0]])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add>
    #     <doc boost="10.0">
    #       <field name="id">42</field>
    #       <field name="text">blah</field>
    #     </doc>
    #   </add>
    #
    # ===== Field attributes
    #
    #   add(id: 42, text: ['blah', boost: 2.0])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add>
    #     <doc>
    #       <field name="id">42</field>
    #       <field name="text" boost="2.0">blah</field>
    #     </doc>
    #   </add>
    #
    # ===== All attributes together
    #
    #   add([[{ id: 42, text: ['blah', boost: 2.0] }, boost: 10.0]], commitWithin: 23)
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <add commitWithin="23">
    #     <doc boost="10.0">
    #       <field name="id">42</field>
    #       <field name="text" boost="2.0">blah</field>
    #     </doc>
    #   </add>
    def add(doc, attributes = {})
      to_xml(:add, attributes) { |add_node| _each(doc) { |hash, doc_attributes|
        add_node.doc_(doc_attributes) { |doc_node| hash.each { |key, values|
          field_attributes = { name: key }

          if values.is_a?(Array) && values.last.is_a?(Hash)
            field_attributes.update((values = values.dup).pop)
          end

          _each_value(values) { |value| doc_node.field_(value, field_attributes) }
        } }
      } }
    end

    alias_method :doc, :add

    # See Schema[https://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22].
    #
    # ==== Examples:
    #
    # ===== Without options
    #
    #   commit
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <commit/>
    #
    # ===== With options
    #
    #   commit(softCommit: true)
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <commit softCommit="true"/>
    def commit(attributes = {})
      to_xml(:commit, attributes)
    end

    # See Schema[https://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22].
    #
    # ==== Examples:
    #
    # ===== Without options
    #
    #   optimize
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <optimize/>
    #
    # ===== With options
    #
    #   optimize(maxSegments: 42)
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <optimize maxSegments="42"/>
    def optimize(attributes = {})
      to_xml(:optimize, attributes)
    end

    # See Schema[https://wiki.apache.org/solr/UpdateXmlMessages#A.22rollback.22].
    #
    # ==== Example:
    #
    #   rollback
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <rollback/>
    def rollback
      to_xml(:rollback)
    end

    # See Schema[https://wiki.apache.org/solr/UpdateXmlMessages#A.22delete.22_documents_by_ID_and_by_Query].
    #
    # See Query#query_string for handling of query hashes (via +client.query_string+).
    #
    # ==== Examples:
    #
    # ===== Single ID
    #
    #   delete(id: '05991')
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <id>05991</id>
    #   </delete>
    #
    # ===== Multiple IDs
    #
    #   delete(id: %w[05991 06000])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <id>05991</id>
    #     <id>06000</id>
    #   </delete>
    #
    # ===== Single query
    #
    #   delete(query: 'office:Bridgewater')
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <query>office:Bridgewater</query>
    #   </delete>
    #
    # ===== Multiple queries
    #
    #   delete(query: %w[office:Bridgewater office:Osaka])
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <query>office:Bridgewater</query>
    #     <query>office:Osaka</query>
    #   </delete>
    #
    # ===== Query hash
    #
    #   delete(query: { office: 'Bridgewater', skills: 'Perl' })
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <query>office:Bridgewater skills:Perl</query>
    #   </delete>
    #
    # ===== Query hash with array
    #
    #   delete(query: { office: %w[Bridgewater Osaka] })
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <query>office:Bridgewater office:Osaka</query>
    #   </delete>
    #
    # ===== Query hash with LocalParams[https://wiki.apache.org/solr/LocalParams]
    #
    #   delete(query: { office: 'Bridgewater', _: { type: :edismax } })
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <query>{!type=edismax}office:Bridgewater</query>
    #   </delete>
    #
    # ===== Both IDs and queries
    #
    #   delete(id: %w[05991 06000], query: { office: %w[Bridgewater Osaka] })
    #
    # Result:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <delete>
    #     <id>05991</id>
    #     <id>06000</id>
    #     <query>office:Bridgewater office:Osaka</query>
    #   </delete>
    def delete(hash)
      to_xml(:delete) { |delete_node| hash.each { |key, values|
        case key.to_s
          when 'id'    then _each_value(values) { |value| delete_node.id_(value) }
          when 'query' then _each_value(values) { |value| delete_node.query_(
            client.query_string(value, false)) }
          else raise ArgumentError, "`id' or `query' expected, got %p" % key
        end
      } }
    end

    def inspect
      '#<%s:0x%x %p>' % [self.class, object_id, @solr4r_opt]
    end

    private

    def to_xml(name, attributes = {}, &block)
      self.parent = self.doc = @solr4r_doc.dup
      method_missing(name, attributes, &block)
      replace_illegal_characters(super(&nil))
    end

    def replace_illegal_characters(string)
      string.gsub(ILLEGAL_CHAR_RE, '')
    end

    def _each(values, &block)
      (values.respond_to?(:to_ary) ? values : [values]).each(&block)
    end

    def _each_value(values)
      _each(values) { |value| yield convert_value(value) }
    end

    def convert_value(value)
      self.class.convert_value(value)
    end

  end

end
