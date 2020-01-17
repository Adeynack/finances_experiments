package com.github.adeynack.finances.service.controller

import com.github.adeynack.finances.service.action.BookAction
import com.github.adeynack.finances.service.model.Book
import com.github.adeynack.finances.service.model.BookList
import com.github.adeynack.finances.service.repository.BookRepository
import com.github.adeynack.finances.service.util.vertx.web.Created
import com.github.adeynack.finances.service.util.vertx.web.Negotiation
import com.github.adeynack.finances.service.util.vertx.web.Ok
import com.github.adeynack.finances.service.util.vertx.web.Problem
import io.netty.handler.codec.http.HttpResponseStatus
import io.vertx.ext.web.RoutingContext

class BookController(
    private val bookRepository: BookRepository,
    private val bookAction: BookAction
) {

    fun getAllBooks(): Negotiation<BookList> {
        val allBooks = bookRepository.findAll()
        return Ok(BookList(data = allBooks))
    }

    fun createNewBook(newBook: Book): Negotiation<Book> {
        return Created(newBook) // todo
    }

    fun getBookById(c: RoutingContext): Negotiation<Book> {
        val bookId = c.request().getParam("bookId").toLongOrNull()
        if (bookId === null) {
            return Problem(status = HttpResponseStatus.BAD_REQUEST)
        }
        val book = bookRepository.findById(bookId)
        if (book === null) {
            return Problem(status = HttpResponseStatus.NOT_FOUND)
        }
        return Ok(book)
    }
}
