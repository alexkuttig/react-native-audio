package com.xtheon.RNAudio;

import android.media.MediaRecorder;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.IOException;

import javax.annotation.Nullable;

public class AudioRecorder extends ReactContextBaseJavaModule {

    ReactApplicationContext context;

    private MediaRecorder mRecorder = null;

    public AudioRecorder(ReactApplicationContext context) {
        super(context);
        this.context = context;
    }

    @Override
    public String getName() {
        return "AudioRecorderManager";
    }

    @ReactMethod
    public void startRecording(final String fileName, Promise promise) {
        mRecorder = new MediaRecorder();
        mRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mRecorder.setOutputFile(fileName + ".3gp");
        mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

        try {
            mRecorder.prepare();
            mRecorder.start();
            promise.resolve("started recording");
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void stopRecording(){
        mRecorder.stop();
        mRecorder.release();
        mRecorder = null;
    }
}
