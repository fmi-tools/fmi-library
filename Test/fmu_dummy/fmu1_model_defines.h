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

/* This header is used to generate the FMU test DLL and in the C API test that uses the DLL */
#ifndef FMU1_MODEL_DEFINES_H_

#define STRINGIFY(a)			#a
#define STRINGIFY2(a)			STRINGIFY(a)
#define MODEL_IDENTIFIER_STR	STRINGIFY2(MODEL_IDENTIFIER)

#define BUFFER					1024
#define MAGIC_TEST_VALUE		13.0	/* A test value for some functions  */

/* BouncingBall model with redundant values */
/* ValueReferences for the variables and parameters in the model */
/* States */
#define VAR_R_HIGHT				0
#define VAR_R_HIGHT_SPEED		1
/* Real */
#define VAR_R_GRATIVY			2
#define VAR_R_BOUNCE_CONF		3

/* Event indicators */
#define EVENT_HIGHT				0

/* Sizes */
#define N_STATES				2
#define N_EVENT_INDICATORS		1
#define N_REAL					4
#define N_INTEGER				4
#define N_BOOLEAN				4
#define N_STRING				4

#define N_INPUT_REAL			2 /* CS only */
#define N_INPUT_REAL_MAX_ORDER	2 /* CS only */
#define N_OUTPUT_REAL			2 /* CS only */
#define N_OUTPUT_REAL_MAX_ORDER	2 /* CS only */


#define FMI_VERSION			"1.0"
#define FMI_PLATFORM_TYPE	"ANY_PLATFORM"
#define FMI_GUID			"123"


#endif /* End of header FMU1_MODEL_DEFINES_H_ */