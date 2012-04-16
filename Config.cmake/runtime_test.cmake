set(RTTESTDIR ${FMILIBRARYHOME}/Test)

add_executable (jm_vector_test ${RTTESTDIR}/jm_vector_test.c)
target_link_libraries (jm_vector_test ${JMUTIL_LIBRARIES})

add_executable (fmi_import_xml_test ${RTTESTDIR}/fmi_import_xml_test.c )
target_link_libraries (fmi_import_xml_test  ${FMIIMPORT_LIBRARIES}  )

add_executable (fmi1_capi_cs_test ${RTTESTDIR}/fmi1_capi_cs_test.c )
target_link_libraries (fmi1_capi_cs_test  ${FMICAPI_LIBRARIES})

add_executable (fmi1_capi_me_test ${RTTESTDIR}/fmi1_capi_me_test.c )
target_link_libraries (fmi1_capi_me_test  ${FMICAPI_LIBRARIES})

#Create function that zipz the dummy FMUs 
add_executable (compress_test_fmu_zip ${RTTESTDIR}/compress_test_fmu_zip.c)
target_link_libraries (compress_test_fmu_zip ${FMIZIP_LIBRARIES})
#Path to the executable
get_property(COMPRESS_EXECUTABLE TARGET compress_test_fmu_zip PROPERTY LOCATION)

set(TEST_OUTPUT_FOLDER "${CMAKE_CURRENT_BINARY_DIR}/testfolder")
#Defines for the test FMUs
set(FMU_DUMMY_ME_MODEL_IDENTIFIER BouncingBall) #This must be the same as in the xml-file
set(FMU_DUMMY_CS_MODEL_IDENTIFIER BouncingBall) #This must be the same as in the xml-file

set(FMU_DUMMY_FOLDER ${RTTESTDIR}/fmu_dummy)

set(FMU_DUMMY_ME_SOURCE
  ${FMU_DUMMY_FOLDER}/fmu1_model_me.c
  ${FMU_DUMMY_FOLDER}/fmu1_model.c
)
set(FMU_DUMMY_CS_SOURCE
  ${FMU_DUMMY_FOLDER}/fmu1_model_cs.c
  ${FMU_DUMMY_FOLDER}/fmu1_model.c
)
set(FMU_DUMMY_HEADERS
  ${FMU_DUMMY_FOLDER}/fmu1_model.h
  ${FMU_DUMMY_FOLDER}/fmu1_model_defines.h
)
include_directories(${RTTESTDIR})
add_library(fmu1_dll_me SHARED ${FMU_DUMMY_ME_SOURCE} ${FMU_DUMMY_HEADERS})
add_library(fmu1_dll_cs SHARED ${FMU_DUMMY_CS_SOURCE} ${FMU_DUMMY_HEADERS})

#Set output directory for the shared library files
set_target_properties(
	fmu1_dll_me
	PROPERTIES 
	RUNTIME_OUTPUT_DIRECTORY_DEBUG 	${TEST_OUTPUT_FOLDER} #For Win
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ${TEST_OUTPUT_FOLDER} #For Win
	LIBRARY_OUTPUT_DIRECTORY_DEBUG ${TEST_OUTPUT_FOLDER} #For Unix
	LIBRARY_OUTPUT_DIRECTORY_RELEASE ${TEST_OUTPUT_FOLDER} #For Unix
	)
	
set_target_properties(
	fmu1_dll_cs 
	PROPERTIES 
	RUNTIME_OUTPUT_DIRECTORY_DEBUG 	${TEST_OUTPUT_FOLDER} #For Win
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ${TEST_OUTPUT_FOLDER} #For Win
	LIBRARY_OUTPUT_DIRECTORY_DEBUG ${TEST_OUTPUT_FOLDER}  #For Unix
	LIBRARY_OUTPUT_DIRECTORY_RELEASE ${TEST_OUTPUT_FOLDER} #For Unix
	)

