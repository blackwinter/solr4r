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

require 'nokogiri'

module Solr4R

  class Builder < Nokogiri::XML::Builder

    class Document < Nokogiri::XML::Document

      def document
        self
      end

    end

    DEFAULT_OPTIONS = {
      encoding: 'UTF-8'
    }

    def initialize(options = {})
      if block_given?
        raise ArgumentError,
          'block argument not supported, use options hash instead'
      end

      super(
        @_solr_opt = DEFAULT_OPTIONS.merge(options),
        @_solr_doc = Document.new
      )
    end

    # See Schema[http://wiki.apache.org/solr/UpdateXmlMessages#add.2Freplace_documents].
    #
    # Examples:
    #
    #   # single document
    #   add(employeeId: '05991', office: 'Bridgewater', skills: %w[Perl Java])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add>
    #       <doc>
    #         <field name="employeeId">05991</field>
    #         <field name="office">Bridgewater</field>
    #         <field name="skills">Perl</field>
    #         <field name="skills">Java</field>
    #       </doc>
    #     </add>
    #
    #   # multiple documents
    #   add([{ employeeId: '05992', office: 'Blackwater' }, { employeeId: '05993', skills: 'Ruby' }])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add>
    #       <doc>
    #         <field name="employeeId">05992</field>
    #         <field name="office">Blackwater</field>
    #       </doc>
    #       <doc>
    #         <field name="employeeId">05993</field>
    #         <field name="skills">Ruby</field>
    #       </doc>
    #     </add>
    #
    #   # add attributes
    #   add([id: 42, text: 'blah'], commitWithin: 23)
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add commitWithin="23">
    #       <doc>
    #         <field name="id">42</field>
    #         <field name="text">blah</field>
    #       </doc>
    #     </add>
    #
    #   # document attributes
    #   add([[{ id: 42, text: 'blah' }, { boost: 10.0 }]])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add>
    #       <doc boost="10.0">
    #         <field name="id">42</field>
    #         <field name="text">blah</field>
    #       </doc>
    #     </add>
    #
    #   # field attributes
    #   add(id: 42, text: ['blah', boost: 2.0])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add>
    #       <doc>
    #         <field name="id">42</field>
    #         <field boost="2.0" name="text">blah</field>
    #       </doc>
    #     </add>
    #
    #   # all attributes together
    #   add([[{ id: 42, text: ['blah', boost: 2.0] }, { boost: 10.0 }]], commitWithin: 23)
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <add commitWithin="23">
    #       <doc boost="10.0">
    #         <field name="id">42</field>
    #         <field boost="2.0" name="text">blah</field>
    #       </doc>
    #     </add>
    def add(doc, attributes = {})
      to_xml(:add, attributes) { |add_node| _each(doc) { |hash, doc_attributes|
        add_node.doc_(doc_attributes) { |doc_node| hash.each { |key, values|
          field_attributes = (values.is_a?(Array) && values.last.is_a?(Hash) ?
            (values = values.dup).pop : {}).merge(name: key)

          _each(values) { |value| doc_node.field_(value, field_attributes) }
        } }
      } }
    end

    # See Schema[http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22].
    #
    # Examples:
    #
    #   commit
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <commit/>
    #
    #   commit(softCommit: true)
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <commit softCommit="true"/>
    def commit(attributes = {})
      to_xml(:commit, attributes)
    end

    # See Schema[http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22].
    #
    # Examples:
    #
    #   optimize
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <optimize/>
    #
    #   optimize(maxSegments: 42)
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <optimize maxSegments="42"/>
    def optimize(attributes = {})
      to_xml(:optimize, attributes)
    end

    # See Schema[http://wiki.apache.org/solr/UpdateXmlMessages#A.22rollback.22].
    #
    # Example:
    #
    #   rollback
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <rollback/>
    def rollback
      to_xml(:rollback)
    end

    # See Schema[http://wiki.apache.org/solr/UpdateXmlMessages#A.22delete.22_documents_by_ID_and_by_Query].
    #
    # Examples:
    #
    #   # single ID
    #   delete(id: '05991')
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <id>05991</id>
    #     </delete>
    #
    #   # multiple IDs
    #   delete(id: %w[05991 06000])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <id>05991</id>
    #       <id>06000</id>
    #     </delete>
    #
    #   # single query
    #   delete(query: 'office:Bridgewater')
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <query>office:Bridgewater</query>
    #     </delete>
    #
    #   # multiple queries
    #   delete(query: %w[office:Bridgewater office:Osaka])
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <query>office:Bridgewater</query>
    #       <query>office:Osaka</query>
    #     </delete>
    #
    #   # query hash
    #   delete(query: { office: 'Bridgewater', skills: 'Perl' })
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <query>office:Bridgewater</query>
    #       <query>skills:Perl</query>
    #     </delete>
    #
    #   # query hash with array
    #   delete(query: { office: %w[Bridgewater Osaka] })
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <query>office:Bridgewater</query>
    #       <query>office:Osaka</query>
    #     </delete>
    #
    #   # both IDs and queries
    #   delete(id: %w[05991 06000], query: { office: %w[Bridgewater Osaka] })
    #
    #     <?xml version="1.0" encoding="UTF-8"?>
    #     <delete>
    #       <id>05991</id>
    #       <id>06000</id>
    #       <query>office:Bridgewater</query>
    #       <query>office:Osaka</query>
    #     </delete>
    def delete(hash)
      to_xml(:delete) { |delete_node| hash.each { |key, values|
        delete = lambda { |value| delete_node.method_missing(key, value) }

        _each(values) { |value| !value.is_a?(Hash) ? delete[value] :
          value.each { |k, v| Array(v).each { |w| delete["#{k}:#{w}"] } } }
      } }
    end

    def inspect
      '#<%s:0x%x %p>' % [self.class, object_id, @_solr_opt]
    end

    private

    def to_xml(name, attributes = {}, &block)
      self.parent = self.doc = @_solr_doc.dup
      method_missing(name, attributes, &block)
      replace_illegal_characters(super(&nil))
    end

    def replace_illegal_characters(string)
      string.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F]/, '')
    end

    def _each(values, &block)
      (values.is_a?(Array) ? values : [values]).each(&block)
    end

  end

end
