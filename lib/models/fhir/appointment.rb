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
    class Appointment 
        
        include Mongoid::Document
        include Mongoid::History::Trackable
        include FHIR::Element
        include FHIR::Resource
        include FHIR::Formats::Utilities
        include FHIR::Serializer::Utilities
        extend FHIR::Deserializer::Appointment
        
        SEARCH_PARAMS = [
            'date',
            'actor',
            'identifier',
            'practitioner',
            'part-status',
            'patient',
            'location',
            'status'
        ]
        
        VALID_CODES = {
            fhirType: [ '408467006', '394577000', '394578005', '421661004', '408462000', '394579002', '394804000', '394580004', '394803006', '408480009', '408454008', '394809005', '394592004', '394600006', '394601005', '394581000', '408478003', '394812008', '408444009', '394582007', '408475000', '410005002', '394583002', '419772000', '394584008', '408443003', '394802001', '394915009', '394814009', '394808002', '394811001', '408446006', '394586005', '394916005', '408472002', '394597005', '394598000', '394807007', '419192003', '408468001', '394593009', '394813003', '410001006', '394589003', '394591006', '394599008', '394649004', '408470005', '394585009', '394821009', '422191005', '394594003', '416304004', '418960008', '394882004', '394806003', '394588006', '408459003', '394607009', '419610006', '418058008', '420208008', '418652005', '418535003', '418862001', '419365004', '418002000', '419983000', '419170002', '419472004', '394539006', '420112009', '409968004', '394587001', '394913002', '408440000', '418112009', '419815003', '394914008', '408455009', '394602003', '408447002', '394810000', '408450004', '408476004', '408469009', '408466002', '408471009', '408464004', '408441001', '408465003', '394605001', '394608004', '408461007', '408460008', '408460008', '394606000', '408449004', '394608004', '418018006', '394604002', '394609007', '408474001', '394610002', '394611003', '408477008', '394801008', '408463005', '419321007', '394576009', '394590007', '409967009', '408448007', '419043006', '394612005', '394733009', '394732004' ],
            status: [ 'proposed', 'pending', 'booked', 'arrived', 'fulfilled', 'cancelled', 'noshow' ]
        }
        
        # This is an ugly hack to deal with embedded structures in the spec participant
        class AppointmentParticipantComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                fhirType: [ 'translator', 'emergency', 'PART', '_ParticipationAncillary', 'ADM', 'ATND', 'CALLBCK', 'CON', 'DIS', 'ESC', 'REF', '_ParticipationInformationGenerator', 'AUT', 'INF', 'TRANS', 'ENT', 'WIT', 'CST', 'DIR', 'ALY', 'BBY', 'CAT', 'CSM', 'DEV', 'NRD', 'RDV', 'DON', 'EXPAGNT', 'EXPART', 'EXPTRGT', 'EXSRC', 'PRD', 'SBJ', 'SPC', 'IND', 'BEN', 'CAGNT', 'COV', 'GUAR', 'HLD', 'RCT', 'RCV', 'IRCP', 'NOT', 'PRCP', 'REFB', 'REFT', 'TRC', 'LOC', 'DST', 'ELOC', 'ORG', 'RML', 'VIA', 'PRF', 'DIST', 'PPRF', 'SPRF', 'RESP', 'VRF', 'AUTHEN', 'LA', '_ParticipationAncillary', 'ADM', 'ATND', 'CALLBCK', 'CON', 'DIS', 'ESC', 'REF', 'SPRF', 'PPRF', 'PART' ],
                required: [ 'required', 'optional', 'information-only' ],
                status: [ 'accepted', 'declined', 'tentative', 'needs-action' ]
            }
            
            embeds_many :fhirType, class_name:'FHIR::CodeableConcept'
            embeds_one :actor, class_name:'FHIR::Reference'
            field :required, type: String
            validates :required, :inclusion => { in: VALID_CODES[:required], :allow_nil => true }
            field :status, type: String
            validates :status, :inclusion => { in: VALID_CODES[:status] }
            validates_presence_of :status
        end
        
        embeds_many :identifier, class_name:'FHIR::Identifier'
        field :status, type: String
        validates :status, :inclusion => { in: VALID_CODES[:status] }
        validates_presence_of :status
        embeds_one :fhirType, class_name:'FHIR::CodeableConcept'
        embeds_one :reason, class_name:'FHIR::CodeableConcept'
        field :priority, type: Integer
        field :description, type: String
        field :start, type: String
        validates :start, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))))\Z/ }
        field :end, type: String
        validates :end, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))))\Z/ }
        field :minutesDuration, type: Integer
        embeds_many :slot, class_name:'FHIR::Reference'
        field :comment, type: String
        embeds_many :participant, class_name:'FHIR::Appointment::AppointmentParticipantComponent'
        validates_presence_of :participant
        track_history
    end
end
