package com.github.adeynack.finances.service.util.vertx.web

import io.netty.handler.codec.http.HttpResponseStatus
import io.vertx.core.http.HttpHeaders
import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.Route
import io.vertx.ext.web.RoutingContext
import mu.KLogging
import kotlin.reflect.KClass

typealias Negotiation0In<TOut> = () -> Negotiation<TOut>
typealias Negotiation1In<TIn, TOut> = (contextOrRequestBody: TIn) -> Negotiation<TOut>
typealias Negotiation2In<TIn, TOut> = (context: RoutingContext, requestBody: TIn) -> Negotiation<TOut>

class RouteInitializer(
    route: Route,
    private val parentRouterInitializer: RouterInitializer?
) : Route by route {

    private fun getDefaultNegotiator(): Negotiator {
        return parentRouterInitializer?.defaultNegotiator
            ?: throw IllegalStateException("No default negotiator set.")
    }

    private fun <TOut : Any> innerNegotiate(
        negotiator: Negotiator,
        clazzOut: KClass<TOut>,
        handler: (RoutingContext, MIMEHeader?) -> Negotiation<TOut>
    ) {
        handler { context ->
            handleNegotiated(context, negotiator, clazzOut, handler)
        }
    }

    private fun <TOut : Any> handleNegotiated(
        context: RoutingContext,
        negotiator: Negotiator,
        clazzOut: KClass<TOut>,
        handler: (RoutingContext, MIMEHeader?) -> Negotiation<TOut>
    ) {
        // Check if `content-type` (request type) is compatible with current negotiator.
        val contentType = context.parsedHeaders().contentType()?.takeIf { it.rawValue().isNotBlank() }
        val acceptedConsumedType =
            if (contentType === null) {
                null // let the negotiator deal with that.
            } else {
                // if a `content-type` header is provided, it needs to be supported by the negotiator.
                val match = contentType.findMatchedBy(negotiator.consumedTypes)
                if (match === null) {
                    val problem = Problem(
                        status = HttpResponseStatus.UNSUPPORTED_MEDIA_TYPE,
                        title = "The request type is not supported (header `${HttpHeaders.CONTENT_TYPE}`)",
                        detail = "A request of type `${contentType.rawValue()}` is not supported."
                    )
                    context.response().endWithProblem(problem)
                    return
                }
                match
            }

        // Check if `accept` (response type) is compatible with current negotiator.
        val accept = context.parsedHeaders().accept()?.filter { it.rawValue().isNotBlank() }.orEmpty()
        val acceptedProducedType =
            if (accept.isEmpty()) {
                null // let the negotiator deal with that.
            } else {
                // if a `accept` header is provided, it needs to be supported by the negotiator.
                val match = accept
                    .asSequence()
                    .mapNotNull { it.findMatchedBy(negotiator.producedTypes) }
                    .firstOrNull()
                if (match === null) {
                    val problem = Problem(
                        status = HttpResponseStatus.NOT_ACCEPTABLE,
                        title = "The accepted types are not supported (header `${HttpHeaders.ACCEPT}`)",
                        detail = "A request that accepts types ${accept.joinToString(", ", "`", "`")}` is not supported."
                    )
                    context.response().endWithProblem(problem)
                    return
                }
                match
            }

        // Call the handler and get the negotiation result.
        val negotiated = handler(context, acceptedConsumedType)

        // Respond
        when (negotiated) {
            is ContentResponse -> {
                negotiator.writeResponseBodyAndContentTypeHeader(clazzOut, negotiated.result, context, acceptedProducedType)
                if (context.response().headers()[HttpHeaders.CONTENT_TYPE] === null) {
                    logger.warn { "Negotiator `${negotiator::class.simpleName}` did not set the `acceptableContentType` of the `RoutingContext`." }
                }
                context.response()
                    .setStatusCode(negotiated.status.code())
                    .end()
            }
            is EmptyResponse -> {
                context.response()
                    .setStatusCode(negotiated.status.code())
                    .end()
            }
            is Problem -> {
                context.response().endWithProblem(negotiated)
            }
        }
    }

    private fun <TIn : Any, TOut : Any> handleWithRequestBody(
        negotiator: Negotiator,
        clazzIn: KClass<TIn>,
        context: RoutingContext,
        acceptedConsumedType: MIMEHeader?,
        handler: (TIn) -> Negotiation<TOut>
    ): Negotiation<TOut> {
        val requestBody = negotiator.readRequestBody(clazzIn, context, acceptedConsumedType)
        return when (requestBody) {
            null -> Problem(
                status = HttpResponseStatus.BAD_REQUEST,
                title = "Unable to parse request body."
            )
            else -> handler(requestBody)
        }
    }

    fun <TOut : Any> negotiate(negotiator: Negotiator, clazzOut: KClass<TOut>, handler: Negotiation0In<TOut>) {
        logger.debug { "Creating negotiated route $path with no input and a response body of ${clazzOut.simpleName}" }
        innerNegotiate(negotiator, clazzOut) { _, _ ->
            handler()
        }
    }

    fun <TOut : Any> negotiate(clazzOut: KClass<TOut>, handler: Negotiation0In<TOut>) = negotiate(getDefaultNegotiator(), clazzOut, handler)

    fun <TIn : Any, TOut : Any> negotiate(negotiator: Negotiator, clazzIn: KClass<TIn>, clazzOut: KClass<TOut>, handler: Negotiation1In<TIn, TOut>) {
        // todo
        when (clazzIn) {
            RoutingContext::class -> {
                logger.debug { "Creating route $path with the RoutingContext and a response body of ${clazzOut.simpleName}" }
                innerNegotiate(negotiator, clazzOut) { context, _ ->
                    @Suppress("UNCHECKED_CAST")
                    handler(context as TIn)
                }
            }
            else -> {
                logger.debug { "Creating route $path with a request body of ${clazzIn.simpleName} and a response body of ${clazzOut.simpleName}" }
                innerNegotiate(negotiator, clazzOut) { context, acceptedConsumedType ->
                    handleWithRequestBody(negotiator, clazzIn, context, acceptedConsumedType, handler)
                }
            }
        }
    }

    fun <TIn : Any, TOut : Any> negotiate(clazzIn: KClass<TIn>, clazzOut: KClass<TOut>, handler: Negotiation1In<TIn, TOut>) =
        negotiate(getDefaultNegotiator(), clazzIn, clazzOut, handler)

    fun <TIn : Any, TOut : Any> negotiate(negotiator: Negotiator, clazzIn: KClass<TIn>, clazzOut: KClass<TOut>, handler: Negotiation2In<TIn, TOut>) {
        logger.debug { "Creating route $path with the RoutingContext, a request body of ${clazzIn.simpleName} and a response body of ${clazzOut.simpleName}" }
        innerNegotiate(negotiator, clazzOut) { context, acceptedConsumedType ->
            handleWithRequestBody(negotiator, clazzIn, context, acceptedConsumedType) { requestBody ->
                handler(context, requestBody)
            }
        }
    }

    fun <TIn : Any, TOut : Any> negotiate(clazzIn: KClass<TIn>, clazzOut: KClass<TOut>, handler: Negotiation2In<TIn, TOut>) =
        negotiate(getDefaultNegotiator(), clazzIn, clazzOut, handler)

    companion object : KLogging()
}

