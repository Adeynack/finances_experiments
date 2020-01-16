package com.github.adeynack.finances.service.util.vertx.web

import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.RoutingContext
import io.vertx.ext.web.impl.ParsableMIMEValue
import kotlin.reflect.KClass

interface Negotiator {

    /**
     * All ContentResponse Types (aka MIME Type) that this [Negotiator] can parse from the request's body.
     */
    val consumedTypes: List<MIMEHeader>

    /**
     * All ContentResponse Types (aka MIME Type) that this [Negotiator] can write to the response's body.
     */
    val producedTypes: List<MIMEHeader>

    /**
     * Reads the response payload from the current server exchange ([context]) and deserialize its content
     * to a value of type [T].
     * @param clazz the type information of the payload to deserialize.
     * @param context the [RoutingContext] of the current server exchange.
     * @return an instance of [T] containing the deserialized request's payload or `null` when it was
     *         not possible to deserialize it.
     */
    fun <T : Any> readRequestBody(clazz: KClass<T>, context: RoutingContext, acceptedConsumedType: MIMEHeader?): T?

    /**
     * Writes the response payload ([value]) to the response ([context]) and set the `Content-Type` header.
     * @param clazz the type information of the payload to serialize.
     * @param value the value to write to the response's body.
     * @param context the [RoutingContext] of the current server exchange.
     */
    fun <T : Any> writeResponseBodyAndContentTypeHeader(clazz: KClass<T>, value: T, context: RoutingContext, acceptedProducedType: MIMEHeader?)
}

fun listOfMimeHeader(vararg contentType: String) = contentType.map(::ParsableMIMEValue)
