SET(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
SET(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m3 -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m3 -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs" CACHE INTERNAL "shared linker flags")

SET(STM32_CHIP_TYPES 205xB 205xC 205xE 205xF 205xG 215xE 215xG 207xC 207xE 207xF 207xG 217xE 217xG)
SET(STM32_CODES "205.B" "205.C" "205.E" "205.F" "205.G" "215.E" "215.G" "207.C" "207.E" "207.F" "207.G" "217.E" "217.G")

MACRO(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF](2[01]7.[BCDEFG]).+$" "\\1" STM32_CODE ${CHIP})
    SET(INDEX 0)
    FOREACH(C_TYPE ${STM32_CHIP_TYPES})
        LIST(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        IF(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            SET(RESULT_TYPE ${C_TYPE})
        ENDIF()
        MATH(EXPR INDEX "${INDEX}+1")
    ENDFOREACH()
    SET(${CHIP_TYPE} ${RESULT_TYPE})
ENDMACRO()

MACRO(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF]2[01]7.([BCDEFG])" "\\1" STM32_SIZE_CODE ${CHIP})

    IF(STM32_SIZE_CODE STREQUAL "B")
        SET(FLASH "128K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "C")
        SET(FLASH "256K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "D")
        SET(FLASH "384K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "E")
        SET(FLASH "512K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "F")
        SET(FLASH "768K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "G")
        SET(FLASH "1024K")
    ENDIF()

    STM32_GET_CHIP_TYPE(${CHIP} TYPE)

    SET(RAM "128K")

    IF(${TYPE} STREQUAL 205xC)
        SET(RAM "96K")
    ELSEIF(${TYPE} STREQUAL 205xB)
        SET(RAM "64K")
    ENDIF()

    SET(${FLASH_SIZE} ${FLASH})
    SET(${RAM_SIZE} ${RAM})
ENDMACRO()

FUNCTION(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F2 chip type: ${CHIP_TYPE}")
    ENDIF()

    STRING(REGEX REPLACE "^(2[01]7).[BCDEFG]" "\\1" DEVICE_NUM ${STM32_CHIP_TYPE})

    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    IF(TARGET_DEFS)
        SET(TARGET_DEFS "STM32F2;STM32F${DEVICE_NUM}xx;${TARGET_DEFS}")
    ELSE()
        SET(TARGET_DEFS "STM32F2;STM32F${DEVICE_NUM}xx")
    ENDIF()
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()