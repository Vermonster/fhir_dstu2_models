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
    class ImagingStudy 
        
        include Mongoid::Document
        include Mongoid::History::Trackable
        include FHIR::Element
        include FHIR::Resource
        include FHIR::Formats::Utilities
        include FHIR::Serializer::Utilities
        extend FHIR::Deserializer::ImagingStudy
        
        SEARCH_PARAMS = [
            'uid',
            'study',
            'dicom-class',
            'modality',
            'bodysite',
            'patient',
            'series',
            'started',
            'accession',
            'order'
        ]
        
        VALID_CODES = {
            modalityList: [ 'AR', 'BMD', 'BDUS', 'EPS', 'CR', 'CT', 'DX', 'ECG', 'ES', 'XC', 'GM', 'HD', 'IO', 'IVOCT', 'IVUS', 'KER', 'LEN', 'MR', 'MG', 'NM', 'OAM', 'OCT', 'OPM', 'OP', 'OPR', 'OPT', 'OPV', 'OSS', 'PX', 'PT', 'RF', 'RG', 'SM', 'SRF', 'US', 'VA', 'XA' ],
            availability: [ 'ONLINE', 'OFFLINE', 'NEARLINE', 'UNAVAILABLE' ]
        }
        
        # This is an ugly hack to deal with embedded structures in the spec instance
        class ImagingStudySeriesInstanceComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            field :number, type: Integer
            field :uid, type: String
            validates_presence_of :uid
            field :sopClass, type: String
            validates_presence_of :sopClass
            field :fhirType, type: String
            field :title, type: String
            embeds_many :content, class_name:'FHIR::Attachment'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec series
        class ImagingStudySeriesComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                modality: [ 'AR', 'BMD', 'BDUS', 'EPS', 'CR', 'CT', 'DX', 'ECG', 'ES', 'XC', 'GM', 'HD', 'IO', 'IVOCT', 'IVUS', 'KER', 'LEN', 'MR', 'MG', 'NM', 'OAM', 'OCT', 'OPM', 'OP', 'OPR', 'OPT', 'OPV', 'OSS', 'PX', 'PT', 'RF', 'RG', 'SM', 'SRF', 'US', 'VA', 'XA' ],
                availability: [ 'ONLINE', 'OFFLINE', 'NEARLINE', 'UNAVAILABLE' ]
            }
            
            field :number, type: Integer
            embeds_one :modality, class_name:'FHIR::Coding'
            validates_presence_of :modality
            field :uid, type: String
            validates_presence_of :uid
            field :description, type: String
            field :numberOfInstances, type: Integer
            validates_presence_of :numberOfInstances
            field :availability, type: String
            validates :availability, :inclusion => { in: VALID_CODES[:availability], :allow_nil => true }
            field :url, type: String
            embeds_one :bodySite, class_name:'FHIR::Coding'
            embeds_one :laterality, class_name:'FHIR::Coding'
            field :started, type: String
            validates :started, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?)?)?)?\Z/ }
            embeds_many :instance, class_name:'FHIR::ImagingStudy::ImagingStudySeriesInstanceComponent'
        end
        
        field :started, type: String
        validates :started, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?)?)?)?\Z/ }
        embeds_one :patient, class_name:'FHIR::Reference'
        validates_presence_of :patient
        field :uid, type: String
        validates_presence_of :uid
        embeds_one :accession, class_name:'FHIR::Identifier'
        embeds_many :identifier, class_name:'FHIR::Identifier'
        embeds_many :order, class_name:'FHIR::Reference'
        embeds_many :modalityList, class_name:'FHIR::Coding'
        embeds_one :referrer, class_name:'FHIR::Reference'
        field :availability, type: String
        validates :availability, :inclusion => { in: VALID_CODES[:availability], :allow_nil => true }
        field :url, type: String
        field :numberOfSeries, type: Integer
        validates_presence_of :numberOfSeries
        field :numberOfInstances, type: Integer
        validates_presence_of :numberOfInstances
        embeds_many :procedure, class_name:'FHIR::Reference'
        embeds_one :interpreter, class_name:'FHIR::Reference'
        field :description, type: String
        embeds_many :series, class_name:'FHIR::ImagingStudy::ImagingStudySeriesComponent'
        track_history
    end
end
