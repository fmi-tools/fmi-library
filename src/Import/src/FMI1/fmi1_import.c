/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdarg.h>

#include <jm_named_ptr.h>
#include "fmi1_import_impl.h"
#include "fmi1_import_variable_list_impl.h"

#include <FMI1/fmi1_types.h>
#include <FMI1/fmi1_functions.h>
#include <FMI1/fmi1_enums.h>
#include <FMI1/fmi1_capi.h>

/*#include "fmi1_import_vendor_annotations_impl.h"
#include "fmi1_import_parser.h"
*/

fmi1_import_t* fmi1_import_allocate(jm_callbacks* cb) {
	fmi1_import_t* fmu = (fmi1_import_t*)cb->calloc(1, sizeof(fmi1_import_t));

	if(!fmu) {
		return 0;
	}
	fmu->dirPath = 0;
	fmu->callbacks = cb;
	fmu->md = fmi1_xml_allocate_model_description(cb);
	if(!fmu->md) {
		cb->free(fmu);
		return 0;
	}
	return fmu;
}

void fmi_import_error(fmi_import_context_t *context, const char* fmt, ...) {
	
    va_list args;
    const char * module = "FMIIMPORT";

    va_start (args, fmt);
	jm_log_v(context->callbacks,module, jm_log_level_error, fmt, args);
	va_end (args);
}

const char* fmi1_import_get_last_error(fmi1_import_t* fmu) {
	return jm_get_last_error(fmu->callbacks);
}


fmi1_import_t* fmi1_import_parse_xml( fmi_import_context_t* context, const char* dirPath) {
	char* xmlPath =  fmi_import_get_model_description_path(dirPath, context->callbacks);

	fmi1_import_t* fmu = fmi1_import_allocate(context->callbacks);

	if(!fmu) {
		fmi_import_error( context, "Import", "Could not allocated memory");
		context->callbacks->free(xmlPath);
		return 0;
	}

	if(fmi1_xml_parse_model_description( fmu->md, xmlPath)) {
		fmi1_import_free(fmu);
		context->callbacks->free(xmlPath);
		return 0;
	}
	
	fmu->dirPath =  context->callbacks->calloc(strlen(dirPath) + 1, sizeof(char));
	if (fmu->dirPath == NULL) {
		fmi_import_error( context, "Import", "Could not allocated memory");
		fmi1_import_free(fmu);
		context->callbacks->free(xmlPath);
		return 0;
	}
	strcpy(fmu->dirPath, dirPath);

	return fmu;
}

/*
const char* fmi1_import_get_last_error(fmi1_import_t* fmu) {
    return fmu->errMessageBuf;
}

int fmi1_import_clear_last_error(fmi1_import_t* fmu) {
    fmu->errMessageBuf[0] = 0;
    return (fmu->status != fmi1_import_model_description_enu_error);
}
*/

void fmi1_import_free(fmi1_import_t* fmu) {
    jm_callbacks* cb = fmu->callbacks;

	fmi1_xml_free_model_description(fmu->md);
    cb->free(fmu);
}

const char* fmi1_import_get_model_name(fmi1_import_t* fmu) {
	return fmi1_xml_get_model_name(fmu->md);
}

const char* fmi1_import_get_model_identifier(fmi1_import_t* fmu) {
	return fmi1_xml_get_model_identifier(fmu->md);
}

const char* fmi1_import_get_GUID(fmi1_import_t* fmu){
    return fmi1_xml_get_GUID(fmu->md);
}

const char* fmi1_import_get_description(fmi1_import_t* fmu) {
	return fmi1_xml_get_description(fmu->md);
}

const char* fmi1_import_get_author(fmi1_import_t* fmu) {
	return fmi1_xml_get_author(fmu->md);
}

const char* fmi1_import_get_model_standard_version(fmi1_import_t* fmu) {
	return fmi1_xml_get_model_standard_version(fmu->md);
}

const char* fmi1_import_get_model_version(fmi1_import_t* fmu) {
	return fmi1_xml_get_model_version(fmu->md);
}

const char* fmi1_import_get_generation_tool(fmi1_import_t* fmu) {
	return fmi1_xml_get_generation_tool(fmu->md);
}

const char* fmi1_import_get_generation_date_and_time(fmi1_import_t* fmu) {
	return fmi1_xml_get_generation_date_and_time(fmu->md);
}

