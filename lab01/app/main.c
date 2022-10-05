#include "utils_ctboard.h"

#define LED_ADDR 0x60000100
#define READ_ADDR 0x60000200

#define P11_ADDR 0x60000211
#define DS0_ADDR 0x60000110

int main(void)
{
	uint8_t display[16] = {0};
	display[0] = 0b11000000;
	display[1] = 0b11111001;
	display[2] = 0b10100100;
	display[3] = 0b10110000;
	display[4] = 0b10011001;
	display[5] = 0b10010010;
	display[6] = 0b10000010;
	display[7] = 0b11111000;
	display[8] = 0b10000000;
	display[9] = 0b10010000;
	/* A */
	display[10] = 0b10001000;
	/* b */
	display[11] = 0b10000011;
	/* C */
	display[12] = 0b11000110;
	/* d */
	display[13] = 0b10100001;
	/* E */
	display[14] = 0b10000110;
	/* F */
	display[15] = 0b10001110;

	while (1)
	{
		/* read from P11 and mask the value with 0x0F*/
		uint8_t val = read_byte(P11_ADDR) & 0x0f;
		// 0000 0000

		/* write to DS0 with the inverted display value
		because the seven segment display is "active low" */
		write_byte(DS0_ADDR, display[val]);

		/* for test purposes read current P11 value and write to LEDs */
		write_byte(LED_ADDR, val);
	}
}
