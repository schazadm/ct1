/* ------------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zuercher Hochschule Winterthur   -
 * --  _| |_| | | | |____ ____) |  (University of Applied Sciences) -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- Project     : CT2 lab - Linking
 * --
 * -- $Id$
 * ------------------------------------------------------------------
 */

// Tasks:
// 1. compile without change --> *include* path error (and others)
// 2. fix include path error, i.e. adjust the project properties for C/C++ to
//    also use the local .\inc path for includes

// 3. compile and link --> *compiler* errors
// 4. fix all *compiler* errors, i.e. fix missing includes in main.c

// 4. compile and link --> *linker* errors
// 5. adjust the project properties for Linker to also link with the
//    library lib\read_write.lib

// 6. compile and link --> fix remaining errors if any


#include <stdint.h>

// add missing includes
/// STUDENTS: To be programmed
#include <read.h>
#include "toggle.h"

/// END: To be programmed

#define BUTTONS 0x60000210
#define T0      (1 << 0)

static uint8_t last = 0;

int main()
{
    while(1) {
        uint8_t buttons = read8(BUTTONS);
        uint8_t pressed_T0 = (~last & buttons) & T0;
        last = buttons;
        
        if (pressed_T0) {
            toggle();
        }
    }
}
