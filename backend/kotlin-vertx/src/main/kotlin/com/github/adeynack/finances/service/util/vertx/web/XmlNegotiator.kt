package com.github.adeynack.finances.service.util.vertx.web

import com.fasterxml.jackson.dataformat.xml.XmlMapper
import com.fasterxml.jackson.module.kotlin.KotlinModule
import io.vertx.core.buffer.Buffer
import io.vertx.core.http.HttpHeaders
import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.RoutingContext
import kotlin.reflect.KClass

/**
 * A [Negotiator] for the XML format.
 */
class XmlNegotiator(
    val mapper: XmlMapper = createDefaultXmlMapper()
) : Negotiator {

    override val consumedTypes = listOfMimeHeader("*/xml")

    override val producedTypes = listOfMimeHeader("application/xml", "text/xml")

    override fun <T : Any> readRequestBody(clazz: KClass<T>, context: RoutingContext, acceptedConsumedType: MIMEHeader?): T? {
        return mapper.readValue(context.body.bytes, clazz.java)
    }

    override fun <T : Any> writeResponseBodyAndContentTypeHeader(clazz: KClass<T>, value: T, context: RoutingContext, acceptedProducedType: MIMEHeader?) {
        val buffer = Buffer.buffer(mapper.writeValueAsBytes(value))
        context.response()
            .putHeader(HttpHeaders.CONTENT_TYPE, context.acceptableContentType ?: "application/xml")
            .writeWithLength(buffer)
    }

    companion object {

        fun createDefaultXmlMapper(): XmlMapper = XmlMapper().apply {
            registerModule(KotlinModule())
        }
    }
}
