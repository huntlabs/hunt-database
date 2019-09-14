module hunt.database.driver.mysql.MySQLClient;

/**
 * An interface to define MySQL specific constants or behaviors.
 */
interface MySQLClient {
    /**
     * SqlResult Property for last_insert_id
     */

    enum string LAST_INSERTED_ID = "last_insert_id";
    
}