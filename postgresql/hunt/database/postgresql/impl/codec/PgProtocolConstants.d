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
module hunt.database.postgresql.impl.codec;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 */
class PgProtocolConstants {

  static final int AUTHENTICATION_TYPE_OK = 0;
  static final int AUTHENTICATION_TYPE_KERBEROS_V5 = 2;
  static final int AUTHENTICATION_TYPE_CLEARTEXT_PASSWORD = 3;
  static final int AUTHENTICATION_TYPE_MD5_PASSWORD = 5;
  static final int AUTHENTICATION_TYPE_SCM_CREDENTIAL = 6;
  static final int AUTHENTICATION_TYPE_GSS = 7;
  static final int AUTHENTICATION_TYPE_GSS_CONTINUE = 8;
  static final int AUTHENTICATION_TYPE_SSPI = 9;

  static final byte ERROR_OR_NOTICE_SEVERITY = 'S';
  static final byte ERROR_OR_NOTICE_CODE = 'C';
  static final byte ERROR_OR_NOTICE_MESSAGE = 'M';
  static final byte ERROR_OR_NOTICE_DETAIL = 'D';
  static final byte ERROR_OR_NOTICE_HINT = 'H';
  static final byte ERROR_OR_NOTICE_POSITION = 'P';
  static final byte ERROR_OR_NOTICE_INTERNAL_POSITION = 'p';
  static final byte ERROR_OR_NOTICE_INTERNAL_QUERY = 'q';
  static final byte ERROR_OR_NOTICE_WHERE = 'W';
  static final byte ERROR_OR_NOTICE_FILE = 'F';
  static final byte ERROR_OR_NOTICE_LINE = 'L';
  static final byte ERROR_OR_NOTICE_ROUTINE = 'R';
  static final byte ERROR_OR_NOTICE_SCHEMA = 's';
  static final byte ERROR_OR_NOTICE_TABLE = 't';
  static final byte ERROR_OR_NOTICE_COLUMN = 'c';
  static final byte ERROR_OR_NOTICE_DATA_TYPE = 'd';
  static final byte ERROR_OR_NOTICE_CONSTRAINT = 'n';

  static final byte MESSAGE_TYPE_BACKEND_KEY_DATA = 'K';
  static final byte MESSAGE_TYPE_AUTHENTICATION = 'R';
  static final byte MESSAGE_TYPE_ERROR_RESPONSE = 'E';
  static final byte MESSAGE_TYPE_NOTICE_RESPONSE = 'N';
  static final byte MESSAGE_TYPE_NOTIFICATION_RESPONSE = 'A';
  static final byte MESSAGE_TYPE_COMMAND_COMPLETE = 'C';
  static final byte MESSAGE_TYPE_PARAMETER_STATUS = 'S';
  static final byte MESSAGE_TYPE_READY_FOR_QUERY = 'Z';
  static final byte MESSAGE_TYPE_PARAMETER_DESCRIPTION = 't';
  static final byte MESSAGE_TYPE_ROW_DESCRIPTION = 'T';
  static final byte MESSAGE_TYPE_DATA_ROW = 'D';
  static final byte MESSAGE_TYPE_PORTAL_SUSPENDED = 's';
  static final byte MESSAGE_TYPE_NO_DATA = 'n';
  static final byte MESSAGE_TYPE_EMPTY_QUERY_RESPONSE = 'I';
  static final byte MESSAGE_TYPE_PARSE_COMPLETE = '1';
  static final byte MESSAGE_TYPE_BIND_COMPLETE = '2';
  static final byte MESSAGE_TYPE_CLOSE_COMPLETE = '3';
  static final byte MESSAGE_TYPE_FUNCTION_RESULT = 'V';
  static final byte MESSAGE_TYPE_SSL_YES = 'S';
  static final byte MESSAGE_TYPE_SSL_NO = 'N';
}
