package com.xtheon.RNAudio;

import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.os.Environment;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

public class AudioPlayer extends ReactContextBaseJavaModule {

    ReactApplicationContext context;

    private MediaPlayer mPlayer = null;

    public AudioPlayer(ReactApplicationContext context) {
        super(context);
        this.context = context;
    }

    @Override
    public String getName() {
        return "AudioPlayerManager";
    }

    @ReactMethod
    public void startPlaying(final String fileName, Promise promise) {
        mPlayer = new MediaPlayer();
        try {
            mPlayer.setDataSource(fileName + ".3gp");
            mPlayer.prepare();
            mPlayer.setOnCompletionListener(new OnCompletionListener(){
                @Override
                public void onCompletion(MediaPlayer mp){
                    sendEvent("playerFinished", true);
                }
            });
            mPlayer.start();
            promise.resolve("started recording");
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void stopPlaying() {
        mPlayer.release();
        mPlayer = null;
    }

    private void sendEvent(String eventName, Boolean params) {
        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("DocumentDirectoryPath", Environment.getExternalStorageDirectory().getAbsolutePath());
        return constants;
    }
}