set(XML_ME_PATH ${FMU_DUMMY_FOLDER}/modelDescription_me.xml)
set(XML_CS_PATH ${FMU_DUMMY_FOLDER}/modelDescription_cs.xml)
set(SHARED_LIBRARY_ME_PATH ${TEST_OUTPUT_FOLDER}/${CMAKE_SHARED_LIBRARY_PREFIX}fmu1_dll_me${CMAKE_SHARED_MODULE_SUFFIX})
set(SHARED_LIBRARY_CS_PATH ${TEST_OUTPUT_FOLDER}/${CMAKE_SHARED_LIBRARY_PREFIX}fmu1_dll_cs${CMAKE_SHARED_MODULE_SUFFIX})

#Create FMU 1.0 ME/CS Model and generate library path
#file(COPY ${FMU_DUMMY_FOLDER}/modelDescription.xml DESTINATION ${TEST_OUTPUT_FOLDER})

set(UNCOMPRESSED_DUMMY_FILE_PATH_SRC "${RTTESTDIR}/try_to_uncompress_this_file.zip")
set(UNCOMPRESSED_DUMMY_FOLDER_PATH_DIST "${TEST_OUTPUT_FOLDER}")
file(COPY "${UNCOMPRESSED_DUMMY_FILE_PATH_SRC}" DESTINATION "${UNCOMPRESSED_DUMMY_FOLDER_PATH_DIST}")

set(COMPRESS_DUMMY_FILE_PATH_SRC "${RTTESTDIR}/try_to_compress_this_file.xml")
set(COMPRESS_DUMMY_FOLDER_PATH_DIST "${TEST_OUTPUT_FOLDER}")
set(COMPRESS_DUMMY_FILE_PATH_DIST "${TEST_OUTPUT_FOLDER}/successfully_compressed_this_file.zip")
file(COPY "${COMPRESS_DUMMY_FILE_PATH_SRC}" DESTINATION "${COMPRESS_DUMMY_FOLDER_PATH_DIST}")

#Create paths for the config.h
if (WIN32)
set(DLL_OUTPUT_PATH "${TEST_OUTPUT_FOLDER}")
set(DLL_OUTPUT_PATH_ME_DEFINE "\"${DLL_OUTPUT_PATH}/fmu1_dll_me${CMAKE_SHARED_MODULE_SUFFIX}\"")
set(DLL_OUTPUT_PATH_CS_DEFINE "\"${DLL_OUTPUT_PATH}/fmu1_dll_cs${CMAKE_SHARED_MODULE_SUFFIX}\"")
STRING(REPLACE "/" "\\\\" DLL_OUTPUT_PATH_ME_DEFINE "${DLL_OUTPUT_PATH_ME_DEFINE}")
STRING(REPLACE "/" "\\\\" DLL_OUTPUT_PATH_CS_DEFINE "${DLL_OUTPUT_PATH_CS_DEFINE}")

STRING(REPLACE "/" "\\\\" UNCOMPRESSED_DUMMY_FILE_PATH_SRC "${UNCOMPRESSED_DUMMY_FILE_PATH_SRC}")
STRING(REPLACE "/" "\\\\" UNCOMPRESSED_DUMMY_FILE_PATH_DIST "${UNCOMPRESSED_DUMMY_FILE_PATH_DIST}")
STRING(REPLACE "/" "\\\\" UNCOMPRESSED_DUMMY_FOLDER_PATH_DIST "${UNCOMPRESSED_DUMMY_FOLDER_PATH_DIST}")
STRING(REPLACE "/" "\\\\" COMPRESS_DUMMY_FILE_PATH_SRC "${COMPRESS_DUMMY_FILE_PATH_SRC}")
STRING(REPLACE "/" "\\\\" COMPRESS_DUMMY_FILE_PATH_DIST "${COMPRESS_DUMMY_FILE_PATH_DIST}")
else(WIN32)
set(DLL_OUTPUT_PATH_ME_DEFINE "\"${TEST_OUTPUT_FOLDER}/${CMAKE_SHARED_LIBRARY_PREFIX}fmu1_dll_me${CMAKE_SHARED_MODULE_SUFFIX}\"")
set(DLL_OUTPUT_PATH_CS_DEFINE "\"${TEST_OUTPUT_FOLDER}/${CMAKE_SHARED_LIBRARY_PREFIX}fmu1_dll_cs${CMAKE_SHARED_MODULE_SUFFIX}\"")
endif(WIN32)
set(FMU1_DLL_ME_PATH "${DLL_OUTPUT_PATH_ME_DEFINE}")
set(FMU1_DLL_CS_PATH "${DLL_OUTPUT_PATH_CS_DEFINE}")