// DSL Extensions for Negotiation0In

inline fun <reified TOut : Any> Route.negotiate(negotiator: Negotiator, noinline handler: Negotiation0In<TOut>) {
    RouteInitializer(this, null).negotiate(negotiator, TOut::class, handler)
}

inline fun <reified TOut : Any> RouteInitializer.negotiate(negotiator: Negotiator, noinline handler: Negotiation0In<TOut>) {
    negotiate(negotiator, TOut::class, handler)
}

inline infix fun <reified TOut : Any> RouteInitializer.negotiate(noinline handler: Negotiation0In<TOut>) {
    negotiate(TOut::class, handler)
}

// DSL Extensions for Negotiation1In

inline fun <reified TIn : Any, reified TOut : Any> Route.negotiate(negotiator: Negotiator, noinline handler: Negotiation1In<TIn, TOut>) {
    RouteInitializer(this, null).negotiate(negotiator, TIn::class, TOut::class, handler)
}

inline fun <reified TIn : Any, reified TOut : Any> RouteInitializer.negotiate(negotiator: Negotiator, noinline handler: Negotiation1In<TIn, TOut>) {
    negotiate(negotiator, TIn::class, TOut::class, handler)
}

inline infix fun <reified TIn : Any, reified TOut : Any> RouteInitializer.negotiate(noinline handler: Negotiation1In<TIn, TOut>) {
    negotiate(TIn::class, TOut::class, handler)
}

// DSL Extensions for Negotiation2In

inline fun <reified TIn : Any, reified TOut : Any> Route.negotiate(negotiator: Negotiator, noinline handler: Negotiation2In<TIn, TOut>) {
    RouteInitializer(this, null).negotiate(negotiator, TIn::class, TOut::class, handler)
}

inline fun <reified TIn : Any, reified TOut : Any> RouteInitializer.negotiate(negotiator: Negotiator, noinline handler: Negotiation2In<TIn, TOut>) {
    negotiate(negotiator, TIn::class, TOut::class, handler)
}

inline infix fun <reified TIn : Any, reified TOut : Any> RouteInitializer.negotiate(noinline handler: Negotiation2In<TIn, TOut>) {
    negotiate(TIn::class, TOut::class, handler)
}
