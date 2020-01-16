package util.vertx.web

import com.github.adeynack.finances.service.util.vertx.web.Created
import com.github.adeynack.finances.service.util.vertx.web.Negotiation
import com.github.adeynack.finances.service.util.vertx.web.Negotiator
import com.github.adeynack.finances.service.util.vertx.web.NoContent
import com.github.adeynack.finances.service.util.vertx.web.Ok
import com.github.adeynack.finances.service.util.vertx.web.Problem
import com.github.adeynack.finances.service.util.vertx.web.initialize
import com.github.adeynack.finances.service.util.vertx.web.negotiate
import io.netty.handler.codec.http.HttpResponseStatus
import io.vertx.core.Vertx
import io.vertx.core.http.HttpMethod
import io.vertx.ext.web.Router
import io.vertx.ext.web.RoutingContext

object KotlinTestRouters {

    /**
     * - Router.initialize extension ... NO
     * - Route { } extension ........... N/A
     * - Default negotiator ............ N/A
     */
    fun createRouterWithRouteExtensions(vertx: Vertx, fooController: FooController, mainNegotiator: Negotiator, alternativeNegotiator: Negotiator): Router =
        Router.router(vertx).apply {
            // 0 argument
            route().path("/foos").method(HttpMethod.GET).negotiate(mainNegotiator, fooController::getAllFoos)
            // 1 argument: request body
            route().path("/foos").method(HttpMethod.POST).negotiate(mainNegotiator, fooController::createFoo)
            // Alternate representation of the list of foo
            route().path("/foos/alternative").method(HttpMethod.GET).negotiate(alternativeNegotiator, fooController::getAllFoos)
            // 1 argument: routing context
            route().path("/foos/{fooId}").method(HttpMethod.GET).negotiate(mainNegotiator, fooController::getFooById)
            // 2 arguments: routing context + request body
            route().path("/foos/{fooId}").method(HttpMethod.PUT).negotiate(mainNegotiator, fooController::updateFoo)
        }

    /**
     * - Router.initialize extension ... YES
     * - Route { } extension ........... YES
     * - Default negotiator ............ YES
     */
    fun createRouterWithRouteInitializerAutoNego(vertx: Vertx, fooController: FooController, mainNegotiator: Negotiator, alternativeNegotiator: Negotiator): Router =
        Router.router(vertx).initialize {
            defaultNegotiator = mainNegotiator
            "foos" {
                // 0 argument
                GET negotiate fooController::getAllFoos
                // 1 argument: request body
                POST negotiate fooController::createFoo
                // Alternate representation of the list of foo
                "alternative" {
                    defaultNegotiator = alternativeNegotiator
                    GET negotiate fooController::getAllFoos
                }
                "{fooId}" {
                    // 1 argument: routing context
                    GET negotiate fooController::getFooById
                    // 2 arguments: routing context + request body
                    PUT negotiate fooController::updateFoo
                }
            }
        }

    /**
     * - Router.initialize extension ... YES
     * - Route { } extension ........... YES
     * - Default negotiator ............ NO
     */
    fun createRouterWithRouteInitializerExplicitNego(vertx: Vertx, fooController: FooController, mainNegotiator: Negotiator, alternativeNegotiator: Negotiator): Router =
        Router.router(vertx).initialize {
            "foos" {
                // 0 argument
                GET.negotiate(mainNegotiator, fooController::getAllFoos)
                // 1 argument: request body
                POST.negotiate(mainNegotiator, fooController::createFoo)
                // Alternate representation of the list of foo
                "alternative" {
                    GET.negotiate(alternativeNegotiator, fooController::getAllFoos)
                }
                "{fooId}" {
                    // 1 argument: routing context
                    GET.negotiate(mainNegotiator, fooController::getFooById)
                    // 2 arguments: routing context + request body
                    PUT.negotiate(mainNegotiator, fooController::updateFoo)
                }
            }
        }

    /**
     * - Router.initialize extension ... YES
     * - Route { } extension ........... NO    (String extensions instead)
     * - Default negotiator ............ YES
     */
    fun createRouterWithStringExtensionsAutoNego(vertx: Vertx, fooController: FooController, mainNegotiator: Negotiator, alternativeNegotiator: Negotiator): Router =
        Router.router(vertx).initialize {
            defaultNegotiator = mainNegotiator
            // 0 argument
            "foos".GET.negotiate(fooController::getAllFoos)
            // 1 argument: request body
            "foos".POST.negotiate(fooController::createFoo)
            // Alternate representation of the list of foo
            defaultNegotiator = alternativeNegotiator
            "foos/alternative".GET.negotiate(fooController::getAllFoos)
            defaultNegotiator = mainNegotiator
            // 1 argument: routing context
            "foos/{fooId}".GET.negotiate(fooController::getFooById)
            // 2 arguments: routing context + request body
            "foos/{fooId}".PUT.negotiate(fooController::updateFoo)
        }

    /**
     * - Router.initialize extension ... YES
     * - Route { } extension ........... NO    (String extensions instead)
     * - Default negotiator ............ NO
     */
    fun createRouterWithStringExtensionsExplicitNego(vertx: Vertx, fooController: FooController, mainNegotiator: Negotiator, alternativeNegotiator: Negotiator): Router =
        Router.router(vertx).initialize {
            // 0 argument
            "foos".GET.negotiate(mainNegotiator, fooController::getAllFoos)
            // 1 argument: request body
            "foos".POST.negotiate(mainNegotiator, fooController::createFoo)
            // Alternate representation of the list of foo
            "foos/alternative".GET.negotiate(alternativeNegotiator, fooController::getAllFoos)
            // 1 argument: routing context
            "foos/{fooId}".GET.negotiate(mainNegotiator, fooController::getFooById)
            // 2 arguments: routing context + request body
            "foos/{fooId}".PUT.negotiate(mainNegotiator, fooController::updateFoo)
        }

}

class FooController {

    private val foos = listOf(
        Foo(id = 11, name = "Meh"),
        Foo(id = 12, name = "Mah"),
        Foo(id = 13, name = "Meuh")
    )

    fun getAllFoos(): Negotiation<FooList> {
        return Ok(FooList(data = foos))
    }

    fun createFoo(newFoo: Foo): Negotiation<Foo> {
        return Created(newFoo.copy(id = 14))
    }

    fun getFooById(c: RoutingContext): Negotiation<Foo> = c.withFoo { foo ->
        Ok(foo)
    }

    @Suppress("RemoveExplicitTypeArguments")
    fun updateFoo(c: RoutingContext, updatedFoo: Foo): Negotiation<Foo> = c.withFoo<Foo> { foo ->
        if (foo.id != updatedFoo.id) Problem(
            status = HttpResponseStatus.BAD_REQUEST,
            title = "Foo is request body does not have the same ID as the provided path."
        ) else {
            NoContent()
        }
    }

    private fun <T> RoutingContext.withFoo(f: (foo: Foo) -> Negotiation<T>): Negotiation<T> {
        val rawFooId = pathParam("fooId")
        if (rawFooId === null) return Problem(
            status = HttpResponseStatus.BAD_REQUEST,
            title = "`fooId` was not part of the path."
        )
        val foo = rawFooId.toLongOrNull()?.let { i -> foos.firstOrNull { r -> r.id == i } }
        if (foo === null) return Problem(
            status = HttpResponseStatus.NOT_FOUND,
            title = "No Foo with ID `$rawFooId` exists."
        )
        return f(foo)
    }
}

data class Foo(
    val id: Long = -1,
    val name: String
)

data class FooList(
    val data: List<Foo>
)
