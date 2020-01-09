package com.kinsomy.better_socket

import android.R
import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.io.InputStream
import java.net.URI
import java.security.*
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import javax.net.ssl.*


class BetterSocketPlugin(private val registrar: Registrar) : MethodCallHandler {
    private var betterWebSocketClient: BetterWebSocketClient? = null
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
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "connentSocket" -> {
                val path = call.argument<String>("path")
                val httpHeaders = call.argument<Map<String, String>>("httpHeaders")
                val keyStorePath = call.argument<String>("keyStorePath")
                val keyPassword = call.argument<String>("keyPassword")
                val storePassword = call.argument<String>("storePassword")
                val keyStoreType = call.argument<String>("keyStoreType")
                val trustAllHost = call.argument<Boolean>("trustAllHost")?: false
                val webSocketUri = URI.create(path)
                close()
                betterWebSocketClient = BetterWebSocketClient(webSocketUri, queuingEventSink, httpHeaders = httpHeaders)
                if (keyStorePath?.isNotEmpty()==true&&keyPassword?.isNotEmpty()==true&&storePassword?.isNotEmpty()==true&&keyStoreType?.isNotEmpty()==true){
                    val sslFactory = getSSLContextFromAndroidKeystore(registrar.context(),storePassword,keyPassword,keyStorePath,keyStoreType).socketFactory
                    betterWebSocketClient?.setSocketFactory(sslFactory)
                }
                if (trustAllHost){
                    betterWebSocketClient?.setSocketFactory(getSSLContext().socketFactory)
                }
                betterWebSocketClient?.connect()
                result.success(null)
            }
            "sendMsg" -> {
                val msg = call.argument<String>("msg")
                if (betterWebSocketClient?.isOpen == true)
                    betterWebSocketClient?.send(msg)
                result.success(null)
            }
            "sendByteMsg" -> {
                val msg = call.argument<ByteArray>("msg")
                if (betterWebSocketClient?.isOpen == true)
                    betterWebSocketClient?.send(msg)
                result.success(null)
            }
            "close" -> {
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

    private fun getSSLContext(): SSLContext{
        val x509TrustManager = object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {
            }

            override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {
            }

            override fun getAcceptedIssuers(): Array<X509Certificate> {
                return arrayOf()
            }
        }

        val sslContext: SSLContext
        try {
            sslContext = SSLContext.getInstance("TLS")
            sslContext.init(null, arrayOf<TrustManager>(x509TrustManager), null)
        } catch (e: KeyStoreException) {
            throw IllegalArgumentException()
        } catch (e: IOException) {
            throw IllegalArgumentException()
        } catch (e: CertificateException) {
            throw IllegalArgumentException()
        } catch (e: NoSuchAlgorithmException) {
            throw IllegalArgumentException()
        } catch (e: KeyManagementException) {
            throw IllegalArgumentException()
        } catch (e: UnrecoverableKeyException) {
            throw IllegalArgumentException()
        }
        return sslContext
    }

    private fun getSSLContextFromAndroidKeystore(context: Context, storePassword:String, keyPassword:String, keyStorePath:String,keyStoreType:String = "BKS"): SSLContext {
        // load up the key store
        val sslContext: SSLContext
        try {
            val keystore: KeyStore = KeyStore.getInstance(keyStoreType)
            val inputStream: InputStream = context.assets.open(keyStorePath)
            inputStream.use { _inputStream ->
                keystore.load(_inputStream, storePassword.toCharArray())
            }
            val keyManagerFactory: KeyManagerFactory = KeyManagerFactory.getInstance("X509")
            keyManagerFactory.init(keystore, keyPassword.toCharArray())
            val tmf: TrustManagerFactory = TrustManagerFactory.getInstance("X509")
            tmf.init(keystore)
            sslContext = SSLContext.getInstance("TLS")
            sslContext.init(keyManagerFactory.keyManagers, tmf.trustManagers, null)
        } catch (e: KeyStoreException) {
            throw IllegalArgumentException()
        } catch (e: IOException) {
            throw IllegalArgumentException()
        } catch (e: CertificateException) {
            throw IllegalArgumentException()
        } catch (e: NoSuchAlgorithmException) {
            throw IllegalArgumentException()
        } catch (e: KeyManagementException) {
            throw IllegalArgumentException()
        } catch (e: UnrecoverableKeyException) {
            throw IllegalArgumentException()
        }
        return sslContext
    }

}
