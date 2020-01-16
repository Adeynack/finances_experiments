package util.vertx.web

import com.github.adeynack.finances.service.util.vertx.web.JsonVertxNegotiator
import com.github.adeynack.finances.service.util.vertx.web.XmlNegotiator
import io.netty.handler.codec.http.HttpResponseStatus
import io.vertx.core.Vertx
import io.vertx.junit5.VertxExtension
import io.vertx.junit5.VertxTestContext
import org.assertj.core.api.Assertions.assertThat
import org.intellij.lang.annotations.Language
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.skyscreamer.jsonassert.JSONAssert
import testRouterVerticle
import util.vertx.web.KotlinTestRouters.createRouterWithRouteExtensions

@ExtendWith(VertxExtension::class)
@DisplayName("Routing with Negotiation extensions")
class RoutingWithNegotiationTest {

    @Nested
    @DisplayName("Router built with `Route` extensions")
    inner class RouterWithRouteExtensions {

        private fun router(vertx: Vertx) =
            createRouterWithRouteExtensions(vertx, FooController(), jsonNegotiator, xmlNegotiator)

        @Test
        @DisplayName("/foos GET")
        fun noNegoHeader(vertx: Vertx, testContext: VertxTestContext) {
            testRouterVerticle(vertx, testContext, { router(vertx) },
                path = "/foos"
            ) { resp ->
                assertThat(resp.statusCode()).isEqualTo(HttpResponseStatus.OK.code())
                JSONAssert.assertEquals(expectedGetFoosResponse, resp.bodyAsString(), true)
            }
        }

    }

    private val jsonNegotiator = JsonVertxNegotiator()

    private val xmlNegotiator = XmlNegotiator()

    @Language("JSON")
    private val expectedGetFoosResponse = """{
  "data": [
    {
      "id": 11,
      "name": "Meh"
    },
    {
      "id": 12,
      "name": "Mah"
    },
    {
      "id": 13,
      "name": "Meuh"
    }
  ]
}        """

}
