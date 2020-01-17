package com.github.adeynack.finances.service.util.vertx.web

import io.vertx.core.http.HttpMethod
import io.vertx.ext.web.Router

@Suppress("MemberVisibilityCanBePrivate", "FunctionName", "unused", "PropertyName")
class RouterInitializer(
    private val router: Router,
    private val basePath: String,
    var defaultNegotiator: Negotiator?
) : Router by router {

    private constructor(
        parentInitializer: RouterInitializer,
        subPath: String
    ) : this(
        parentInitializer.router,
        parentInitializer.joinPaths(subPath),
        parentInitializer.defaultNegotiator
    )

    /**
     * Starts a new sub-path initialization block.
     */
    operator fun String.invoke(f: RouterInitializer.() -> Unit) =
        f.invoke(RouterInitializer(this@RouterInitializer, this))

    val String.OPTIONS get() = method(HttpMethod.OPTIONS)
    val String.GET get() = method(HttpMethod.GET)
    val String.HEAD get() = method(HttpMethod.HEAD)
    val String.POST get() = method(HttpMethod.POST)
    val String.PUT get() = method(HttpMethod.PUT)
    val String.DELETE get() = method(HttpMethod.DELETE)
    val String.TRACE get() = method(HttpMethod.TRACE)
    val String.CONNECT get() = method(HttpMethod.CONNECT)
    val String.PATCH get() = method(HttpMethod.PATCH)
    val String.OTHER get() = method(HttpMethod.OTHER)

    val OPTIONS get() = basePath.OPTIONS
    val GET get() = basePath.GET
    val HEAD get() = basePath.HEAD
    val POST get() = basePath.POST
    val PUT get() = basePath.PUT
    val DELETE get() = basePath.DELETE
    val TRACE get() = basePath.TRACE
    val CONNECT get() = basePath.CONNECT
    val PATCH get() = basePath.PATCH
    val OTHER get() = basePath.OTHER

    private fun joinPaths(path: String): String = basePath + '/' + path.trim('/')

    private fun String.method(m: HttpMethod) = RouteInitializer(
        router.route()
            .path(joinPaths(this))
            .method(m),
        this@RouterInitializer)

}

fun Router.initialize(f: RouterInitializer.() -> Unit): Router =
    RouterInitializer(this, "/", null).also {
        f.invoke(it)
    }