#Move files and compress them to an FMU
function(compress_fmu OUTPUT_FOLDER_T MODEL_IDENTIFIER_T FILE_NAME_CS_ME_EXT_T TARGET_NAME_T XML_PATH_T SHARED_LIBRARY_PATH_T)
	set(FMU_OUTPUT_FOLDER_T ${OUTPUT_FOLDER_T}/${MODEL_IDENTIFIER_T}_${FILE_NAME_CS_ME_EXT_T})
	add_dependencies(${TARGET_NAME_T} compress_test_fmu_zip) #Make sure the compress_test_fmu_zip.exe is created and can be used to compress the FMU
	#Detect platform
	IF(WIN32)
		IF(CMAKE_CL_64)
		set(PLATFORM_T win64)
		ELSE(CMAKE_CL_64)
		set(PLATFORM_T win32)
		ENDIF(CMAKE_CL_64)
	ELSE(WIN32)
		IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
			set(PLATFORM_T linux32)
		# Regular x86
		ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
			set(PLATFORM_T linux64)
		# AMD64:
		ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
	endif(WIN32)
	set(FMU_OUTPUT_SHARED_LIBRARY_PATH_T ${FMU_OUTPUT_FOLDER_T}/binaries/${PLATFORM_T}/${MODEL_IDENTIFIER_T}${CMAKE_SHARED_MODULE_SUFFIX})

	#Must create the FMU directory in a separate command..
	ADD_CUSTOM_COMMAND(
		TARGET ${TARGET_NAME_T}
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory ${FMU_OUTPUT_FOLDER_T}/binaries/${PLATFORM_T}
	)

	file(TO_NATIVE_PATH binaries/${PLATFORM_T}/${MODEL_IDENTIFIER_T}${CMAKE_SHARED_MODULE_SUFFIX} FMU_OUTPUT_SHARED_LIBRARY_PATH_OUT_T)

	#Move files to the FMU directories and compress 
	ADD_CUSTOM_COMMAND(
	   TARGET ${TARGET_NAME_T}
	   POST_BUILD
	   COMMAND "${CMAKE_COMMAND}" -E copy "${XML_PATH_T}" "${FMU_OUTPUT_FOLDER_T}/modelDescription.xml"
	   COMMAND "${CMAKE_COMMAND}" -E copy "${SHARED_LIBRARY_PATH_T}" "${FMU_OUTPUT_SHARED_LIBRARY_PATH_T}"
	   COMMAND "${COMPRESS_EXECUTABLE}" "${MODEL_IDENTIFIER_T}.fmu" "modelDescription.xml" "${FMU_OUTPUT_SHARED_LIBRARY_PATH_OUT_T}" WORKING_DIRECTORY "${FMU_OUTPUT_FOLDER_T}"
	   COMMAND "${CMAKE_COMMAND}" -E copy "${FMU_OUTPUT_FOLDER_T}/${MODEL_IDENTIFIER_T}.fmu" "${OUTPUT_FOLDER_T}/${MODEL_IDENTIFIER_T}_${FILE_NAME_CS_ME_EXT_T}.fmu"
	)

	#These lines does not work on the Monster with VS2005, returns error "Cannot remove directory..." 
	#ADD_CUSTOM_COMMAND(
	#   TARGET ${TARGET_NAME_T}
	#   POST_BUILD
	#   COMMAND "${CMAKE_COMMAND}" -E remove_directory ${FMU_OUTPUT_FOLDER_T}
	#)

endfunction(compress_fmu)

