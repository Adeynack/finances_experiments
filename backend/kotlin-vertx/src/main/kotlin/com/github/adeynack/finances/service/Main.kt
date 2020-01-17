@file:JvmName("Main")

package com.github.adeynack.finances.service

import com.github.adeynack.finances.service.action.BookAction
import com.github.adeynack.finances.service.controller.BookController
import com.github.adeynack.finances.service.repository.BookRepository
import com.github.adeynack.finances.service.service.DatabaseService
import com.github.adeynack.finances.service.util.vertx.web.JsonVertxNegotiator
import com.github.adeynack.finances.service.util.vertx.web.Ok
import com.github.adeynack.finances.service.util.vertx.web.initialize
import com.github.adeynack.finances.service.util.vertx.web.negotiate
import com.typesafe.config.Config
import com.typesafe.config.ConfigFactory
import com.typesafe.config.ConfigRenderOptions
import io.vertx.core.AbstractVerticle
import io.vertx.core.Vertx
import io.vertx.core.http.HttpMethod
import io.vertx.ext.web.Router
import io.vertx.ext.web.RoutingContext
import io.vertx.ext.web.handler.BodyHandler
import io.vertx.ext.web.handler.LoggerHandler
import mu.KotlinLogging
import kotlin.concurrent.thread


private val logger = KotlinLogging.logger { }

fun <T> T?.orElse(provider: () -> T): T = if (this === null) provider() else this

fun main(args: Array<String>) {
    Vertx.vertx().also { vertx ->
        vertx.deployVerticle(ServerVerticle(args))
        Runtime.getRuntime().addShutdownHook(thread(start = false) { vertx.close() })
    }
}

class ServerVerticle(
    args: Array<String>
) : AbstractVerticle() {

    private val config = loadConfig(args)

    override fun start() {
        super.start()

        // Services

        val databaseService = DatabaseService(config)
        val bookRepository = BookRepository(databaseService)
        val bookAction = BookAction()
        val bookController = BookController(bookRepository, bookAction)

        // Web server initialisation

        val mainNegotiator = JsonVertxNegotiator()

        val port = config.getInt("finances.server.port")
        Router.router(vertx).initialize {

            defaultNegotiator = mainNegotiator

            route().handler(BodyHandler.create())
            route().handler(LoggerHandler.create())
            route("/hello").method(HttpMethod.GET).handler { it.response().end("Hello, World!") }

            route("/books/{bookId}").method(HttpMethod.PATCH).negotiate(mainNegotiator) { _: RoutingContext ->
                Ok("asd")
            }

            "/" {
                "books" {
                    GET negotiate bookController::getAllBooks
                    POST negotiate bookController::createNewBook
                    "{bookId}" {
                        GET negotiate bookController::getBookById
                    }
                }
            }

            vertx
                .createHttpServer()
                .requestHandler(this::accept)
                .listen(port)
        }

        logger.info {
            """


,------.,--.                                                ,-----.                ,--.          ,------.           ,--.
|  .---'`--',--,--,  ,--,--.,--,--,  ,---. ,---.  ,---.     |  |) /_  ,--,--. ,---.|  |,-.,-----.|  .---',--,--,  ,-|  |
|  `--, ,--.|      \' ,-.  ||      \| .--'| .-. :(  .-'     |  .-.  \' ,-.  || .--'|     /'-----'|  `--, |      \' .-. |
|  |`   |  ||  ||  |\ '-'  ||  ||  |\ `--.\   --..-'  `)    |  '--' /\ '-'  |\ `--.|  \  \       |  `---.|  ||  |\ `-' |
`--'    `--'`--''--' `--`--'`--''--' `---' `----'`----'     `------'  `--`--' `---'`--'`--'      `------'`--''--' `---'

    Listening on port $port


"""

        }
    }

    override fun stop() {
        logger.info { "Stopping server" }
    }

    private fun loadConfig(args: Array<String>): Config = args
        .firstOrNull { it.startsWith("-config=", ignoreCase = true) }
        ?.let { configFlag ->
            configFlag.split('=').takeIf { it.size == 2 }?.let { it[1] }
        }
        .orElse {
            val default = "application.conf"
            logger.debug { """No config argument. Using "$default"""" }
            default
        }
        .let { configFile ->
            logger.info { "Loading configuration from $configFile" }
            val config = ConfigFactory.load(configFile)
            logger.debug { config.root().render(ConfigRenderOptions.defaults()) }
            config
        }

}
