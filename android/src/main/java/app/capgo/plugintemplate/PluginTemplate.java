package app.capgo.plugintemplate;

import com.getcapacitor.Logger;

public class PluginTemplate {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }

    public String getPluginVersion() {
        return "native";
    }
}
