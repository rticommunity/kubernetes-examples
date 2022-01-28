

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from PatientMonitoring.idl
using RTI Code Generator (rtiddsgen) version 3.1.0.
The rtiddsgen tool is part of the RTI Connext DDS distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the Code Generator User's Manual.
*/

#include <iosfwd>
#include <iomanip>

#include "rti/topic/cdr/Serialization.hpp"

#include "PatientMonitoring.hpp"
#include "PatientMonitoringPlugin.hpp"

#include <rti/util/ostream_operators.hpp>

// ---- PatientMonitoring: 

PatientMonitoring::PatientMonitoring() :
    m_patient_condition_ ("")  {
}   

PatientMonitoring::PatientMonitoring (
    const std::string& patient_condition)
    :
        m_patient_condition_( patient_condition ) {
}

#ifdef RTI_CXX11_RVALUE_REFERENCES
#ifdef RTI_CXX11_NO_IMPLICIT_MOVE_OPERATIONS
PatientMonitoring::PatientMonitoring(PatientMonitoring&& other_) OMG_NOEXCEPT  :m_patient_condition_ (std::move(other_.m_patient_condition_))
{
} 

PatientMonitoring& PatientMonitoring::operator=(PatientMonitoring&&  other_) OMG_NOEXCEPT {
    PatientMonitoring tmp(std::move(other_));
    swap(tmp); 
    return *this;
}
#endif
#endif   

void PatientMonitoring::swap(PatientMonitoring& other_)  OMG_NOEXCEPT 
{
    using std::swap;
    swap(m_patient_condition_, other_.m_patient_condition_);
}  

bool PatientMonitoring::operator == (const PatientMonitoring& other_) const {
    if (m_patient_condition_ != other_.m_patient_condition_) {
        return false;
    }
    return true;
}
bool PatientMonitoring::operator != (const PatientMonitoring& other_) const {
    return !this->operator ==(other_);
}

std::ostream& operator << (std::ostream& o,const PatientMonitoring& sample)
{
    ::rti::util::StreamFlagSaver flag_saver (o);
    o <<"[";
    o << "patient_condition: " << sample.patient_condition() ;
    o <<"]";
    return o;
}

// --- Type traits: -------------------------------------------------

namespace rti { 
    namespace topic {

        #ifndef NDDS_STANDALONE_TYPE
        template<>
        struct native_type_code< PatientMonitoring > {
            static DDS_TypeCode * get()
            {
                using namespace ::rti::topic::interpreter;

                static RTIBool is_initialized = RTI_FALSE;

                static DDS_TypeCode PatientMonitoring_g_tc_patient_condition_string;

                static DDS_TypeCode_Member PatientMonitoring_g_tc_members[1]=
                {

                    {
                        (char *)"patient_condition",/* Member name */
                        {
                            0,/* Representation ID */
                            DDS_BOOLEAN_FALSE,/* Is a pointer? */
                            -1, /* Bitfield bits */
                            NULL/* Member type code is assigned later */
                        },
                        0, /* Ignored */
                        0, /* Ignored */
                        0, /* Ignored */
                        NULL, /* Ignored */
                        RTI_CDR_REQUIRED_MEMBER, /* Is a key? */
                        DDS_PUBLIC_MEMBER,/* Member visibility */
                        1,
                        NULL, /* Ignored */
                        RTICdrTypeCodeAnnotations_INITIALIZER
                    }
                };

                static DDS_TypeCode PatientMonitoring_g_tc =
                {{
                        DDS_TK_STRUCT, /* Kind */
                        DDS_BOOLEAN_FALSE, /* Ignored */
                        -1, /*Ignored*/
                        (char *)"PatientMonitoring", /* Name */
                        NULL, /* Ignored */      
                        0, /* Ignored */
                        0, /* Ignored */
                        NULL, /* Ignored */
                        1, /* Number of members */
                        PatientMonitoring_g_tc_members, /* Members */
                        DDS_VM_NONE, /* Ignored */
                        RTICdrTypeCodeAnnotations_INITIALIZER,
                        DDS_BOOLEAN_TRUE, /* _isCopyable */
                        NULL, /* _sampleAccessInfo: assigned later */
                        NULL /* _typePlugin: assigned later */
                    }}; /* Type code for PatientMonitoring*/

                if (is_initialized) {
                    return &PatientMonitoring_g_tc;
                }

                PatientMonitoring_g_tc_patient_condition_string = initialize_string_typecode((128L));

                PatientMonitoring_g_tc._data._annotations._allowedDataRepresentationMask = 5;

                PatientMonitoring_g_tc_members[0]._representation._typeCode = (RTICdrTypeCode *)&PatientMonitoring_g_tc_patient_condition_string;

                /* Initialize the values for member annotations. */
                PatientMonitoring_g_tc_members[0]._annotations._defaultValue._d = RTI_XCDR_TK_STRING;
                PatientMonitoring_g_tc_members[0]._annotations._defaultValue._u.string_value = (DDS_Char *) "";

                PatientMonitoring_g_tc._data._sampleAccessInfo = sample_access_info();
                PatientMonitoring_g_tc._data._typePlugin = type_plugin_info();    

                is_initialized = RTI_TRUE;

                return &PatientMonitoring_g_tc;
            }

