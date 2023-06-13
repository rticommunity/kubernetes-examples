

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from PatientMonitoring.idl
using RTI Code Generator (rtiddsgen) version 3.1.0.
The rtiddsgen tool is part of the RTI Connext DDS distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the Code Generator User's Manual.
*/

#ifndef PatientMonitoringPlugin_1745722001_h
#define PatientMonitoringPlugin_1745722001_h

#include "PatientMonitoring.hpp"

struct RTICdrStream;

#ifndef pres_typePlugin_h
#include "pres/pres_typePlugin.h"
#endif

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, start exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport __declspec(dllexport)
#endif

#define PatientMonitoringPlugin_get_sample PRESTypePluginDefaultEndpointData_getSample

#define PatientMonitoringPlugin_get_buffer PRESTypePluginDefaultEndpointData_getBuffer 
#define PatientMonitoringPlugin_return_buffer PRESTypePluginDefaultEndpointData_returnBuffer

#define PatientMonitoringPlugin_create_sample PRESTypePluginDefaultEndpointData_createSample 
#define PatientMonitoringPlugin_destroy_sample PRESTypePluginDefaultEndpointData_deleteSample 

/* --------------------------------------------------------------------------------------
Support functions:
* -------------------------------------------------------------------------------------- */

NDDSUSERDllExport extern PatientMonitoring*
PatientMonitoringPluginSupport_create_data_w_params(
    const struct DDS_TypeAllocationParams_t * alloc_params);

NDDSUSERDllExport extern PatientMonitoring*
PatientMonitoringPluginSupport_create_data_ex(RTIBool allocate_pointers);

NDDSUSERDllExport extern PatientMonitoring*
PatientMonitoringPluginSupport_create_data(void);

NDDSUSERDllExport extern RTIBool 
PatientMonitoringPluginSupport_copy_data(
    PatientMonitoring *out,
    const PatientMonitoring *in);

NDDSUSERDllExport extern void 
PatientMonitoringPluginSupport_destroy_data_w_params(
    PatientMonitoring *sample,
    const struct DDS_TypeDeallocationParams_t * dealloc_params);

NDDSUSERDllExport extern void 
PatientMonitoringPluginSupport_destroy_data_ex(
    PatientMonitoring *sample,RTIBool deallocate_pointers);

NDDSUSERDllExport extern void 
PatientMonitoringPluginSupport_destroy_data(
    PatientMonitoring *sample);

NDDSUSERDllExport extern void 
PatientMonitoringPluginSupport_print_data(
    const PatientMonitoring *sample,
    const char *desc,
    unsigned int indent);

/* ----------------------------------------------------------------------------
Callback functions:
* ---------------------------------------------------------------------------- */

NDDSUSERDllExport extern PRESTypePluginParticipantData 
PatientMonitoringPlugin_on_participant_attached(
    void *registration_data, 
    const struct PRESTypePluginParticipantInfo *participant_info,
    RTIBool top_level_registration, 
    void *container_plugin_context,
    RTICdrTypeCode *typeCode);

NDDSUSERDllExport extern void 
PatientMonitoringPlugin_on_participant_detached(
    PRESTypePluginParticipantData participant_data);

NDDSUSERDllExport extern PRESTypePluginEndpointData 
PatientMonitoringPlugin_on_endpoint_attached(
    PRESTypePluginParticipantData participant_data,
    const struct PRESTypePluginEndpointInfo *endpoint_info,
    RTIBool top_level_registration, 
    void *container_plugin_context);

NDDSUSERDllExport extern void 
PatientMonitoringPlugin_on_endpoint_detached(
    PRESTypePluginEndpointData endpoint_data);

NDDSUSERDllExport extern void    
PatientMonitoringPlugin_return_sample(
    PRESTypePluginEndpointData endpoint_data,
    PatientMonitoring *sample,
    void *handle);    

NDDSUSERDllExport extern RTIBool 
PatientMonitoringPlugin_copy_sample(
    PRESTypePluginEndpointData endpoint_data,
    PatientMonitoring *out,
    const PatientMonitoring *in);

/* ----------------------------------------------------------------------------
(De)Serialize functions:
* ------------------------------------------------------------------------- */

NDDSUSERDllExport extern RTIBool
PatientMonitoringPlugin_serialize_to_cdr_buffer(
    char * buffer,
    unsigned int * length,
    const PatientMonitoring *sample,
    ::dds::core::policy::DataRepresentationId representation
    = ::dds::core::policy::DataRepresentation::xcdr()); 

NDDSUSERDllExport extern RTIBool 
PatientMonitoringPlugin_deserialize(
    PRESTypePluginEndpointData endpoint_data,
    PatientMonitoring **sample, 
    RTIBool * drop_sample,
    struct RTICdrStream *stream,
    RTIBool deserialize_encapsulation,
    RTIBool deserialize_sample, 
    void *endpoint_plugin_qos);

NDDSUSERDllExport extern RTIBool
PatientMonitoringPlugin_deserialize_from_cdr_buffer(
    PatientMonitoring *sample,
    const char * buffer,
    unsigned int length);    

NDDSUSERDllExport extern unsigned int 
PatientMonitoringPlugin_get_serialized_sample_max_size(
    PRESTypePluginEndpointData endpoint_data,
    RTIBool include_encapsulation,
    RTIEncapsulationId encapsulation_id,
    unsigned int current_alignment);

/* --------------------------------------------------------------------------------------
Key Management functions:
* -------------------------------------------------------------------------------------- */
NDDSUSERDllExport extern PRESTypePluginKeyKind 
PatientMonitoringPlugin_get_key_kind(void);

NDDSUSERDllExport extern unsigned int 
PatientMonitoringPlugin_get_serialized_key_max_size(
    PRESTypePluginEndpointData endpoint_data,
    RTIBool include_encapsulation,
    RTIEncapsulationId encapsulation_id,
    unsigned int current_alignment);

NDDSUSERDllExport extern unsigned int 
PatientMonitoringPlugin_get_serialized_key_max_size_for_keyhash(
    PRESTypePluginEndpointData endpoint_data,
    RTIEncapsulationId encapsulation_id,
    unsigned int current_alignment);

NDDSUSERDllExport extern RTIBool 
PatientMonitoringPlugin_deserialize_key(
    PRESTypePluginEndpointData endpoint_data,
    PatientMonitoring ** sample,
    RTIBool * drop_sample,
    struct RTICdrStream *stream,
    RTIBool deserialize_encapsulation,
    RTIBool deserialize_key,
    void *endpoint_plugin_qos);

/* Plugin Functions */
NDDSUSERDllExport extern struct PRESTypePlugin*
PatientMonitoringPlugin_new(void);

NDDSUSERDllExport extern void
PatientMonitoringPlugin_delete(struct PRESTypePlugin *);

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, stop exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport
#endif

#endif /* PatientMonitoringPlugin_1745722001_h */

