package util.vertx.web

import com.github.adeynack.finances.service.util.vertx.web.CompositeNegotiator
import com.github.adeynack.finances.service.util.vertx.web.JsonVertxNegotiator
import com.github.adeynack.finances.service.util.vertx.web.Negotiator
import com.github.adeynack.finances.service.util.vertx.web.XmlNegotiator
import com.github.adeynack.finances.service.util.vertx.web.listOfMimeHeader
import io.netty.handler.codec.http.HttpResponseStatus
import io.vertx.core.Vertx
import io.vertx.core.http.HttpHeaders
import io.vertx.ext.web.MIMEHeader
import io.vertx.ext.web.RoutingContext
import io.vertx.ext.web.impl.ParsableMIMEValue
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
import kotlin.reflect.KClass

@ExtendWith(VertxExtension::class)
@DisplayName("Routing with Negotiation extensions")
class CompositeNegotiatorTest {

    private fun router(vertx: Vertx) =
        createRouterWithRouteExtensions(vertx, FooController(), jsonXmlNegotiator, toStringNegotiator)

    @Nested
    @DisplayName("/foos GET")
    inner class GetFoos {

        @Test
        @DisplayName("without content negotiation header, response should be JSON")
        fun noNegoHeader(vertx: Vertx, testContext: VertxTestContext) {
            testRouterVerticle(vertx, testContext, { router(vertx) },
                path = "/foos"
            ) { resp ->
                assertThat(resp.statusCode()).isEqualTo(HttpResponseStatus.OK.code())
                assertThat(resp.getHeader(HttpHeaders.CONTENT_TYPE.toString())).isEqualTo("application/json")
                JSONAssert.assertEquals(expectedGetFoosResponse, resp.bodyAsString(), true)
            }
        }

        @Test
        @DisplayName("with `accept` header set to `application/json`, response should be JSON")
        fun acceptApplicationJson(vertx: Vertx, testContext: VertxTestContext) {
            testRouterVerticle(vertx, testContext, { router(vertx) },
                path = "/foos",
                headers = listOf(
                    HttpHeaders.ACCEPT to "application/json"
                )
            ) { resp ->
                assertThat(resp.statusCode()).isEqualTo(HttpResponseStatus.OK.code())
                assertThat(resp.getHeader(HttpHeaders.CONTENT_TYPE.toString())).isEqualTo("application/json")
                JSONAssert.assertEquals(expectedGetFoosResponse, resp.bodyAsString(), true)
            }
        }

        @Test
        @DisplayName("with `accept` header set to `foo/json`, response should be a NOT_ACCEPTABLE with ProblemJson")
        fun acceptFooJson(vertx: Vertx, testContext: VertxTestContext) {
            testRouterVerticle(vertx, testContext, { router(vertx) },
                path = "/foos",
                headers = listOf(
                    HttpHeaders.ACCEPT to "foo/json"
                )
            ) { resp ->
                assertThat(resp.statusCode()).isEqualTo(HttpResponseStatus.NOT_ACCEPTABLE.code())
                // todo: assert ProblemJson
            }
        }

        @Test
        @DisplayName("with `accept` header set to `application/xml`, response should be XML")
        fun acceptApplicationXml(vertx: Vertx, testContext: VertxTestContext) {
            testRouterVerticle(vertx, testContext, { router(vertx) },
                path = "/foos",
                headers = listOf(
                    HttpHeaders.ACCEPT to "application/xml"
                )
            ) { resp ->
                assertThat(resp.statusCode()).isEqualTo(HttpResponseStatus.OK.code())
                assertThat(resp.getHeader(HttpHeaders.CONTENT_TYPE.toString())).isEqualTo("application/xml")
                assertThat(resp.bodyAsString()).isXmlEqualTo(expectedGetFoosResponseXml) // todo: Assert XML payload
            }
        }
    }

    private val jsonXmlNegotiator = CompositeNegotiator(JsonVertxNegotiator(), XmlNegotiator())

    private val toStringNegotiator = object : Negotiator {

        override val consumedTypes = emptyList<ParsableMIMEValue>()

        override val producedTypes = listOfMimeHeader("text/plain")

        override fun <T : Any> readRequestBody(clazz: KClass<T>, context: RoutingContext, acceptedConsumedType: MIMEHeader?): T? = null

        override fun <T : Any> writeResponseBodyAndContentTypeHeader(clazz: KClass<T>, value: T, context: RoutingContext, acceptedProducedType: MIMEHeader?) {
            context.response().write(value.toString())
        }
    }

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

    @Language("XML")
    private val expectedGetFoosResponseXml = """
<FooList>
    <data>
        <Foo>
            <id>11</id>
            <name>Meh</name>
        </Foo>
        <Foo>
            <id>12</id>
            <name>Mah</name>
        </Foo>
        <Foo>
            <id>13</id>
            <name>Meuh</name>
        </Foo>
    </data>
</FooList>
    """

}
