module FHIR
    module Deserializer
        module Person
        include FHIR::Formats::Utilities
        include FHIR::Deserializer::Utilities
            def parse_xml_entry_PersonLinkComponent(entry) 
                return nil unless entry
                model = FHIR::Person::PersonLinkComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'target', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:target')))
                parse_primitive_field(model,entry,'assurance','assurance',false)
                model
            end
            
            def parse_xml_entry(entry) 
                return nil unless entry
                model = self.new
                self.parse_element_data(model, entry)
                self.parse_resource_data(model, entry)
                set_model_data(model, 'identifier', entry.xpath('./fhir:identifier').map {|e| FHIR::Identifier.parse_xml_entry(e)})
                set_model_data(model, 'name', entry.xpath('./fhir:name').map {|e| FHIR::HumanName.parse_xml_entry(e)})
                set_model_data(model, 'telecom', entry.xpath('./fhir:telecom').map {|e| FHIR::ContactPoint.parse_xml_entry(e)})
                parse_primitive_field(model,entry,'gender','gender',false)
                parse_primitive_field(model,entry,'birthDate','birthDate',false)
                set_model_data(model, 'address', entry.xpath('./fhir:address').map {|e| FHIR::Address.parse_xml_entry(e)})
                set_model_data(model, 'photo', FHIR::Attachment.parse_xml_entry(entry.at_xpath('./fhir:photo')))
                set_model_data(model, 'managingOrganization', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:managingOrganization')))
                parse_primitive_field(model,entry,'active','active',false)
                set_model_data(model, 'link', entry.xpath('./fhir:link').map {|e| parse_xml_entry_PersonLinkComponent(e)})
                model
            end
        end
    end
end
