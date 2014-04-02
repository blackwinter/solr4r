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

  Document = Nokogiri::XML::Document

  class Builder < Nokogiri::XML::Builder

    DEFAULT_OPTIONS = {
      encoding: 'UTF-8'
    }

    def initialize(options = {})
      if block_given?
        raise ArgumentError,
          'block argument not supported, use options hash instead'
      end

      super(@options = DEFAULT_OPTIONS.merge(options))

      @_solr_doc = @doc
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
      to_xml(:add, attributes) { |add_node|
        doc = [doc] unless doc.is_a?(Array)
        doc.each { |hash, doc_attributes|
          doc_(doc_attributes) { |doc_node|
            hash.each { |key, values|
              values = values.is_a?(Array) ? values.dup : [values]

              field_attributes = values.last.is_a?(Hash) ? values.pop : {}
              field_attributes = field_attributes.merge(name: key)

              values.each { |value| doc_node.field_(value, field_attributes) }
            }
          }
        }
      }
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
      to_xml(:delete) { |delete_node|
        hash.each { |key, values|
          values = [values] unless values.is_a?(Array)
          values.each { |value|
            ary = []

            if value.is_a?(Hash)
              value.each { |k, v| Array(v).each { |w| ary << "#{k}:#{w}" } }
            else
              ary << value
            end

            ary.each { |v| delete_node.method_missing(key, v) }
          }
        }
      }
    end

    def inspect
      '#<%s:0x%x @options=%p>' % [
        self.class, object_id, @options
      ]
    end

    private

    def to_xml(name, attributes = {}, &block)
      self.parent = self.doc = @_solr_doc.dup

      method_missing(name, attributes, &block)

      super(&nil)
    end

  end

end