fmi1_variable_naming_convension_enu_t fmi1_import_get_naming_convention(fmi1_import_t* fmu) {
	return fmi1_xml_get_naming_convention(fmu->md);
}

unsigned int fmi1_import_get_number_of_continuous_states(fmi1_import_t* fmu) {
	return fmi1_xml_get_number_of_continuous_states(fmu->md);
}

unsigned int fmi1_import_get_number_of_event_indicators(fmi1_import_t* fmu) {
	return fmi1_xml_get_number_of_event_indicators(fmu->md);
}

double fmi1_import_get_default_experiment_start(fmi1_import_t* fmu) {
	return fmi1_xml_get_default_experiment_start(fmu->md);
}

void fmi1_import_set_default_experiment_start(fmi1_import_t* fmu, double t) {
	fmi1_xml_set_default_experiment_start(fmu->md, t);
}

double fmi1_import_get_default_experiment_stop(fmi1_import_t* fmu) {
	return fmi1_xml_get_default_experiment_stop(fmu->md);
}

void fmi1_import_set_default_experiment_stop(fmi1_import_t* fmu, double t) {
	fmi1_xml_set_default_experiment_stop(fmu->md, t);
}

double fmi1_import_get_default_experiment_tolerance(fmi1_import_t* fmu) {
	return fmi1_xml_get_default_experiment_tolerance(fmu->md);
}

void fmi1_import_set_default_experiment_tolerance(fmi1_import_t* fmu, double tol) {
	fmi1_xml_set_default_experiment_tolerance(fmu->md, tol);
}

fmi1_import_vendor_list_t* fmi1_import_get_vendor_list(fmi1_import_t* fmu) {
	return fmi1_xml_get_vendor_list(fmu->md);
}

unsigned int  fmi1_import_get_number_of_vendors(fmi1_import_vendor_list_t* vl) {
	return fmi1_xml_get_number_of_vendors(vl);
}

fmi1_import_vendor_t* fmi1_import_get_vendor(fmi1_import_vendor_list_t* v, unsigned int  index) {
	return fmi1_xml_get_vendor(v, index);
}

fmi1_import_unit_definitions_t* fmi1_import_get_unit_definitions(fmi1_import_t* fmu) {
	return fmi1_xml_get_unit_definitions(fmu->md);
}

unsigned int  fmi1_import_get_unit_definitions_number(fmi1_import_unit_definitions_t* ud) {
	return fmi1_xml_get_unit_definitions_number(ud);
}

fmi1_import_type_definitions_t* fmi1_import_get_type_definitions(fmi1_import_t* fmu) {
	return fmi1_xml_get_type_definitions(fmu->md);
}

void fmi1_import_report_error_v(fmi1_import_t* fmu, const char* module, const char* fmt, va_list ap) {
	jm_log_v(fmu->callbacks, module, jm_log_level_error, fmt, ap);
}

void fmi1_import_report_error(fmi1_import_t* fmu, const char* module, const char* fmt, ...) {
    va_list args;
    va_start (args, fmt);
    fmi1_import_report_error_v(fmu, module, fmt, args);
    va_end (args);
}

void fmi1_import_report_warning_v(fmi1_import_t* fmu, const char* module, const char* fmt, va_list ap) {
	jm_log_v(fmu->callbacks, module, jm_log_level_warning, fmt, ap);
}

void fmi1_import_report_warning(fmi1_import_t* fmu, const char* module, const char* fmt, ...) {
    va_list args;
    va_start (args, fmt);
    fmi1_import_report_warning_v(fmu, module, fmt, args);
    va_end (args);
}

/* Get the list of all the variables in the model */
fmi1_import_variable_list_t* fmi1_import_get_variable_list(fmi1_import_t* fmu) {
	jm_vector(jm_named_ptr)* vars = fmi1_xml_get_variables(fmu->md);
    fmi1_import_variable_list_t* vl;
    size_t nv, i;
    nv = jm_vector_get_size(jm_named_ptr)(vars);
    vl = fmi1_import_alloc_variable_list(fmu, nv);
    if(!vl) return 0;
    for(i = 0; i< nv; i++) {
        jm_vector_set_item(jm_voidp)(&vl->variables, i, jm_vector_get_item(jm_named_ptr)(vars, i).ptr);
    }
    return vl;
}