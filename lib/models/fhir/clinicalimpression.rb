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
    class ClinicalImpression 
        
        include Mongoid::Document
        include Mongoid::History::Trackable
        include FHIR::Element
        include FHIR::Resource
        include FHIR::Formats::Utilities
        include FHIR::Serializer::Utilities
        extend FHIR::Deserializer::ClinicalImpression
        
        SEARCH_PARAMS = [
            'date',
            'previous',
            'assessor',
            'trigger',
            'finding',
            'ruledout',
            'problem',
            'patient',
            'investigation',
            'action',
            'trigger-code',
            'plan',
            'resolved',
            'status'
        ]
        
        VALID_CODES = {
            status: [ 'in-progress', 'completed', 'entered-in-error' ]
        }
        
        MULTIPLE_TYPES = {
            trigger: [ 'triggerCodeableConcept', 'triggerReference' ]
        }
        
        # This is an ugly hack to deal with embedded structures in the spec investigations
        class ClinicalImpressionInvestigationsComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                code: [ '271336007', '160237006' ]
            }
            
            embeds_one :code, class_name:'FHIR::CodeableConcept'
            validates_presence_of :code
            embeds_many :item, class_name:'FHIR::Reference'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec finding
        class ClinicalImpressionFindingComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            embeds_one :item, class_name:'FHIR::CodeableConcept'
            validates_presence_of :item
            field :cause, type: String
        end
        
        # This is an ugly hack to deal with embedded structures in the spec ruledOut
        class ClinicalImpressionRuledOutComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            embeds_one :item, class_name:'FHIR::CodeableConcept'
            validates_presence_of :item
            field :reason, type: String
        end
        
        embeds_one :patient, class_name:'FHIR::Reference'
        validates_presence_of :patient
        embeds_one :assessor, class_name:'FHIR::Reference'
        field :status, type: String
        validates :status, :inclusion => { in: VALID_CODES[:status] }
        validates_presence_of :status
        field :date, type: String
        validates :date, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?)?)?)?\Z/ }
        field :description, type: String
        embeds_one :previous, class_name:'FHIR::Reference'
        embeds_many :problem, class_name:'FHIR::Reference'
        embeds_one :triggerCodeableConcept, class_name:'FHIR::CodeableConcept'
        embeds_one :triggerReference, class_name:'FHIR::Reference'
        embeds_many :investigations, class_name:'FHIR::ClinicalImpression::ClinicalImpressionInvestigationsComponent'
        field :protocol, type: String
        field :summary, type: String
        embeds_many :finding, class_name:'FHIR::ClinicalImpression::ClinicalImpressionFindingComponent'
        embeds_many :resolved, class_name:'FHIR::CodeableConcept'
        embeds_many :ruledOut, class_name:'FHIR::ClinicalImpression::ClinicalImpressionRuledOutComponent'
        field :prognosis, type: String
        embeds_many :plan, class_name:'FHIR::Reference'
        embeds_many :action, class_name:'FHIR::Reference'
        track_history
    end
end
