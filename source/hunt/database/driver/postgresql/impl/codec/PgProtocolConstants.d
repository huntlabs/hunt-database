/*
 * Copyright (C) 2019, HuntLabs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
module hunt.database.driver.postgresql.impl.codec.PgProtocolConstants;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class PgProtocolConstants {

    enum int AUTHENTICATION_TYPE_OK = 0;
    enum int AUTHENTICATION_TYPE_KERBEROS_V5 = 2;
    enum int AUTHENTICATION_TYPE_CLEARTEXT_PASSWORD = 3;
    enum int AUTHENTICATION_TYPE_MD5_PASSWORD = 5;
    enum int AUTHENTICATION_TYPE_SCM_CREDENTIAL = 6;
    enum int AUTHENTICATION_TYPE_GSS = 7;
    enum int AUTHENTICATION_TYPE_GSS_CONTINUE = 8;
    enum int AUTHENTICATION_TYPE_SSPI = 9;

    enum byte ERROR_OR_NOTICE_SEVERITY = 'S';
    enum byte ERROR_OR_NOTICE_CODE = 'C';
    enum byte ERROR_OR_NOTICE_MESSAGE = 'M';
    enum byte ERROR_OR_NOTICE_DETAIL = 'D';
    enum byte ERROR_OR_NOTICE_HINT = 'H';
    enum byte ERROR_OR_NOTICE_POSITION = 'P';
    enum byte ERROR_OR_NOTICE_INTERNAL_POSITION = 'p';
    enum byte ERROR_OR_NOTICE_INTERNAL_QUERY = 'q';
    enum byte ERROR_OR_NOTICE_WHERE = 'W';
    enum byte ERROR_OR_NOTICE_FILE = 'F';
    enum byte ERROR_OR_NOTICE_LINE = 'L';
    enum byte ERROR_OR_NOTICE_ROUTINE = 'R';
    enum byte ERROR_OR_NOTICE_SCHEMA = 's';
    enum byte ERROR_OR_NOTICE_TABLE = 't';
    enum byte ERROR_OR_NOTICE_COLUMN = 'c';
    enum byte ERROR_OR_NOTICE_DATA_TYPE = 'd';
    enum byte ERROR_OR_NOTICE_CONSTRAINT = 'n';

    enum byte MESSAGE_TYPE_BACKEND_KEY_DATA = 'K';
    enum byte MESSAGE_TYPE_AUTHENTICATION = 'R';
    enum byte MESSAGE_TYPE_ERROR_RESPONSE = 'E';
    enum byte MESSAGE_TYPE_NOTICE_RESPONSE = 'N';
    enum byte MESSAGE_TYPE_NOTIFICATION_RESPONSE = 'A';
    enum byte MESSAGE_TYPE_COMMAND_COMPLETE = 'C';
    enum byte MESSAGE_TYPE_PARAMETER_STATUS = 'S';
    enum byte MESSAGE_TYPE_READY_FOR_QUERY = 'Z';
    enum byte MESSAGE_TYPE_PARAMETER_DESCRIPTION = 't';
    enum byte MESSAGE_TYPE_ROW_DESCRIPTION = 'T';
    enum byte MESSAGE_TYPE_DATA_ROW = 'D';
    enum byte MESSAGE_TYPE_PORTAL_SUSPENDED = 's';
    enum byte MESSAGE_TYPE_NO_DATA = 'n';
    enum byte MESSAGE_TYPE_EMPTY_QUERY_RESPONSE = 'I';
    enum byte MESSAGE_TYPE_PARSE_COMPLETE = '1';
    enum byte MESSAGE_TYPE_BIND_COMPLETE = '2';
    enum byte MESSAGE_TYPE_CLOSE_COMPLETE = '3';
    enum byte MESSAGE_TYPE_FUNCTION_RESULT = 'V';
    enum byte MESSAGE_TYPE_SSL_YES = 'S';
    enum byte MESSAGE_TYPE_SSL_NO = 'N';
}
