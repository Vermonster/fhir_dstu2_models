module FHIR
    module Deserializer
        module ReferralRequest
        include FHIR::Formats::Utilities
        include FHIR::Deserializer::Utilities
            def parse_xml_entry(entry) 
                return nil unless entry
                model = self.new
                self.parse_element_data(model, entry)
                self.parse_resource_data(model, entry)
                parse_primitive_field(model,entry,'status','status',false)
                set_model_data(model, 'identifier', entry.xpath('./fhir:identifier').map {|e| FHIR::Identifier.parse_xml_entry(e)})
                parse_primitive_field(model,entry,'date','date',false)
                set_model_data(model, 'fhirType', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:type')))
                set_model_data(model, 'specialty', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:specialty')))
                set_model_data(model, 'priority', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:priority')))
                set_model_data(model, 'patient', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:patient')))
                set_model_data(model, 'requester', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:requester')))
                set_model_data(model, 'recipient', entry.xpath('./fhir:recipient').map {|e| FHIR::Reference.parse_xml_entry(e)})
                set_model_data(model, 'encounter', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:encounter')))
                parse_primitive_field(model,entry,'dateSent','dateSent',false)
                set_model_data(model, 'reason', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:reason')))
                parse_primitive_field(model,entry,'description','description',false)
                set_model_data(model, 'serviceRequested', entry.xpath('./fhir:serviceRequested').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                set_model_data(model, 'supportingInformation', entry.xpath('./fhir:supportingInformation').map {|e| FHIR::Reference.parse_xml_entry(e)})
                set_model_data(model, 'fulfillmentTime', FHIR::Period.parse_xml_entry(entry.at_xpath('./fhir:fulfillmentTime')))
                model
            end
        end
    end
end
