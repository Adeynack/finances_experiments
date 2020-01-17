package com.github.adeynack.finances.service.util.vertx.web

import io.netty.handler.codec.http.HttpResponseStatus
import java.net.URI

@Suppress("unused")
sealed class Negotiation<out T>(
    open val status: HttpResponseStatus
)

// Manual Status Code
open class ContentResponse<T>(status: HttpResponseStatus, val result: T): Negotiation<T>(status)
open class EmptyResponse(status: HttpResponseStatus): Negotiation<Nothing>(status)

// 200
class Ok<T>(result: T) : ContentResponse<T>(HttpResponseStatus.OK, result)
class Created<T>(result: T) : ContentResponse<T>(HttpResponseStatus.CREATED, result)
class Accepted<T>(result: T) : ContentResponse<T>(HttpResponseStatus.ACCEPTED, result)
class NoContent: EmptyResponse(HttpResponseStatus.NO_CONTENT)

// 300
class NotModified: EmptyResponse(HttpResponseStatus.NOT_MODIFIED)


// todo: Serialize the HttpStatusCode value (the int) and not the HttpResponseStatus object itself.
// todo: Make sure the `debug` property is not serialized when app not in dev mode
@Suppress("MemberVisibilityCanBePrivate")
data class Problem(
    override val status: HttpResponseStatus,
    val type: URI = defaultType,
    val title: String = status.reasonPhrase(),
    val detail: String? = null,
    val instance: URI? = null,
    val debug: ProblemDebugInformation? = null
) : Negotiation<Nothing>(status) {
    companion object {
        val defaultType: URI = URI.create("about:blank")
    }
}

data class ProblemDebugInformation(
    val cause: Throwable? = null,
    val debugInformation: Any? = null
)

data class ProblemJson(
    val status: Int,
    val type: URI,
    val title: String,
    val detail: String?,
    val instance: URI?
)
