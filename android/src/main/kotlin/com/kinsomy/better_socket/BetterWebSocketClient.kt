package com.kinsomy.better_socket

import android.os.Handler
import android.os.Message
import android.util.Log
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake
import java.lang.Exception
import java.net.URI

class BetterWebSocketClient(uri: URI, var queuingEventSink: QueuingEventSink) : WebSocketClient(uri) {


    var handler: Handler = Handler {
        queuingEventSink.success(it.obj)
        false
    }

    override fun onOpen(handshakedata: ServerHandshake?) {
        Log.i("onOpen", "onOpen")

        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onOpen"
        eventResult["code"] = 0
        eventResult["httpStatus"] = handshakedata?.httpStatus.toString()
        eventResult["httpStatusMessage"] = handshakedata?.httpStatusMessage.toString()

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)

    }

    override fun onClose(code: Int, reason: String?, remote: Boolean) {
        Log.i("onClose", reason)

        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onClose"
        eventResult["code"] = code
        eventResult["reason"] = reason.toString()
        eventResult["remote"] = remote

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)


    }

    override fun onMessage(message: String?) {
        Log.i("onMessage", message)
        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onMessage"
        eventResult["message"] = message.toString()

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)
    }

    override fun onError(ex: Exception?) {
        Log.i("onError", ex?.message)
        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onError"
        eventResult["message"] = ex?.message.toString()

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)
    }

}