package ir.tapsell.godot;

import android.app.Activity;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.HashSet;
import java.util.Set;

import ir.tapsell.plus.AdRequestCallback;
import ir.tapsell.plus.AdShowListener;
import ir.tapsell.plus.TapsellPlus;
import ir.tapsell.plus.TapsellPlusBannerType;
import ir.tapsell.plus.TapsellPlusInitListener;
import ir.tapsell.plus.model.AdNetworkError;
import ir.tapsell.plus.model.AdNetworks;
import ir.tapsell.plus.model.TapsellPlusAdModel;
import ir.tapsell.plus.model.TapsellPlusErrorModel;

public class TapsellGodotPlugin extends GodotPlugin {
    private static final String TAG = "TapsellGodot";

    private String lastRewardedResponseId = "";
    private String lastBannerResponseId = "";
    private FrameLayout bannerContainer = null;

    public TapsellGodotPlugin(Godot godot) {
        super(godot);
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "TapsellGodot";
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new HashSet<>();
        // Initialization signals
        signals.add(new SignalInfo("init_success", String.class));
        signals.add(new SignalInfo("init_failed", String.class));

        // Rewarded Video signals
        signals.add(new SignalInfo("rewarded_video_response", String.class));
        signals.add(new SignalInfo("rewarded_video_error", String.class));
        signals.add(new SignalInfo("rewarded_video_opened"));
        signals.add(new SignalInfo("rewarded_video_closed"));
        signals.add(new SignalInfo("rewarded_video_rewarded"));

        // Standard Banner 320x50 signals
        signals.add(new SignalInfo("banner_response", String.class));
        signals.add(new SignalInfo("banner_error", String.class));
        signals.add(new SignalInfo("banner_opened"));
        signals.add(new SignalInfo("banner_closed"));

        return signals;
    }

    // ==========================================
    // Initialization
    // ==========================================

