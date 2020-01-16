package com.github.adeynack.finances.service.util.vertx.web

import io.vertx.core.http.HttpHeaders
import io.vertx.core.json.Json
import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.RoutingContext
import kotlin.reflect.KClass

/**
 * A [Negotiator] for the JSON format, using the Vert.x `ObjectMapper` in [Json] for
 * serialize and deserialize payloads.
 */
class JsonVertxNegotiator : Negotiator {

    override val consumedTypes = listOfMimeHeader(
        "application/json"
    )

    override val producedTypes = consumedTypes

    override fun <T : Any> readRequestBody(clazz: KClass<T>, context: RoutingContext, acceptedConsumedType: MIMEHeader?): T? {
        return context.bodyAsJson.mapTo(clazz.java)
    }

    override fun <T : Any> writeResponseBodyAndContentTypeHeader(clazz: KClass<T>, value: T, context: RoutingContext, acceptedProducedType: MIMEHeader?) {
        val buffer = Json.encodeToBuffer(value)
        context.response()
            .putHeader(HttpHeaders.CONTENT_TYPE, context.acceptableContentType ?: "application/json")
            .writeWithLength(buffer)
    }
}
