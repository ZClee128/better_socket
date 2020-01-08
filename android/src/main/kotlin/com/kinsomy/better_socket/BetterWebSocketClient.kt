package com.kinsomy.better_socket

import android.os.Handler
import android.os.Message
import org.java_websocket.client.WebSocketClient
import org.java_websocket.drafts.Draft
import org.java_websocket.drafts.Draft_6455
import org.java_websocket.handshake.ServerHandshake
import org.java_websocket.util.ByteBufferUtils
import java.lang.Exception
import java.net.URI
import java.nio.ByteBuffer
import java.util.*
import kotlin.collections.HashMap

class BetterWebSocketClient @JvmOverloads
constructor(serverUri: URI, var queuingEventSink: QueuingEventSink, protocolDraft: Draft = Draft_6455(), httpHeaders: Map<String, String>? = null, connectTimeout: Int = 0) : WebSocketClient(serverUri, protocolDraft, httpHeaders, connectTimeout) {

    var handler: Handler = Handler {
        queuingEventSink.success(it.obj)
        false
    }

    override fun onOpen(handshakedata: ServerHandshake?) {
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
        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onMessage"
        eventResult["message"] = message.toString()

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)
    }

    override fun onMessage(bytes: ByteBuffer?) {
        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onMessage"
        eventResult["message"] = bytes?.array()!!

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)
    }

    override fun onError(ex: Exception?) {
        val eventResult = HashMap<String, Any>()
        eventResult["event"] = "onError"
        eventResult["message"] = ex?.message.toString()

        val m = Message()
        m.obj = eventResult
        handler.sendMessage(m)
    }

}