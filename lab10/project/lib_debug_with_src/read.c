#include "read.h"

uint8_t read8(uint32_t from)
{
    return (*((volatile uint8_t*)from));
}
