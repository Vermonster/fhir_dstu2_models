# Copyright (c) 2011-2015, HL7, Inc & The MITRE Corporation
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this 
#       list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, 
#       this list of conditions and the following disclaimer in the documentation 
#       and/or other materials provided with the distribution.
#     * Neither the name of HL7 nor the names of its contributors may be used to 
#       endorse or promote products derived from this software without specific 
#       prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.

module FHIR
  class ValueSet

    @@base_valuesets = nil
    @@v2_tables = nil
    @@v3_codesystems = nil

    def self.load_valuesets
      if @@base_valuesets.nil?
        filename = File.join(File.dirname(__FILE__),'valuesets.xml')
        xml = File.read(filename)
        @@base_valuesets = FHIR::Bundle.from_xml(xml)
      end
      if @@v2_tables.nil?
        filename = File.join(File.dirname(__FILE__),'v2-tables.xml')
        xml = File.read(filename)
        @@v2_tables = FHIR::Bundle.from_xml(xml)
      end      
      if @@v3_codesystems.nil?
        filename = File.join(File.dirname(__FILE__),'v3-codesystems.xml')
        xml = File.read(filename)
        @@v3_codesystems = FHIR::Bundle.from_xml(xml)
      end
    end

    def self.get_base_valueset(valueset_name)
      return nil if valueset_name.nil?
      load_valuesets

      @@base_valuesets.entry.each do |entry|
        if entry.resourceType == 'ValueSet'
          if !entry.resource.nil? && (entry.fullUrl == valueset_name || entry.resource.url == valueset_name || entry.resource.name == valueset_name || entry.resource.xmlId == valueset_name || entry.resource.try(:codeSystem).try(:system) == valueset_name)
            return entry.resource
          end
        end
      end
      @@v2_tables.entry.each do |entry|
        if entry.resourceType == 'ValueSet'
          if !entry.resource.nil? && (entry.fullUrl == valueset_name || entry.resource.url == valueset_name || entry.resource.name == valueset_name || entry.resource.xmlId == valueset_name || entry.resource.try(:codeSystem).try(:system) == valueset_name)
            return entry.resource
          end
        end
      end
      @@v3_codesystems.entry.each do |entry|
        if entry.resourceType == 'ValueSet'
          if !entry.resource.nil? && (entry.fullUrl == valueset_name || entry.resource.url == valueset_name || entry.resource.name == valueset_name || entry.resource.xmlId == valueset_name || entry.resource.try(:codeSystem).try(:system) == valueset_name)
            return entry.resource
          end
        end
      end

      nil
    end

    def include?(code)
      # first, check codeSystems
      if !codeSystem.nil?
        codeSystem.concept.each do |concept|
          return true if concept_include?(concept,code)
        end
      end

      # if it wasn't found, need to check compose
      if !compose.nil?
        return true if((compose_import?(compose,code) || compose_include?(compose,code)) && !compose_exclude?(compose,code))
      end

      # finally, try checking expansion
      if !expansion.nil?
        return expansion_include?(code)
      end

      # special cases
      if ['http://hl7.org/fhir/ValueSet/data-types','http://hl7.org/fhir/ValueSet/resource-types'].include?(url)
        return true if code.starts_with?('Reference(') && code.ends_with?(')')
        return true if code=='Resource'
      end

      false
    end

    def concept_include?(concept, code)
      return false if (concept.nil? || code.nil?)
      return true if concept.code==code
      return true if (codeSystem.caseSensitive==false && concept.code.downcase==code.downcase)
      if !concept.concept.nil?
        concept.concept.each do |child|
          return true if concept_include?(child,code)
        end
      end
      false
    end

    # TODO compose_import? won't fetch remote ValueSets
    def compose_import?(compose, code)
     return false if (compose.nil? || compose.import.nil? || code.nil?)
      compose.import.each do |import|
        other = FHIR::ValueSet.get_base_valueset(import)
        return true if !other.nil? && other.include?(code)
      end
      false      
    end

    def compose_include?(compose, code)
      return false if (compose.nil? || compose.include.nil? || code.nil?)
      compose.include.each do |concept|
        concept.concept.each do |c|
          return true if c.code==code
          return true if (!codeSystem.nil? && codeSystem.caseSensitive==false && c.code.downcase==code.downcase)
        end
        system = FHIR::ValueSet.get_base_valueset(concept.system)
        if !system.nil?
          return true if system.include?(code)
        end
      end
      false
    end

    def compose_exclude?(compose, code)
      return false if (compose.nil? || compose.exclude.nil? || code.nil?)
      compose.exclude.each do |concept|
        concept.concept.each do |c|
          return true if c.code==code
          return true if (!codeSystem.nil? && codeSystem.caseSensitive==false && c.code.downcase==code.downcase)
        end
        system = FHIR::ValueSet.get_base_valueset(concept.system)
        if !system.nil?
          return true if system.include?(code)
        end
      end
      false
    end

    def expansion_include?(code)
      return false if (expansion.nil? || code.nil?)
      expansion.contains.each do |contains|
        return true if contains_include?(contains,code)
      end
      false
    end

    def contains_include?(contains,code)
      return false if (contains.nil? || code.nil?)
      return true if contains.code==code
      return true if (!codeSystem.nil? && codeSystem.caseSensitive==false && !contains.code.nil? && contains.code.downcase==code.downcase)
      if !contains.contains.nil?
        contains.contains.each do |c|
          return true if contains_include?(c,code)
        end
      end
      false
    end

    private :concept_include?, :compose_import?, :compose_include?, :compose_exclude?, :expansion_include?, :contains_include?

  end
end
