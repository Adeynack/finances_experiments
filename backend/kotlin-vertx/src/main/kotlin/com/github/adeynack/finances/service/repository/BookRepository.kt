package com.github.adeynack.finances.service.repository

import com.github.adeynack.finances.service.jooq.generated.Tables.BOOKS
import com.github.adeynack.finances.service.jooq.generated.tables.records.BooksRecord
import com.github.adeynack.finances.service.model.Book
import com.github.adeynack.finances.service.service.DatabaseService

class BookRepository(
    private val databaseService: DatabaseService
) {

    fun findAll(): List<Book> = databaseService.dslContext
        .selectFrom(BOOKS)
        .fetch(::toBook)

    fun findById(id: Long): Book? = databaseService.dslContext
        .selectFrom(BOOKS)
        .where(BOOKS.ID.eq(id))
        .fetchOne(::toBook)

    private fun toBook(it: BooksRecord): Book = Book(it[BOOKS.ID], it[BOOKS.NAME], it[BOOKS.OWNER_ID])

}
