#include <errno.h>
#include <stddef.h>
#include <stdint.h>

extern uint8_t _end;

void *_sbrk(ptrdiff_t incr)
{
    static uint8_t *heap_end;
    uint8_t *prev_heap_end;

    if (heap_end == 0) {
        heap_end = &_end;
    }

    prev_heap_end = heap_end;
    heap_end += incr;

    return prev_heap_end;
}
