//package com.github.adeynack.finances.service.interceptor
//
//import com.github.adeynack.finances.service.model.Book
//import com.github.adeynack.finances.service.service.BookService
//import io.ktor.application.ApplicationCall
//import io.ktor.http.HttpStatusCode
//import io.ktor.pipeline.PipelineContext
//import io.ktor.pipeline.PipelineInterceptor
//import io.ktor.response.respond
//import io.ktor.util.AttributeKey
//
//class BookInterceptor(
//    private val bookService: BookService
//) {
//
//    val bookAttributeKey = AttributeKey<Book>("book")
//
//    val intercept: PipelineInterceptor<Unit, ApplicationCall> = {
//        val book = context.parameters["bookId"]
//            ?.toIntOrNull()
//            ?.let { bookId -> bookService.books.firstOrNull { it.id == bookId } }
//        if (book == null) {
//            context.respond(HttpStatusCode.Forbidden, "You do not have access to this book.")
//            finish()
//        } else {
//            context.attributes.put(bookAttributeKey, book)
//        }
//    }
//
//}
