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
    class Encounter 
        
        include Mongoid::Document
        include Mongoid::History::Trackable
        include FHIR::Element
        include FHIR::Resource
        include FHIR::Formats::Utilities
        include FHIR::Serializer::Utilities
        extend FHIR::Deserializer::Encounter
        
        SEARCH_PARAMS = [
            'date',
            'identifier',
            'reason',
            'episodeofcare',
            'participant-type',
            'incomingreferral',
            'practitioner',
            'length',
            'appointment',
            'part-of',
            'procedure',
            'type',
            'participant',
            'condition',
            'patient',
            'location-period',
            'location',
            'indication',
            'special-arrangement',
            'status'
        ]
        
        VALID_CODES = {
            fhirClass: [ 'inpatient', 'outpatient', 'ambulatory', 'emergency', 'home', 'field', 'daytime', 'virtual', 'other' ],
            priority: [ 'imm', 'emg', 'urg', 's-urg', 'no-urg' ],
            fhirType: [ 'ADMS', 'BD/BM-clin', 'CCS60', 'OKI' ],
            status: [ 'planned', 'arrived', 'in-progress', 'onleave', 'finished', 'cancelled' ]
        }
        
        # This is an ugly hack to deal with embedded structures in the spec statusHistory
        class EncounterStatusHistoryComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                status: [ 'planned', 'arrived', 'in-progress', 'onleave', 'finished', 'cancelled' ]
            }
            
            field :status, type: String
            validates :status, :inclusion => { in: VALID_CODES[:status] }
            validates_presence_of :status
            embeds_one :period, class_name:'FHIR::Period'
            validates_presence_of :period
        end
        
        # This is an ugly hack to deal with embedded structures in the spec participant
        class EncounterParticipantComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                fhirType: [ 'translator', 'emergency', 'PART', '_ParticipationAncillary', 'ADM', 'ATND', 'CALLBCK', 'CON', 'DIS', 'ESC', 'REF', '_ParticipationInformationGenerator', 'AUT', 'INF', 'TRANS', 'ENT', 'WIT', 'CST', 'DIR', 'ALY', 'BBY', 'CAT', 'CSM', 'DEV', 'NRD', 'RDV', 'DON', 'EXPAGNT', 'EXPART', 'EXPTRGT', 'EXSRC', 'PRD', 'SBJ', 'SPC', 'IND', 'BEN', 'CAGNT', 'COV', 'GUAR', 'HLD', 'RCT', 'RCV', 'IRCP', 'NOT', 'PRCP', 'REFB', 'REFT', 'TRC', 'LOC', 'DST', 'ELOC', 'ORG', 'RML', 'VIA', 'PRF', 'DIST', 'PPRF', 'SPRF', 'RESP', 'VRF', 'AUTHEN', 'LA', '_ParticipationAncillary', 'ADM', 'ATND', 'CALLBCK', 'CON', 'DIS', 'ESC', 'REF', 'SPRF', 'PPRF', 'PART' ]
            }
            
            embeds_many :fhirType, class_name:'FHIR::CodeableConcept'
            embeds_one :period, class_name:'FHIR::Period'
            embeds_one :individual, class_name:'FHIR::Reference'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec hospitalization
        class EncounterHospitalizationComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                specialArrangement: [ 'wheel', 'stret', 'int', 'att', 'dog' ],
                dietPreference: [ 'vegetarian', 'dairy-free', 'nut-free', 'gluten-free', 'vegan', 'halal', 'kosher' ],
                specialCourtesy: [ 'EXT', 'NRM', 'PRF', 'STF', 'VIP', 'UNK' ],
                dischargeDisposition: [ 'home', 'other-hcf', 'hosp', 'long', 'aadvice', 'exp', 'psy', 'rehab', 'oth' ],
                admitSource: [ 'hosp-trans', 'emd', 'outp', 'born', 'gp', 'mp', 'nursing', 'psych', 'rehab', 'other' ]
            }
            
            embeds_one :preAdmissionIdentifier, class_name:'FHIR::Identifier'
            embeds_one :origin, class_name:'FHIR::Reference'
            embeds_one :admitSource, class_name:'FHIR::CodeableConcept'
            embeds_many :admittingDiagnosis, class_name:'FHIR::Reference'
            embeds_one :reAdmission, class_name:'FHIR::CodeableConcept'
            embeds_many :dietPreference, class_name:'FHIR::CodeableConcept'
            embeds_many :specialCourtesy, class_name:'FHIR::CodeableConcept'
            embeds_many :specialArrangement, class_name:'FHIR::CodeableConcept'
            embeds_one :destination, class_name:'FHIR::Reference'
            embeds_one :dischargeDisposition, class_name:'FHIR::CodeableConcept'
            embeds_many :dischargeDiagnosis, class_name:'FHIR::Reference'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec location
        class EncounterLocationComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                status: [ 'planned', 'active', 'reserved', 'completed' ]
            }
            
            embeds_one :location, class_name:'FHIR::Reference'
            validates_presence_of :location
            field :status, type: String
            validates :status, :inclusion => { in: VALID_CODES[:status], :allow_nil => true }
            embeds_one :period, class_name:'FHIR::Period'
        end
        
        embeds_many :identifier, class_name:'FHIR::Identifier'
        field :status, type: String
        validates :status, :inclusion => { in: VALID_CODES[:status] }
        validates_presence_of :status
        embeds_many :statusHistory, class_name:'FHIR::Encounter::EncounterStatusHistoryComponent'
        field :fhirClass, type: String
        validates :fhirClass, :inclusion => { in: VALID_CODES[:fhirClass], :allow_nil => true }
        embeds_many :fhirType, class_name:'FHIR::CodeableConcept'
        embeds_one :priority, class_name:'FHIR::CodeableConcept'
        embeds_one :patient, class_name:'FHIR::Reference'
        embeds_many :episodeOfCare, class_name:'FHIR::Reference'
        embeds_many :incomingReferral, class_name:'FHIR::Reference'
        embeds_many :participant, class_name:'FHIR::Encounter::EncounterParticipantComponent'
        embeds_one :appointment, class_name:'FHIR::Reference'
        embeds_one :period, class_name:'FHIR::Period'
        embeds_one :length, class_name:'FHIR::Quantity'
        embeds_many :reason, class_name:'FHIR::CodeableConcept'
        embeds_many :indication, class_name:'FHIR::Reference'
        embeds_one :hospitalization, class_name:'FHIR::Encounter::EncounterHospitalizationComponent'
        embeds_many :location, class_name:'FHIR::Encounter::EncounterLocationComponent'
        embeds_one :serviceProvider, class_name:'FHIR::Reference'
        embeds_one :partOf, class_name:'FHIR::Reference'
        track_history
    end
end
