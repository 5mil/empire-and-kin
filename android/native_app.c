/* Minimal NativeActivity glue for Empire & Kin (Phase B host).
 *
 * Build with NDK after producing libempire.so:
 *   clang --target=aarch64-linux-android24 ... -lempire -o unused
 * Prefer linking this object into the same .so or a small wrapper library
 * named "empire" so AndroidManifest meta-data android.app.lib_name=empire works.
 *
 * Flow:
 *   APP_CMD_INIT_WINDOW → empire_gles_attach(window, w, h)
 *   motion events → empire_touch / empire_touch2
 *   APP_CMD_TERM_WINDOW → empire_gles_detach
 *
 * Full game loop embedding is still optional: host can call into Zig main later.
 */

#include <android/native_activity.h>
#include <android/native_window.h>
#include <android/log.h>
#include <android/input.h>
#include <stdint.h>

#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "EmpireKin", __VA_ARGS__)

/* From libempire.so (Zig exports) */
extern uint32_t empire_abi_version(void);
extern uint8_t empire_gles_attach(void *window, uint32_t width, uint32_t height);
extern void empire_gles_detach(void);
extern void empire_touch(float x_norm, float y_norm, uint8_t down);
extern void empire_touch2(float x_norm, float y_norm, uint8_t down);
extern void empire_touch_clear(void);
extern void empire_gles_request_close(void);

static ANativeWindow *g_window = 0;
static int g_w = 0, g_h = 0;

static void attach_if_ready(void) {
    if (!g_window) return;
    g_w = ANativeWindow_getWidth(g_window);
    g_h = ANativeWindow_getHeight(g_window);
    if (empire_gles_attach((void *)g_window, (uint32_t)g_w, (uint32_t)g_h)) {
        LOGI("GLES attached %dx%d abi=%u", g_w, g_h, (unsigned)empire_abi_version());
    } else {
        LOGI("GLES attach FAILED");
    }
}

static void on_app_cmd(ANativeActivity *activity, int32_t cmd) {
    (void)activity;
    switch (cmd) {
    case APP_CMD_INIT_WINDOW:
        /* window set by onNativeWindowCreated below in fuller templates */
        break;
    case APP_CMD_TERM_WINDOW:
        empire_gles_detach();
        g_window = 0;
        break;
    default:
        break;
    }
}

static void onNativeWindowCreated(ANativeActivity *activity, ANativeWindow *window) {
    (void)activity;
    g_window = window;
    attach_if_ready();
}

static void onNativeWindowDestroyed(ANativeActivity *activity, ANativeWindow *window) {
    (void)activity;
    (void)window;
    empire_gles_detach();
    g_window = 0;
}

static int32_t onInput(ANativeActivity *activity, AInputEvent *event) {
    (void)activity;
    if (AInputEvent_getType(event) != AINPUT_EVENT_TYPE_MOTION) return 0;
    const int action = AMotionEvent_getAction(event) & AMOTION_EVENT_ACTION_MASK;
    const int count = (int)AMotionEvent_getPointerCount(event);
    if (g_w <= 0 || g_h <= 0) return 0;

    if (action == AMOTION_EVENT_ACTION_UP || action == AMOTION_EVENT_ACTION_CANCEL) {
        empire_touch_clear();
        return 1;
    }

    /* Finger 0 → stick / primary; finger 1 → actions */
    if (count >= 1) {
        float x = AMotionEvent_getX(event, 0) / (float)g_w;
        float y = AMotionEvent_getY(event, 0) / (float)g_h;
        empire_touch(x, y, 1);
    }
    if (count >= 2) {
        float x = AMotionEvent_getX(event, 1) / (float)g_w;
        float y = AMotionEvent_getY(event, 1) / (float)g_h;
        empire_touch2(x, y, 1);
    }
    return 1;
}

void ANativeActivity_onCreate(ANativeActivity *activity,
                              void *savedState, size_t savedStateSize) {
    (void)savedState;
    (void)savedStateSize;
    LOGI("ANativeActivity_onCreate");
    activity->callbacks->onNativeWindowCreated = onNativeWindowCreated;
    activity->callbacks->onNativeWindowDestroyed = onNativeWindowDestroyed;
    activity->callbacks->onInputEvent = onInput;
    (void)on_app_cmd;
}
