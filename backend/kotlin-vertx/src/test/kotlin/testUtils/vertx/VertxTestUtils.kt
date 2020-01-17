import io.vertx.core.AbstractVerticle
import io.vertx.core.Verticle
import io.vertx.core.Vertx
import io.vertx.core.buffer.Buffer
import io.vertx.ext.web.Router
import io.vertx.ext.web.client.HttpResponse
import io.vertx.ext.web.client.WebClient
import io.vertx.junit5.VertxTestContext

fun createVerticle(startFunction: AbstractVerticle.() -> Unit): Verticle = object : AbstractVerticle() {

    override fun start() {
        super.start()
        this.startFunction()
    }
}

fun createRouterVerticle(router: Router): Verticle =
    createVerticle {
        vertx
            .createHttpServer()
            .requestHandler(router::accept)
            .listen(12345)
    }

fun testRouterVerticle(
    vertx: Vertx,
    testContext: VertxTestContext,
    createRouter: () -> Router,
    path: String,
    headers: List<Pair<CharSequence, String>> = emptyList(),
    responseAssert: (HttpResponse<Buffer>) -> Unit
) {
    vertx.deployVerticle(
        createRouterVerticle(createRouter()),
        testContext.succeeding {

            val client = WebClient.create(vertx).get(12345, "localhost", path)
            headers.forEach { (name, value) -> client.putHeader(name.toString(), value) }
            client.send(testContext.succeeding { resp ->
                testContext.verify {
                    responseAssert(resp)
                    testContext.completeNow()
                }
            })

        }
    )
}
