package com.kinsomy.better_socket

import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.net.URI

class BetterSocketPlugin(registrar: Registrar) : MethodCallHandler {
  private var betterWebSocketClient: BetterWebSocketClient? = null
  private var eventChannel: EventChannel? = null
  private val queuingEventSink: QueuingEventSink = QueuingEventSink()

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = BetterSocketPlugin(registrar)

      val channel = MethodChannel(registrar.messenger(), "better_socket")
      channel.setMethodCallHandler(plugin)

      //注册WebSocket Flutter回调
      EventChannel(registrar.messenger(), "better_socket/event").setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(p0: Any?, sink: EventChannel.EventSink?) {
          plugin.queuingEventSink.setDelegate(sink)
        }

        override fun onCancel(p0: Any?) {
          plugin.queuingEventSink.setDelegate(null)
        }
      })
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when {
      call.method == "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      call.method == "connentSocket" -> {
        val path = call.argument<String>("path")
        val webSocketUri = URI.create(path)
        close()
        betterWebSocketClient = BetterWebSocketClient(webSocketUri, queuingEventSink)
        betterWebSocketClient?.connect()
        result.success(null)
      }
      call.method == "sendMsg" -> {
        val msg = call.argument<String>("msg")
        if (betterWebSocketClient?.isOpen == true)
          betterWebSocketClient?.send(msg)
        result.success(null)
      }
      call.method == "close" -> {
        close()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun close() {
    if (betterWebSocketClient?.isOpen == true) {
      betterWebSocketClient?.close()
    }
    betterWebSocketClient = null
  }

}
