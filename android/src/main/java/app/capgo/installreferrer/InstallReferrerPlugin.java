package app.capgo.installreferrer;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "InstallReferrer")
public class InstallReferrerPlugin extends Plugin {

    private final InstallReferrer implementation = new InstallReferrer();

    @PluginMethod
    public void getReferrer(PluginCall call) {
        implementation.getReferrer(
            getContext(),
            new InstallReferrer.ReferrerCallback() {
                @Override
                public void onSuccess(JSObject result) {
                    call.resolve(result);
                }

                @Override
                public void onError(String code, String message, Exception error) {
                    Exception resolvedError = error != null ? error : new Exception(message);
                    call.reject(message, code, resolvedError);
                }
            }
        );
    }

    @PluginMethod
    public void GetReferrer(PluginCall call) {
        getReferrer(call);
    }

    @PluginMethod
    public void getPluginVersion(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("version", implementation.getPluginVersion());
        call.resolve(ret);
    }
}
