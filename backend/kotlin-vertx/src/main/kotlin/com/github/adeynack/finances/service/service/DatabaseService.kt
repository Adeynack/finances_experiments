package com.github.adeynack.finances.service.service

import com.typesafe.config.Config
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import mu.KLogging
import org.flywaydb.core.Flyway
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL

class DatabaseService(
    private val config: Config
) {

    val dslContext: DSLContext

    init {
        val dbDriver = config.getString("finances.database.dataSource.driver")
        val dbUrl = config.getString("finances.database.dataSource.connectionString")
        val dbUsername = config.getString("finances.database.dataSource.username")
        val dbPassword = config.getString("finances.database.dataSource.password")
        val dbSchema = config.getString("finances.database.dataSource.schema")
        val jooqDialect = config.getString("finances.database.jooq.dialect")
        logger.info { "Connecting to database at URL $dbUrl under user $dbUsername using schema $dbSchema using driver $dbDriver" }
        val hikariConfig = HikariConfig().apply {
            driverClassName = dbDriver
            jdbcUrl = dbUrl
            username = dbUsername
            password = dbPassword
            schema = dbSchema
        }
        val dbDataSource = HikariDataSource(hikariConfig)

        dslContext = DSL.using(dbDataSource, SQLDialect.valueOf(jooqDialect))!!

        migrate(dbDataSource, dbSchema)
    }

    private fun migrate(dbDataSource: HikariDataSource, dbSchema: String) {
        if (!config.getBoolean("finances.database.flyway.enabled")) {
            return
        }
        val evolutions = listOf(config.getString("finances.database.flyway.locations.schema"))
        val extra = config.getStringList("finances.database.flyway.locations.extra")
        val migrationLocations = evolutions + extra
        Flyway().apply {
            dataSource = dbDataSource
            setSchemas(dbSchema)
            setLocations(*migrationLocations.toTypedArray())
            migrate()
        }
    }

    companion object : KLogging()

}