            static RTIXCdrSampleAccessInfo * sample_access_info()
            {
                static RTIBool is_initialized = RTI_FALSE;

                PatientMonitoring *sample;

                static RTIXCdrMemberAccessInfo PatientMonitoring_g_memberAccessInfos[1] =
                {RTIXCdrMemberAccessInfo_INITIALIZER};

                static RTIXCdrSampleAccessInfo PatientMonitoring_g_sampleAccessInfo = 
                RTIXCdrSampleAccessInfo_INITIALIZER;

                if (is_initialized) {
                    return (RTIXCdrSampleAccessInfo*) &PatientMonitoring_g_sampleAccessInfo;
                }

                RTIXCdrHeap_allocateStruct(
                    &sample, 
                    PatientMonitoring);
                if (sample == NULL) {
                    return NULL;
                }

                PatientMonitoring_g_memberAccessInfos[0].bindingMemberValueOffset[0] = 
                (RTIXCdrUnsignedLong) ((char *)&sample->patient_condition() - (char *)sample);

                PatientMonitoring_g_sampleAccessInfo.memberAccessInfos = 
                PatientMonitoring_g_memberAccessInfos;

                {
                    size_t candidateTypeSize = sizeof(PatientMonitoring);

                    if (candidateTypeSize > RTIXCdrLong_MAX) {
                        PatientMonitoring_g_sampleAccessInfo.typeSize[0] =
                        RTIXCdrLong_MAX;
                    } else {
                        PatientMonitoring_g_sampleAccessInfo.typeSize[0] =
                        (RTIXCdrUnsignedLong) candidateTypeSize;
                    }
                }

                PatientMonitoring_g_sampleAccessInfo.useGetMemberValueOnlyWithRef =
                RTI_XCDR_TRUE;

                PatientMonitoring_g_sampleAccessInfo.getMemberValuePointerFcn = 
                interpreter::get_aggregation_value_pointer< PatientMonitoring >;

                PatientMonitoring_g_sampleAccessInfo.languageBinding = 
                RTI_XCDR_TYPE_BINDING_CPP_11_STL ;

                RTIXCdrHeap_freeStruct(sample);
                is_initialized = RTI_TRUE;
                return (RTIXCdrSampleAccessInfo*) &PatientMonitoring_g_sampleAccessInfo;
            }

            static RTIXCdrTypePlugin * type_plugin_info()
            {
                static RTIXCdrTypePlugin PatientMonitoring_g_typePlugin = 
                {
                    NULL, /* serialize */
                    NULL, /* serialize_key */
                    NULL, /* deserialize_sample */
                    NULL, /* deserialize_key_sample */
                    NULL, /* skip */
                    NULL, /* get_serialized_sample_size */
                    NULL, /* get_serialized_sample_max_size_ex */
                    NULL, /* get_serialized_key_max_size_ex */
                    NULL, /* get_serialized_sample_min_size */
                    NULL, /* serialized_sample_to_key */
                    NULL,
                    NULL,
                    NULL,
                    NULL
                };

                return &PatientMonitoring_g_typePlugin;
            }
        }; // native_type_code
        #endif

        const ::dds::core::xtypes::StructType& dynamic_type< PatientMonitoring >::get()
        {
            return static_cast<const ::dds::core::xtypes::StructType&>(
                ::rti::core::native_conversions::cast_from_native< ::dds::core::xtypes::DynamicType >(
                    *(native_type_code< PatientMonitoring >::get())));
        }

    }
}

namespace dds { 
    namespace topic {
        void topic_type_support< PatientMonitoring >:: register_type(
            ::dds::domain::DomainParticipant& participant,
            const std::string& type_name) 
        {

            ::rti::domain::register_type_plugin(
                participant,
                type_name,
                PatientMonitoringPlugin_new,
                PatientMonitoringPlugin_delete);
        }

        std::vector<char>& topic_type_support< PatientMonitoring >::to_cdr_buffer(
            std::vector<char>& buffer, 
            const PatientMonitoring& sample,
            ::dds::core::policy::DataRepresentationId representation)
        {
            // First get the length of the buffer
            unsigned int length = 0;
            RTIBool ok = PatientMonitoringPlugin_serialize_to_cdr_buffer(
                NULL, 
                &length,
                &sample,
                representation);
            ::rti::core::check_return_code(
                ok ? DDS_RETCODE_OK : DDS_RETCODE_ERROR,
                "Failed to calculate cdr buffer size");

            // Create a vector with that size and copy the cdr buffer into it
            buffer.resize(length);
            ok = PatientMonitoringPlugin_serialize_to_cdr_buffer(
                &buffer[0], 
                &length, 
                &sample,
                representation);
            ::rti::core::check_return_code(
                ok ? DDS_RETCODE_OK : DDS_RETCODE_ERROR,
                "Failed to copy cdr buffer");

            return buffer;
        }

        void topic_type_support< PatientMonitoring >::from_cdr_buffer(PatientMonitoring& sample, 
        const std::vector<char>& buffer)
        {

            RTIBool ok  = PatientMonitoringPlugin_deserialize_from_cdr_buffer(
                &sample, 
                &buffer[0], 
                static_cast<unsigned int>(buffer.size()));
            ::rti::core::check_return_code(ok ? DDS_RETCODE_OK : DDS_RETCODE_ERROR,
            "Failed to create PatientMonitoring from cdr buffer");
        }

        void topic_type_support< PatientMonitoring >::reset_sample(PatientMonitoring& sample) 
        {
            sample.patient_condition("");
        }

        void topic_type_support< PatientMonitoring >::allocate_sample(PatientMonitoring& sample, int, int) 
        {
            ::rti::topic::allocate_sample(sample.patient_condition(),  -1, 128L);
        }

    }
}  

