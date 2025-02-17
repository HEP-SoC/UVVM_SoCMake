#include "CRC.h"
#include <iostream>

extern "C" uint32_t crc_dpi(uint32_t data, uint32_t initial_value);

uint32_t crc_dpi(uint32_t data, uint32_t initial_value)
{
    CRC::Parameters<crcpp_uint32, 32> crc_params;
    crc_params.initialValue = initial_value;
    crc_params.polynomial = 0x04c11db7;
    crc_params.reflectInput = 0;
    crc_params.reflectOutput = 0;
    crc_params.finalXOR = 0;

    return CRC::Calculate(&data, 1, crc_params);
}
