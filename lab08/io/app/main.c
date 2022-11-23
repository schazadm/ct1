#include <stdint.h>

#define LED_ADDR 0x60000100
#define READ_ADDR 0x60000200

extern uint32_t in_word(uint32_t input_addr);
extern void out_word(uint32_t val, uint32_t output_addr);

int main(int argc, char *argv[])
{
    while (1)
    {
        uint32_t inputVal = in_word(READ_ADDR);
        out_word(inputVal, LED_ADDR);
    }
}
