package com.dclab.beat.steps

object StepEventSink {
    @Volatile var sink: io.flutter.plugin.common.EventChannel.EventSink? = null
    fun emit(v: Long) { sink?.success(v) }
}