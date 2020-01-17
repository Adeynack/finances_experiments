package com.github.adeynack.finances.service.model

data class Book(
    val id: Long,
    val name: String,
    val ownerId: Long
)

data class BookList(
    val data: List<Book>
)
