package com.github.adeynack.finances.service.util.vertx.web

import io.vertx.core.buffer.Buffer
import io.vertx.core.http.HttpHeaders
import io.vertx.core.http.HttpServerResponse
import io.vertx.core.json.Json

fun HttpServerResponse.writeWithLength(buffer: Buffer): HttpServerResponse {
    putHeader(HttpHeaders.CONTENT_LENGTH, buffer.length().toString())
    write(buffer)
    return this
}

fun HttpServerResponse.endWithProblem(problem: Problem) {
    endWithProblem(
        ProblemJson(
            status = problem.status.code(),
            type = problem.type,
            title = problem.title,
            detail = problem.detail,
            instance = problem.instance
        )
    )
}

fun HttpServerResponse.endWithProblem(problem: ProblemJson) {
    putHeader(HttpHeaders.CONTENT_TYPE, "application/problem+json")
        .setStatusCode(problem.status)
        .writeWithLength(Json.encodeToBuffer(problem))
        .end()
}
