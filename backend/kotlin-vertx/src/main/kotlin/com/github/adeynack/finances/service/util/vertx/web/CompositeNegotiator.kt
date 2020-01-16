package com.github.adeynack.finances.service.util.vertx.web

import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.RoutingContext
import mu.KLogging
import kotlin.reflect.KClass

class CompositeNegotiator(private val negotiators: List<Negotiator>) : Negotiator {

    constructor(vararg negotiators: Negotiator) : this(negotiators.asList())

    private val consumedTypeToNegotiator: Map<MIMEHeader, List<Negotiator>> = negotiators
        .flatMap { n -> n.consumedTypes.map { t -> t to n } }
        .groupBy({ it.first }, { it.second })

    private val producedTypeToNegotiator: Map<MIMEHeader, List<Negotiator>> = negotiators
        .flatMap { n -> n.producedTypes.map { t -> t to n } }
        .groupBy({ it.first }, { it.second })

    private val producedTypeStringToNegotiator: Map<String, List<Negotiator>> = producedTypeToNegotiator.mapKeys { it.key.rawValue() }

    override val consumedTypes = consumedTypeToNegotiator.keys.toList()

    override val producedTypes = producedTypeToNegotiator.keys.toList()

    override fun <T : Any> readRequestBody(clazz: KClass<T>, context: RoutingContext, acceptedConsumedType: MIMEHeader?): T? {
        val negotiators = when (acceptedConsumedType) {
            null -> negotiators // try all of them
            else -> consumedTypeToNegotiator[acceptedConsumedType]
                ?: throw RuntimeException("No negotiator for type `$acceptedConsumedType` found in negotiator. ${knownTypes()}")
        }
        return negotiators
            .asSequence()
            .mapNotNull { negotiator ->
                negotiator.readRequestBody(clazz, context, acceptedConsumedType).also { requestBody: T? ->
                    when (requestBody) {
                        null -> logger.debug { "Negotiator ${negotiator::class.simpleName} did not read the request's body (returned null)." }
                        else -> logger.debug { "Negotiator ${negotiator::class.simpleName} read the request's body: $requestBody" }
                    }
                }
            }
            .firstOrNull()
    }

    private fun knownTypes() = "Known types are: ${consumedTypes.joinToString(", ")}."

    override fun <T : Any> writeResponseBodyAndContentTypeHeader(clazz: KClass<T>, value: T, context: RoutingContext, acceptedProducedType: MIMEHeader?) {
        val negotiator = when (acceptedProducedType) {
            null -> // use the first negotiator as a default.
                negotiators.first()
            else -> // use the first negotiator that registered this response type.
                producedTypeStringToNegotiator[acceptedProducedType.rawValue()]?.firstOrNull()
                    ?: throw RuntimeException("No negotiator for AcceptableContentType `$acceptedProducedType` found in negotiator. ${knownTypes()}")
        }
        negotiator.writeResponseBodyAndContentTypeHeader(clazz, value, context, acceptedProducedType)
    }

    companion object : KLogging()

}
