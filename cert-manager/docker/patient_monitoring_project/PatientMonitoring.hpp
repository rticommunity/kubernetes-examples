

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from PatientMonitoring.idl
using RTI Code Generator (rtiddsgen) version 3.1.0.
The rtiddsgen tool is part of the RTI Connext DDS distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the Code Generator User's Manual.
*/

#ifndef PatientMonitoring_1745722001_hpp
#define PatientMonitoring_1745722001_hpp

#include <iosfwd>

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, start exporting symbols.
*/
#undef RTIUSERDllExport
#define RTIUSERDllExport __declspec(dllexport)
#endif

#include "dds/domain/DomainParticipant.hpp"
#include "dds/topic/TopicTraits.hpp"
#include "dds/core/SafeEnumeration.hpp"
#include "dds/core/String.hpp"
#include "dds/core/array.hpp"
#include "dds/core/vector.hpp"
#include "dds/core/Optional.hpp"
#include "dds/core/xtypes/DynamicType.hpp"
#include "dds/core/xtypes/StructType.hpp"
#include "dds/core/xtypes/UnionType.hpp"
#include "dds/core/xtypes/EnumType.hpp"
#include "dds/core/xtypes/AliasType.hpp"
#include "rti/core/array.hpp"
#include "rti/core/BoundedSequence.hpp"
#include "rti/util/StreamFlagSaver.hpp"
#include "rti/domain/PluginSupport.hpp"
#include "rti/core/LongDouble.hpp"
#include "dds/core/External.hpp"
#include "rti/core/Pointer.hpp"
#include "rti/topic/TopicTraits.hpp"

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, stop exporting symbols.
*/
#undef RTIUSERDllExport
#define RTIUSERDllExport
#endif

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, start exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport __declspec(dllexport)
#endif

class NDDSUSERDllExport PatientMonitoring {
  public:
    PatientMonitoring();

    explicit PatientMonitoring(
        const std::string& patient_condition);

    #ifdef RTI_CXX11_RVALUE_REFERENCES
    #ifndef RTI_CXX11_NO_IMPLICIT_MOVE_OPERATIONS
    PatientMonitoring (PatientMonitoring&&) = default;
    PatientMonitoring& operator=(PatientMonitoring&&) = default;
    PatientMonitoring& operator=(const PatientMonitoring&) = default;
    PatientMonitoring(const PatientMonitoring&) = default;
    #else
    PatientMonitoring(PatientMonitoring&& other_) OMG_NOEXCEPT;  
    PatientMonitoring& operator=(PatientMonitoring&&  other_) OMG_NOEXCEPT;
    #endif
    #endif 

    std::string& patient_condition() OMG_NOEXCEPT {
        return m_patient_condition_;
    }

    const std::string& patient_condition() const OMG_NOEXCEPT {
        return m_patient_condition_;
    }

    void patient_condition(const std::string& value) {
        m_patient_condition_ = value;
    }

    void patient_condition(std::string&& value) {
        m_patient_condition_ = std::move(value);
    }

    bool operator == (const PatientMonitoring& other_) const;
    bool operator != (const PatientMonitoring& other_) const;

    void swap(PatientMonitoring& other_) OMG_NOEXCEPT ;

  private:

    std::string m_patient_condition_;

};

inline void swap(PatientMonitoring& a, PatientMonitoring& b)  OMG_NOEXCEPT 
{
    a.swap(b);
}

NDDSUSERDllExport std::ostream& operator<<(std::ostream& o, const PatientMonitoring& sample);

namespace rti {
    namespace flat {
        namespace topic {
        }
    }
}
namespace dds {
    namespace topic {

        template<>
        struct topic_type_name< PatientMonitoring > {
            NDDSUSERDllExport static std::string value() {
                return "PatientMonitoring";
            }
        };

        template<>
        struct is_topic_type< PatientMonitoring > : public ::dds::core::true_type {};

        template<>
        struct topic_type_support< PatientMonitoring > {
            NDDSUSERDllExport 
            static void register_type(
                ::dds::domain::DomainParticipant& participant,
                const std::string & type_name);

            NDDSUSERDllExport 
            static std::vector<char>& to_cdr_buffer(
                std::vector<char>& buffer, 
                const PatientMonitoring& sample,
                ::dds::core::policy::DataRepresentationId representation 
                = ::dds::core::policy::DataRepresentation::auto_id());

            NDDSUSERDllExport 
            static void from_cdr_buffer(PatientMonitoring& sample, const std::vector<char>& buffer);
            NDDSUSERDllExport 
            static void reset_sample(PatientMonitoring& sample);

            NDDSUSERDllExport 
            static void allocate_sample(PatientMonitoring& sample, int, int);

            static const ::rti::topic::TypePluginKind::type type_plugin_kind = 
            ::rti::topic::TypePluginKind::STL;
        };

    }
}

namespace rti { 
    namespace topic {
        #ifndef NDDS_STANDALONE_TYPE
        template<>
        struct dynamic_type< PatientMonitoring > {
            typedef ::dds::core::xtypes::StructType type;
            NDDSUSERDllExport static const ::dds::core::xtypes::StructType& get();
        };
        #endif

        template <>
        struct extensibility< PatientMonitoring > {
            static const ::dds::core::xtypes::ExtensibilityKind::type kind =
            ::dds::core::xtypes::ExtensibilityKind::EXTENSIBLE;                
        };

    }
}

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, stop exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport
#endif

#endif // PatientMonitoring_1745722001_hpp

