#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

FFI_PLUGIN_EXPORT intptr_t sum(intptr_t a, intptr_t b);
FFI_PLUGIN_EXPORT int init_mic();
FFI_PLUGIN_EXPORT float get_amplitude();
FFI_PLUGIN_EXPORT void stop_mic();
