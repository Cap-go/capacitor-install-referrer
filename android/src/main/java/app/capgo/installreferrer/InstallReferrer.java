package app.capgo.installreferrer;

import android.content.Context;
import android.os.RemoteException;
import com.android.installreferrer.api.InstallReferrerClient;
import com.android.installreferrer.api.InstallReferrerStateListener;
import com.android.installreferrer.api.ReferrerDetails;
import com.getcapacitor.JSObject;
import java.util.concurrent.atomic.AtomicBoolean;

public class InstallReferrer {

    public interface ReferrerCallback {
        void onSuccess(JSObject result);
        void onError(String code, String message, Exception error);
    }

    public void getReferrer(Context context, ReferrerCallback callback) {
        InstallReferrerClient client = InstallReferrerClient.newBuilder(context).build();
        AtomicBoolean completed = new AtomicBoolean(false);

        client.startConnection(
            new InstallReferrerStateListener() {
                @Override
                public void onInstallReferrerSetupFinished(int responseCode) {
                    switch (responseCode) {
                        case InstallReferrerClient.InstallReferrerResponse.OK:
                            resolveReferrer(client, completed, callback);
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED:
                            finishWithError(
                                client,
                                completed,
                                callback,
                                "FEATURE_NOT_SUPPORTED",
                                "Google Play Install Referrer API is not available on this Play Store app.",
                                null
                            );
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE:
                            finishWithError(
                                client,
                                completed,
                                callback,
                                "SERVICE_UNAVAILABLE",
                                "Could not connect to the Google Play Install Referrer service.",
                                null
                            );
                            break;
                        default:
                            finishWithError(
                                client,
                                completed,
                                callback,
                                "UNEXPECTED_RESPONSE",
                                "Unexpected Google Play Install Referrer response code: " + responseCode,
                                null
                            );
                            break;
                    }
                }

                @Override
                public void onInstallReferrerServiceDisconnected() {
                    finishWithError(
                        client,
                        completed,
                        callback,
                        "SERVICE_DISCONNECTED",
                        "Google Play Install Referrer service disconnected before returning a result.",
                        null
                    );
                }
            }
        );
    }

    public String getPluginVersion() {
        return "native";
    }

    private void resolveReferrer(InstallReferrerClient client, AtomicBoolean completed, ReferrerCallback callback) {
        try {
            ReferrerDetails details = client.getInstallReferrer();
            JSObject result = new JSObject();
            result.put("platform", "android");
            result.put("referrer", details.getInstallReferrer());
            result.put("clickTimestampSeconds", details.getReferrerClickTimestampSeconds());
            result.put("installBeginTimestampSeconds", details.getInstallBeginTimestampSeconds());
            result.put("googlePlayInstantParam", details.getGooglePlayInstantParam());
            finishWithSuccess(client, completed, callback, result);
        } catch (RemoteException exception) {
            finishWithError(
                client,
                completed,
                callback,
                "REMOTE_EXCEPTION",
                "Could not read Google Play Install Referrer details.",
                exception
            );
        } catch (RuntimeException exception) {
            finishWithError(client, completed, callback, "INSTALL_REFERRER_ERROR", "Google Play Install Referrer failed.", exception);
        }
    }

    private void finishWithSuccess(InstallReferrerClient client, AtomicBoolean completed, ReferrerCallback callback, JSObject result) {
        if (!completed.compareAndSet(false, true)) {
            return;
        }
        close(client);
        callback.onSuccess(result);
    }

    private void finishWithError(
        InstallReferrerClient client,
        AtomicBoolean completed,
        ReferrerCallback callback,
        String code,
        String message,
        Exception error
    ) {
        if (!completed.compareAndSet(false, true)) {
            return;
        }
        close(client);
        callback.onError(code, message, error);
    }

    private void close(InstallReferrerClient client) {
        try {
            client.endConnection();
        } catch (RuntimeException ignored) {}
    }
}
