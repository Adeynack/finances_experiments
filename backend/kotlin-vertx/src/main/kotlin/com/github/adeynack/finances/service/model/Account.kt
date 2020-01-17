package com.github.adeynack.finances.service.model

data class Account(
    val id: Int,
    val parentBookId: Int,
    val name: String
)

data class AccountList(
    val data: List<Account>
)
