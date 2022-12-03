#include "write.h"

void write8(uint32_t to, uint8_t what)
{
    (*((volatile uint8_t*)to)) = what;
}

