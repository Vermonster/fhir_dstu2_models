module FHIR
    module Deserializer
        module HealthcareService
        include FHIR::Formats::Utilities
        include FHIR::Deserializer::Utilities
            def parse_xml_entry_ServiceTypeComponent(entry) 
                return nil unless entry
                model = FHIR::HealthcareService::ServiceTypeComponent.new
                self.parse_element_data(model, entry)
                set_model_data(model, 'fhirType', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:type')))
                set_model_data(model, 'specialty', entry.xpath('./fhir:specialty').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                model
            end
            
            def parse_xml_entry_HealthcareServiceAvailableTimeComponent(entry) 
                return nil unless entry
                model = FHIR::HealthcareService::HealthcareServiceAvailableTimeComponent.new
                self.parse_element_data(model, entry)
                parse_primitive_field(model,entry,'daysOfWeek','daysOfWeek',true)
                parse_primitive_field(model,entry,'allDay','allDay',false)
                parse_primitive_field(model,entry,'availableStartTime','availableStartTime',false)
                parse_primitive_field(model,entry,'availableEndTime','availableEndTime',false)
                model
            end
            
            def parse_xml_entry_HealthcareServiceNotAvailableComponent(entry) 
                return nil unless entry
                model = FHIR::HealthcareService::HealthcareServiceNotAvailableComponent.new
                self.parse_element_data(model, entry)
                parse_primitive_field(model,entry,'description','description',false)
                set_model_data(model, 'during', FHIR::Period.parse_xml_entry(entry.at_xpath('./fhir:during')))
                model
            end
            
            def parse_xml_entry(entry) 
                return nil unless entry
                model = self.new
                self.parse_element_data(model, entry)
                self.parse_resource_data(model, entry)
                set_model_data(model, 'identifier', entry.xpath('./fhir:identifier').map {|e| FHIR::Identifier.parse_xml_entry(e)})
                set_model_data(model, 'providedBy', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:providedBy')))
                set_model_data(model, 'serviceCategory', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:serviceCategory')))
                set_model_data(model, 'serviceType', entry.xpath('./fhir:serviceType').map {|e| parse_xml_entry_ServiceTypeComponent(e)})
                set_model_data(model, 'location', FHIR::Reference.parse_xml_entry(entry.at_xpath('./fhir:location')))
                parse_primitive_field(model,entry,'serviceName','serviceName',false)
                parse_primitive_field(model,entry,'comment','comment',false)
                parse_primitive_field(model,entry,'extraDetails','extraDetails',false)
                set_model_data(model, 'photo', FHIR::Attachment.parse_xml_entry(entry.at_xpath('./fhir:photo')))
                set_model_data(model, 'telecom', entry.xpath('./fhir:telecom').map {|e| FHIR::ContactPoint.parse_xml_entry(e)})
                set_model_data(model, 'coverageArea', entry.xpath('./fhir:coverageArea').map {|e| FHIR::Reference.parse_xml_entry(e)})
                set_model_data(model, 'serviceProvisionCode', entry.xpath('./fhir:serviceProvisionCode').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                set_model_data(model, 'eligibility', FHIR::CodeableConcept.parse_xml_entry(entry.at_xpath('./fhir:eligibility')))
                parse_primitive_field(model,entry,'eligibilityNote','eligibilityNote',false)
                parse_primitive_field(model,entry,'programName','programName',true)
                set_model_data(model, 'characteristic', entry.xpath('./fhir:characteristic').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                set_model_data(model, 'referralMethod', entry.xpath('./fhir:referralMethod').map {|e| FHIR::CodeableConcept.parse_xml_entry(e)})
                parse_primitive_field(model,entry,'publicKey','publicKey',false)
                parse_primitive_field(model,entry,'appointmentRequired','appointmentRequired',false)
                set_model_data(model, 'availableTime', entry.xpath('./fhir:availableTime').map {|e| parse_xml_entry_HealthcareServiceAvailableTimeComponent(e)})
                set_model_data(model, 'notAvailable', entry.xpath('./fhir:notAvailable').map {|e| parse_xml_entry_HealthcareServiceNotAvailableComponent(e)})
                parse_primitive_field(model,entry,'availabilityExceptions','availabilityExceptions',false)
                model
            end
        end
    end
end
