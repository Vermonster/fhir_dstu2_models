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
    class Patient 
        
        include Mongoid::Document
        include Mongoid::History::Trackable
        include FHIR::Element
        include FHIR::Resource
        include FHIR::Formats::Utilities
        include FHIR::Serializer::Utilities
        extend FHIR::Deserializer::Patient
        
        SEARCH_PARAMS = [
            'birthdate',
            'deceased',
            'address-state',
            'gender',
            'animal-species',
            'link',
            'language',
            'deathdate',
            'animal-breed',
            'address-country',
            'phonetic',
            'telecom',
            'address-city',
            'email',
            'identifier',
            'given',
            'address',
            'active',
            'address-postalcode',
            'careprovider',
            'phone',
            'organization',
            'name',
            'address-use',
            'family'
        ]
        
        VALID_CODES = {
            gender: [ 'male', 'female', 'other', 'unknown' ],
            maritalStatus: [ 'U', 'A', 'D', 'I', 'L', 'M', 'P', 'S', 'T', 'W', 'UNK' ]
        }
        
        MULTIPLE_TYPES = {
            deceased: [ 'deceasedBoolean', 'deceasedDateTime' ],
            multipleBirth: [ 'multipleBirthBoolean', 'multipleBirthInteger' ]
        }
        
        # This is an ugly hack to deal with embedded structures in the spec contact
        class ContactComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                gender: [ 'male', 'female', 'other', 'unknown' ],
                relationship: [ 'emergency', 'family', 'guardian', 'friend', 'partner', 'work', 'caregiver', 'agent', 'guarantor', 'owner', 'parent' ]
            }
            
            embeds_many :relationship, class_name:'FHIR::CodeableConcept'
            embeds_one :name, class_name:'FHIR::HumanName'
            embeds_many :telecom, class_name:'FHIR::ContactPoint'
            embeds_one :address, class_name:'FHIR::Address'
            field :gender, type: String
            validates :gender, :inclusion => { in: VALID_CODES[:gender], :allow_nil => true }
            embeds_one :organization, class_name:'FHIR::Reference'
            embeds_one :period, class_name:'FHIR::Period'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec animal
        class AnimalComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                species: [ 'canislf', 'ovisa', 'serinuscd' ],
                breed: [ 'gsd', 'irt', 'tibmas', 'gret' ],
                genderStatus: [ 'neutered', 'intact', 'unknown' ]
            }
            
            embeds_one :species, class_name:'FHIR::CodeableConcept'
            validates_presence_of :species
            embeds_one :breed, class_name:'FHIR::CodeableConcept'
            embeds_one :genderStatus, class_name:'FHIR::CodeableConcept'
        end
        
        # This is an ugly hack to deal with embedded structures in the spec communication
        class PatientCommunicationComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            embeds_one :language, class_name:'FHIR::CodeableConcept'
            validates_presence_of :language
            field :preferred, type: Boolean
        end
        
        # This is an ugly hack to deal with embedded structures in the spec link
        class PatientLinkComponent
        include Mongoid::Document
        include FHIR::Element
        include FHIR::Formats::Utilities
            
            VALID_CODES = {
                fhirType: [ 'replace', 'refer', 'seealso' ]
            }
            
            embeds_one :other, class_name:'FHIR::Reference'
            validates_presence_of :other
            field :fhirType, type: String
            validates :fhirType, :inclusion => { in: VALID_CODES[:fhirType] }
            validates_presence_of :fhirType
        end
        
        embeds_many :identifier, class_name:'FHIR::Identifier'
        field :active, type: Boolean
        embeds_many :name, class_name:'FHIR::HumanName'
        embeds_many :telecom, class_name:'FHIR::ContactPoint'
        field :gender, type: String
        validates :gender, :inclusion => { in: VALID_CODES[:gender], :allow_nil => true }
        field :birthDate, type: String
        validates :birthDate, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1]))?)?\Z/ }
        field :deceasedBoolean, type: Boolean
        field :deceasedDateTime, type: String
        validates :deceasedDateTime, :allow_nil => true, :format => {  with: /\A[0-9]{4}(-(0[1-9]|1[0-2])(-(0[0-9]|[1-2][0-9]|3[0-1])(T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?)?)?)?\Z/ }
        embeds_many :address, class_name:'FHIR::Address'
        embeds_one :maritalStatus, class_name:'FHIR::CodeableConcept'
        field :multipleBirthBoolean, type: Boolean
        field :multipleBirthInteger, type: Integer
        embeds_many :photo, class_name:'FHIR::Attachment'
        embeds_many :contact, class_name:'FHIR::Patient::ContactComponent'
        embeds_one :animal, class_name:'FHIR::Patient::AnimalComponent'
        embeds_many :communication, class_name:'FHIR::Patient::PatientCommunicationComponent'
        embeds_many :careProvider, class_name:'FHIR::Reference'
        embeds_one :managingOrganization, class_name:'FHIR::Reference'
        embeds_many :link, class_name:'FHIR::Patient::PatientLinkComponent'
        track_history
    end
end
