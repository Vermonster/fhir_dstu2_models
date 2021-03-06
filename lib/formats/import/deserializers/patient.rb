module FHIR
    module Deserializer
        module Patient
        include FHIR::Formats::Utilities
        include FHIR::Deserializer::Utilities
            def parse_xml_entry_ContactComponent(entry) 
                return nil unless entry
                model = FHIR::Patient::ContactComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'relationship', entry.xpath('./fhir:relationship').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                set_model_data(model, 'name', FHIR::HumanName.parse_xml_entry(entry.at_xpath('./fhir:name')))
                set_model_data(model, 'telecom', entry.xpath('./fhir:telecom').map {|e| FHIR::ContactPoint.parse_xml_entry(e)})
                set_model_data(model, 'address', FHIR::Address.parse_xml_entry(entry.at_xpath('./fhir:address')))
                parse_primitive_field(model,entry,'gender','gender',false)
                set_model_data(model, 'organization', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:organization')))
                set_model_data(model, 'period', FHIR::Period.parse_xml_entry(entry.at_xpath('./fhir:period')))
                model
            end
            
            def parse_xml_entry_AnimalComponent(entry) 
                return nil unless entry
                model = FHIR::Patient::AnimalComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'species', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:species')))
                set_model_data(model, 'breed', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:breed')))
                set_model_data(model, 'genderStatus', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:genderStatus')))
                model
            end
            
            def parse_xml_entry_PatientCommunicationComponent(entry) 
                return nil unless entry
                model = FHIR::Patient::PatientCommunicationComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'language', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:language')))
                parse_primitive_field(model,entry,'preferred','preferred',false)
                model
            end
            
            def parse_xml_entry_PatientLinkComponent(entry) 
                return nil unless entry
                model = FHIR::Patient::PatientLinkComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'other', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:other')))
                parse_primitive_field(model,entry,'type','fhirType',false)
                model
            end
            
            def parse_xml_entry(entry) 
                return nil unless entry
                model = self.new
                self.parse_element_data(model, entry)
                self.parse_resource_data(model, entry)
                set_model_data(model, 'identifier', entry.xpath('./fhir:identifier').map {|e| FHIR::Identifier.parse_xml_entry(e)})
                parse_primitive_field(model,entry,'active','active',false)
                set_model_data(model, 'name', entry.xpath('./fhir:name').map {|e| FHIR::HumanName.parse_xml_entry(e)})
                set_model_data(model, 'telecom', entry.xpath('./fhir:telecom').map {|e| FHIR::ContactPoint.parse_xml_entry(e)})
                parse_primitive_field(model,entry,'gender','gender',false)
                parse_primitive_field(model,entry,'birthDate','birthDate',false)
                parse_primitive_field(model,entry,'deceasedBoolean','deceasedBoolean',false)
                parse_primitive_field(model,entry,'deceasedDateTime','deceasedDateTime',false)
                set_model_data(model, 'address', entry.xpath('./fhir:address').map {|e| FHIR::Address.parse_xml_entry(e)})
                set_model_data(model, 'maritalStatus', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:maritalStatus')))
                parse_primitive_field(model,entry,'multipleBirthBoolean','multipleBirthBoolean',false)
                parse_primitive_field(model,entry,'multipleBirthInteger','multipleBirthInteger',false)
                set_model_data(model, 'photo', entry.xpath('./fhir:photo').map {|e| FHIR::Attachment.parse_xml_entry(e)})
                set_model_data(model, 'contact', entry.xpath('./fhir:contact').map {|e| parse_xml_entry_ContactComponent(e)})
                set_model_data(model, 'animal', parse_xml_entry_AnimalComponent(entry.at_xpath('./fhir:animal')))
                set_model_data(model, 'communication', entry.xpath('./fhir:communication').map {|e| parse_xml_entry_PatientCommunicationComponent(e)})
                set_model_data(model, 'careProvider', entry.xpath('./fhir:careProvider').map {|e| FHIR::Reference.parse_xml_entry(e)})
                set_model_data(model, 'managingOrganization', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:managingOrganization')))
                set_model_data(model, 'link', entry.xpath('./fhir:link').map {|e| parse_xml_entry_PatientLinkComponent(e)})
                model
            end
        end
    end
end
