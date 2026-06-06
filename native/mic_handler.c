#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"
#include <math.h>

ma_device device;
float current_amplitude = 0.0f;
int is_running = 0;

void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount) {
    if (pInput == NULL) return;
    const float* pInputF32 = (const float*)pInput;
    float sum = 0.0f;
    for (ma_uint32 i = 0; i < frameCount; ++i) {
        sum += pInputF32[i] * pInputF32[i];
    }
    float rms = sqrtf(sum / frameCount);
    current_amplitude = rms;
}

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

EXPORT int init_mic() {
    if (is_running) return 0;
    
    ma_device_config deviceConfig = ma_device_config_init(ma_device_type_capture);
    deviceConfig.capture.format   = ma_format_f32;
    deviceConfig.capture.channels = 1;
    deviceConfig.sampleRate       = 44100;
    deviceConfig.dataCallback     = data_callback;

    if (ma_device_init(NULL, &deviceConfig, &device) != MA_SUCCESS) {
        return -1;
    }
    if (ma_device_start(&device) != MA_SUCCESS) {
        ma_device_uninit(&device);
        return -2;
    }
    is_running = 1;
    return 0;
}

EXPORT float get_amplitude() {
    return current_amplitude;
}

EXPORT void stop_mic() {
    if (!is_running) return;
    ma_device_uninit(&device);
    is_running = 0;
    current_amplitude = 0.0f;
}