#function(compress_fmu OUTPUT_FOLDER MODEL_IDENTIFIER FILE_NAME_CS_ME_EXT TARGET_NAME XML_PATH SHARED_LIBRARY_PATH)
compress_fmu("${TEST_OUTPUT_FOLDER}" "${FMU_DUMMY_ME_MODEL_IDENTIFIER}" "me" "fmu1_dll_me" "${XML_ME_PATH}" "${SHARED_LIBRARY_ME_PATH}")
compress_fmu("${TEST_OUTPUT_FOLDER}" "${FMU_DUMMY_CS_MODEL_IDENTIFIER}" "cs" "fmu1_dll_cs" "${XML_CS_PATH}" "${SHARED_LIBRARY_CS_PATH}")

add_executable (fmi_zip_zip_test ${RTTESTDIR}/fmi_zip_zip_test.c )
target_link_libraries (fmi_zip_zip_test ${FMIZIP_LIBRARIES})

add_executable (fmi_zip_unzip_test ${RTTESTDIR}/fmi_zip_unzip_test.c )
target_link_libraries (fmi_zip_unzip_test ${FMIZIP_LIBRARIES})

add_executable (fmi_import_test ${RTTESTDIR}/fmi_import_test.c)
target_link_libraries (fmi_import_test  ${FMICAPI_LIBRARIES} ${FMIXML_LIBRARIES} ${FMIZIP_LIBRARIES} ${FMIIMPORT_LIBRARIES} ${JMUTIL_LIBRARIES})
add_executable (fmi_import_me_test ${RTTESTDIR}/fmi_import_me_test.c)
target_link_libraries (fmi_import_me_test  ${FMICAPI_LIBRARIES} ${FMIXML_LIBRARIES} ${FMIZIP_LIBRARIES} ${FMIIMPORT_LIBRARIES} ${JMUTIL_LIBRARIES})
add_executable (fmi_import_cs_test ${RTTESTDIR}/fmi_import_cs_test.c)
target_link_libraries (fmi_import_cs_test  ${FMICAPI_LIBRARIES} ${FMIXML_LIBRARIES} ${FMIZIP_LIBRARIES} ${FMIIMPORT_LIBRARIES} ${JMUTIL_LIBRARIES})


ENABLE_TESTING()

#Define values in the "config.h"
set(CTEST_RETURN_SUCCESS 0) 
set(CTEST_RETURN_FAIL 1)

set(FMU_ME_PATH ${TEST_OUTPUT_FOLDER}/${FMU_DUMMY_ME_MODEL_IDENTIFIER}_me.fmu)
set(FMU_CS_PATH ${TEST_OUTPUT_FOLDER}/${FMU_DUMMY_CS_MODEL_IDENTIFIER}_cs.fmu)
set(FMU_TEMPFOLDER ${TEST_OUTPUT_FOLDER}/tempfolder)
file(MAKE_DIRECTORY ${FMU_TEMPFOLDER})

ADD_TEST(ctest_fmi_import_test ${EXECUTABLE_OUTPUT_PATH}/fmi_import_test ${FMU_ME_PATH} ${FMU_TEMPFOLDER})
ADD_TEST(ctest_fmi_import_me_test ${EXECUTABLE_OUTPUT_PATH}/fmi_import_me_test ${FMU_ME_PATH} ${FMU_TEMPFOLDER})
ADD_TEST(ctest_fmi_import_cs_test ${EXECUTABLE_OUTPUT_PATH}/fmi_import_cs_test ${FMU_CS_PATH} ${FMU_TEMPFOLDER})

ADD_TEST(ctest_fmi_zip_unzip_test ${EXECUTABLE_OUTPUT_PATH}/fmi_zip_unzip_test)
ADD_TEST(ctest_fmi_zip_zip_test ${EXECUTABLE_OUTPUT_PATH}/fmi_zip_zip_test)
ADD_TEST(ctest_fmi1_capi_cs_test ${EXECUTABLE_OUTPUT_PATH}/fmi1_capi_cs_test)
ADD_TEST(ctest_fmi1_capi_me_test ${EXECUTABLE_OUTPUT_PATH}/fmi1_capi_me_test)
                              