    @UsedByGodot
    public void initialize(String appKey) {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "Activity is null during initialize");
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                Log.d(TAG, "Initializing TapsellPlus with key: " + appKey);
                TapsellPlus.setDebugMode(Log.DEBUG);
                TapsellPlus.initialize(activity, appKey, new TapsellPlusInitListener() {
                    @Override
                    public void onInitializeSuccess(AdNetworks adNetworks) {
                        Log.d(TAG, "TapsellPlus initialized successfully");
                        emitSignal("init_success", adNetworks != null ? adNetworks.toString() : "Success");
                    }

                    @Override
                    public void onInitializeFailed(AdNetworks adNetworks, AdNetworkError adNetworkError) {
                        String errMsg = adNetworkError != null ? adNetworkError.getErrorMessage() : "Unknown error";
                        Log.e(TAG, "TapsellPlus initialization failed: " + errMsg);
                        emitSignal("init_failed", errMsg);
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Exception during initialize", e);
                emitSignal("init_failed", e.getMessage() != null ? e.getMessage() : "Exception");
            }
        });
    }

    @UsedByGodot
    public void setDebugMode(int mode) {
        TapsellPlus.setDebugMode(mode);
    }

    // ==========================================
    // Rewarded Video
    // ==========================================

    @UsedByGodot
    public void requestRewardedVideo(String zoneId) {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "Activity is null during requestRewardedVideo");
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                Log.d(TAG, "Requesting rewarded video for zone: " + zoneId);
                TapsellPlus.requestRewardedVideoAd(activity, zoneId, new AdRequestCallback() {
                    @Override
                    public void response(TapsellPlusAdModel model) {
                        lastRewardedResponseId = model.getResponseId();
                        Log.d(TAG, "Rewarded video response received: " + lastRewardedResponseId);
                        emitSignal("rewarded_video_response", lastRewardedResponseId);
                    }

                    @Override
                    public void error(String message) {
                        Log.e(TAG, "Rewarded video request error: " + message);
                        emitSignal("rewarded_video_error", message != null ? message : "Unknown error");
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Exception during requestRewardedVideo", e);
                emitSignal("rewarded_video_error", e.getMessage() != null ? e.getMessage() : "Exception");
            }
        });
    }

    @UsedByGodot
    public void showRewardedVideo(String responseId) {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "Activity is null during showRewardedVideo");
            return;
        }

        final String resId = (responseId != null && !responseId.isEmpty()) ? responseId : lastRewardedResponseId;
        if (resId == null || resId.isEmpty()) {
            emitSignal("rewarded_video_error", "No valid responseId to show");
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                Log.d(TAG, "Showing rewarded video for response: " + resId);
                TapsellPlus.showRewardedVideoAd(activity, resId, new AdShowListener() {
                    @Override
                    public void onOpened(TapsellPlusAdModel model) {
                        Log.d(TAG, "Rewarded video opened");
                        emitSignal("rewarded_video_opened");
                    }

                    @Override
                    public void onClosed(TapsellPlusAdModel model) {
                        Log.d(TAG, "Rewarded video closed");
                        emitSignal("rewarded_video_closed");
                    }

                    @Override
                    public void onRewarded(TapsellPlusAdModel model) {
                        Log.d(TAG, "Rewarded video rewarded");
                        emitSignal("rewarded_video_rewarded");
                    }

                    @Override
                    public void onError(TapsellPlusErrorModel error) {
                        String errMsg = error != null ? error.getErrorMessage() : "Error showing ad";
                        Log.e(TAG, "Rewarded video show error: " + errMsg);
                        emitSignal("rewarded_video_error", errMsg);
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Exception during showRewardedVideo", e);
                emitSignal("rewarded_video_error", e.getMessage() != null ? e.getMessage() : "Exception");
            }
        });
    }

    // ==========================================
    // Standard Banner 320x50
    // ==========================================

    @UsedByGodot
    public void requestStandardBanner(String zoneId) {
        requestBanner(zoneId);
    }

    @UsedByGodot
    public void requestBanner(String zoneId) {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "Activity is null during requestBanner");
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                Log.d(TAG, "Requesting standard banner (320x50) for zone: " + zoneId);
                TapsellPlus.requestStandardBannerAd(activity, zoneId, TapsellPlusBannerType.BANNER_320x50, new AdRequestCallback() {
                    @Override
                    public void response(TapsellPlusAdModel model) {
                        lastBannerResponseId = model.getResponseId();
                        Log.d(TAG, "Standard banner response received: " + lastBannerResponseId);
                        emitSignal("banner_response", lastBannerResponseId);
                    }

                    @Override
                    public void error(String message) {
                        Log.e(TAG, "Standard banner request error: " + message);
                        emitSignal("banner_error", message != null ? message : "Unknown error");
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Exception during requestBanner", e);
                emitSignal("banner_error", e.getMessage() != null ? e.getMessage() : "Exception");
            }
        });
    }

    @UsedByGodot
    public void showStandardBanner(String responseId) {
        showBanner(responseId);
    }

    @UsedByGodot
    public void showBanner(String responseId) {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "Activity is null during showBanner");
            return;
        }

        final String resId = (responseId != null && !responseId.isEmpty()) ? responseId : lastBannerResponseId;
        if (resId == null || resId.isEmpty()) {
            emitSignal("banner_error", "No valid responseId to show");
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                if (bannerContainer == null) {
                    bannerContainer = new FrameLayout(activity);
                    FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.WRAP_CONTENT,
                        FrameLayout.LayoutParams.WRAP_CONTENT
                    );
                    params.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;

                    ViewGroup root = (ViewGroup) activity.findViewById(android.R.id.content);
                    if (root != null) {
                        root.addView(bannerContainer, params);
                    }
                } else {
                    bannerContainer.removeAllViews();
                    bannerContainer.setVisibility(View.VISIBLE);
                }

                bannerContainer.bringToFront();
                bannerContainer.requestLayout();

                Log.d(TAG, "Showing standard banner (320x50) for response: " + resId);
                TapsellPlus.showStandardBannerAd(activity, resId, bannerContainer, new AdShowListener() {
                    @Override
                    public void onOpened(TapsellPlusAdModel model) {
                        Log.d(TAG, "Standard banner opened");
                        emitSignal("banner_opened");
                    }

                    @Override
                    public void onClosed(TapsellPlusAdModel model) {
                        Log.d(TAG, "Standard banner closed");
                        emitSignal("banner_closed");
                    }

                    @Override
                    public void onRewarded(TapsellPlusAdModel model) {}

                    @Override
                    public void onError(TapsellPlusErrorModel error) {
                        String errMsg = error != null ? error.getErrorMessage() : "Error showing banner";
                        Log.e(TAG, "Standard banner show error: " + errMsg);
                        emitSignal("banner_error", errMsg);
                    }
                });
            } catch (Exception e) {
                Log.e(TAG, "Exception during showBanner", e);
                emitSignal("banner_error", e.getMessage() != null ? e.getMessage() : "Exception");
            }
        });
    }

    @UsedByGodot
    public void destroyStandardBanner() {
        destroyBanner();
    }

    @UsedByGodot
    public void hideBanner() {
        destroyBanner();
    }

    @UsedByGodot
    public void destroyBanner() {
        Activity activity = getActivity();
        if (activity == null || bannerContainer == null) return;

        activity.runOnUiThread(() -> {
            try {
                if (lastBannerResponseId != null && !lastBannerResponseId.isEmpty()) {
                    TapsellPlus.destroyStandardBanner(activity, lastBannerResponseId, bannerContainer);
                }
                ViewGroup root = (ViewGroup) activity.findViewById(android.R.id.content);
                if (root != null) {
                    root.removeView(bannerContainer);
                }
                bannerContainer = null;
                lastBannerResponseId = "";
            } catch (Exception e) {
                Log.e(TAG, "Exception during destroyBanner", e);
            }
        });
    }
}
