/*
 * Copyright (C) 2018 Julien Viet
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
module hunt.database.postgresql.impl.codec.PgEncoder;

import hunt.database.postgresql.impl.codec.Bind;
import hunt.database.postgresql.impl.codec.CloseConnectionCommandCodec;
import hunt.database.postgresql.impl.codec.ClosePortalCommandCodec;
import hunt.database.postgresql.impl.codec.CloseStatementCommandCodec;
import hunt.database.postgresql.impl.codec.DataTypeCodec;
import hunt.database.postgresql.impl.codec.DataFormat;
import hunt.database.postgresql.impl.codec.DataType;
import hunt.database.postgresql.impl.codec.DataTypeDesc;
import hunt.database.postgresql.impl.codec.Describe;
import hunt.database.postgresql.impl.codec.ExtendedBatchQueryCommandCodec;
import hunt.database.postgresql.impl.codec.ExtendedQueryCommandCodec;
import hunt.database.postgresql.impl.codec.InitCommandCodec;
import hunt.database.postgresql.impl.codec.PgColumnDesc;
import hunt.database.postgresql.impl.codec.CommandCodec;
import hunt.database.postgresql.impl.codec.PgDecoder;
import hunt.database.postgresql.impl.codec.PrepareStatementCommandCodec;
import hunt.database.postgresql.impl.codec.Query;
import hunt.database.postgresql.impl.codec.QueryCommandBaseCodec;
import hunt.database.postgresql.impl.codec.Parse;
import hunt.database.postgresql.impl.codec.PasswordMessage;
import hunt.database.postgresql.impl.codec.Response;
import hunt.database.postgresql.impl.codec.SimpleQueryCommandCodec;
import hunt.database.postgresql.impl.codec.StartupMessage;
import hunt.database.base.Util;

import hunt.database.base.AsyncResult;
import hunt.database.base.Exceptions;
import hunt.database.base.impl.Connection;
import hunt.database.base.impl.ParamDesc;
import hunt.database.base.impl.RowDesc;
import hunt.database.base.impl.TxStatus;
import hunt.database.base.impl.command;
import hunt.database.base.RowSet;


import hunt.collection.ArrayDeque;
import hunt.collection.ByteBuffer;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer;
import hunt.net.codec.Encoder;
import hunt.net.Connection;
import hunt.text.Charset;

alias writeCString = Util.writeCString;

import std.container.dlist;
import std.range;
import std.variant;

/**
 * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
final class PgEncoder : EncoderChain {

    // Frontend message types for {@link pgclient.impl.codec.encoder.MessageEncoder}

    private enum byte PASSWORD_MESSAGE = 'p';
    private enum byte QUERY = 'Q';
    private enum byte TERMINATE = 'X';
    private enum byte PARSE = 'P';
    private enum byte BIND = 'B';
    private enum byte DESCRIBE = 'D';
    private enum byte EXECUTE = 'E';
    private enum byte CLOSE = 'C';
    private enum byte SYNC = 'S';

    // private ArrayDeque<CommandCodec<?, ?>> inflight;
    private DList!(CommandCodecBase) *inflight;
    private Connection ctx;
    private ByteBuf outBuffer;
    private PgDecoder dec;

    this(PgDecoder dec, ref DList!(CommandCodecBase) inflight) {
        this.inflight = &inflight;
        this.dec = dec;
    }

    override void encode(Object message, Connection connection) {
        ctx = connection;

        ICommand cmd = cast(ICommand)message;
        if(cmd is null) {
            warningf("The message is not a ICommand: %s", typeid(message));
        }

        version(HUNT_DB_DEBUG) 
        tracef("encoding a message: %s", typeid(message));

        CommandCodecBase cmdCodec = wrap(cmd);

        cmdCodec.completionHandler = (ICommandResponse resp) {
            version(HUNT_DB_DEBUG) {
                infof("message encoding completed");
                // CommandCodecBase c = inflight.front();
                // assert(cmdCodec is c);
                if(resp.failed()) {
                    Throwable th = resp.cause();
                    warningf("Response error: %s", th.msg);
                }
            }
            version(HUNT_DB_DEBUG_MORE)  tracef("%s", typeid(cast(Object)resp));
            inflight.removeFront();

            if(!resp.isCommandAttatched()) {
                // infof("No command attatched for %s", typeid(cast(Object)cmdCodec));
                resp.attachCommand(cmdCodec.getCommand());
            }

            ConnectionEventHandler handler = ctx.getHandler();
            handler.messageReceived(ctx, cast(Object)resp);
        };

        inflight.insertBack(cmdCodec);
        cmdCodec.encode(this);
        flush();
	}

    private CommandCodecBase wrap(ICommand cmd) {
        InitCommand initCommand = cast(InitCommand) cmd;
        if (initCommand !is null) {
            return new InitCommandCodec(initCommand);
        }

        SimpleQueryCommand!(RowSet) simpleCommand = cast(SimpleQueryCommand!(RowSet))cmd;
        if(simpleCommand !is null) {
            return new SimpleQueryCommandCodec!RowSet(simpleCommand);
        }

        PrepareStatementCommand prepareCommand = cast(PrepareStatementCommand)cmd;
        if(prepareCommand !is null) {
            return new PrepareStatementCommandCodec(prepareCommand);
        }

        ExtendedQueryCommand!RowSet extendedCommand = cast(ExtendedQueryCommand!RowSet)cmd;
        if(extendedCommand !is null) {
            return new ExtendedQueryCommandCodec!RowSet(extendedCommand);
        }

        ExtendedBatchQueryCommand!RowSet batchQueryCommand = cast(ExtendedBatchQueryCommand!RowSet)cmd;
        if(batchQueryCommand !is null) {
            return new ExtendedBatchQueryCommandCodec!RowSet(batchQueryCommand);
        }

        CloseConnectionCommand connCommand = cast(CloseConnectionCommand)cmd;
        if(connCommand !is null) {
            return CloseConnectionCommandCodec.INSTANCE();
        }

        CloseCursorCommand cursorCommand = cast(CloseCursorCommand)cmd;
        if(cursorCommand !is null) {
            return new ClosePortalCommandCodec(cursorCommand);
        }

        CloseStatementCommand statementCommand = cast(CloseStatementCommand)cmd;
        if(statementCommand !is null) {
            return new CloseStatementCommandCodec(statementCommand);
        }

        throw new AssertionError();
    }

    // override
    // void handlerAdded(Connection ctx) {
    //     // TODO: Tasks pending completion -@zxp at 8/22/2019, 5:50:54 PM
    //     // 
    //     this.ctx = ctx;
    // }

    void flush() {
        version(HUNT_DB_DEBUG) trace("flushing ...");

        if(ctx is null) {
            warning("ctx is null");
            return ;
        }

        if (outBuffer !is null) {
            ByteBuf buff = outBuffer;
            outBuffer = null;
            byte[] avaliableData = buff.getReadableBytes();
            version(HUNT_DB_DEBUG_MORE) {
                tracef("buffer: %s", buff.toString());
                tracef("buffer data: %s", cast(string)avaliableData);
            }
            ctx.write(cast(const(ubyte)[])avaliableData);
        }
    }

    /**
     * This message immediately closes the connection. On receipt of this message,
     * the backend closes the connection and terminates.
     */
    void writeTerminate() {
        ensureBuffer();
        outBuffer.writeByte(TERMINATE);
        outBuffer.writeInt(4);
    }

    /**
     * <p>
     * The purpose of this message is to provide a resynchronization point for error recovery.
     * When an error is detected while processing any extended-query message, the backend issues {@link ErrorResponse},
     * then reads and discards messages until this message is reached, then issues {@link ReadyForQuery} and returns to normal
     * message processing.
     * <p>
     * Note that no skipping occurs if an error is detected while processing this message which ensures that there is one
     * and only one {@link ReadyForQuery} sent for each of this message.
     * <p>
     * Note this message does not cause a transaction block opened with BEGIN to be closed. It is possible to detect this
     * situation in {@link ReadyForQuery#txStatus()} that includes {@link TxStatus} information.
     */
    void writeSync() {
        ensureBuffer();
        outBuffer.writeByte(SYNC);
        outBuffer.writeInt(4);
    }

    /**
     * <p>
     * The message closes an existing prepared statement or portal and releases resources.
     * Note that closing a prepared statement implicitly closes any open portals that were constructed from that statement.
     * <p>
     * The response is either {@link CloseComplete} or {@link ErrorResponse}
     *
     * @param portal
     */
    void writeClosePortal(string portal) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(CLOSE);
        outBuffer.writeInt(0);
        outBuffer.writeByte('P'); // 'S' to close a prepared statement or 'P' to close a portal
        Util.writeCStringUTF8(outBuffer, portal);
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos - 1);
    }

    void writeStartupMessage(StartupMessage msg) {
        ensureBuffer();

        int pos = outBuffer.writerIndex();

        outBuffer.writeInt(0);
        // protocol version
        outBuffer.writeShort(3);
        outBuffer.writeShort(0);

        writeCString(outBuffer, StartupMessage.BUFF_USER);
        Util.writeCStringUTF8(outBuffer, msg.username);
        writeCString(outBuffer, StartupMessage.BUFF_DATABASE);
        Util.writeCStringUTF8(outBuffer, msg.database);
        foreach (MapEntry!(string, string) property ; msg.properties) {
            writeCString(outBuffer, property.getKey(), StandardCharsets.UTF_8);
            writeCString(outBuffer, property.getValue(), StandardCharsets.UTF_8);
        }

        outBuffer.writeByte(0);
        outBuffer.setInt(pos, outBuffer.writerIndex() - pos);
    }

    void writePasswordMessage(PasswordMessage msg) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(PASSWORD_MESSAGE);
        outBuffer.writeInt(0);
        Util.writeCStringUTF8(outBuffer, msg.hash);
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos- 1);
    }

    /**
     * <p>
     * This message includes an SQL command (or commands) expressed as a text string.
     * <p>
     * The possible response messages from the backend are
     * {@link CommandComplete}, {@link RowDesc}, {@link DataRow}, {@link EmptyQueryResponse}, {@link ErrorResponse},
     * {@link ReadyForQuery} and {@link NoticeResponse}
     */
    void writeQuery(Query query) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(QUERY);
        outBuffer.writeInt(0);
        Util.writeCStringUTF8(outBuffer, query.sql);
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos - 1);
    }

    /**
     * <p>
     * The message that using "statement" variant specifies the name of an existing prepared statement.
     * <p>
     * The response is a {@link ParamDesc} message describing the parameters needed by the statement,
     * followed by a {@link RowDesc} message describing the rows that will be returned when the statement is eventually
     * executed or a {@link NoData} message if the statement will not return rows.
     * {@link ErrorResponse} is issued if there is no such prepared statement.
     * <p>
     * Note that since {@link Bind} has not yet been issued, the formats to be used for returned columns are not yet known to
     * the backend; the format code fields in the {@link RowDesc} message will be zeroes in this case.
     * <p>
     * The message that using "portal" variant specifies the name of an existing portal.
     * <p>
     * The response is a {@link RowDesc} message describing the rows that will be returned by executing the portal;
     * or a {@link NoData} message if the portal does not contain a query that will return rows; or {@link ErrorResponse}
     * if there is no such portal.
     */
    void writeDescribe(Describe describe) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(DESCRIBE);
        outBuffer.writeInt(0);
        if (describe.statement != 0) {
            outBuffer.writeByte('S');
            outBuffer.writeLong(describe.statement);
        } else if (describe.portal !is null) {
            outBuffer.writeByte('P');
            Util.writeCStringUTF8(outBuffer, describe.portal);
        } else {
            outBuffer.writeByte('S');
            Util.writeCStringUTF8(outBuffer, "");
        }
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos- 1);
    }

    /**
     * <p>
     * The message contains a textual SQL query string.
     * <p>
     * The response is either {@link ParseComplete} or {@link ErrorResponse}
     */
    void writeParse(Parse parse) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(PARSE);
        outBuffer.writeInt(0);
        if (parse.statement == 0) {
            outBuffer.writeByte(0);
        } else {
            outBuffer.writeLong(parse.statement);
        }
        Util.writeCStringUTF8(outBuffer, parse.query);
        // no parameter data types (OIDs)
        // if(paramDataTypes is null) {
        outBuffer.writeShort(0);
        // } else {
        //   // Parameter data types (OIDs)
        //   outBuffer.writeShort(paramDataTypes.length);
        //   for (int paramDataType : paramDataTypes) {
        //     outBuffer.writeInt(paramDataType);
        //   }
        // }
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos - 1);
    }

    /**
     * The message specifies the portal and a maximum row count (zero meaning "fetch all rows") of the result.
     * <p>
     * The row count of the result is only meaningful for portals containing commands that return row sets;
     * in other cases the command is always executed to completion, and the row count of the result is ignored.
     * <p>
     * The possible responses to this message are the same as {@link Query} message, except that
     * it doesn't cause {@link ReadyForQuery} or {@link RowDesc} to be issued.
     * <p>
     * If Execute terminates before completing the execution of a portal, it will send a {@link PortalSuspended} message;
     * the appearance of this message tells the frontend that another Execute should be issued against the same portal to
     * complete the operation. The {@link CommandComplete} message indicating completion of the source SQL command
     * is not sent until the portal's execution is completed. Therefore, This message is always terminated by
     * the appearance of exactly one of these messages: {@link CommandComplete},
     * {@link EmptyQueryResponse}, {@link ErrorResponse} or {@link PortalSuspended}.
     *
     * @author <a href="mailto:emad.albloushi@gmail.com">Emad Alblueshi</a>
     */
    void writeExecute(string portal, int rowCount) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(EXECUTE);
        outBuffer.writeInt(0);
        if (portal !is null) {
            outBuffer.writeCharSequence(portal, StandardCharsets.UTF_8);
        }
        outBuffer.writeByte(0);
        outBuffer.writeInt(rowCount); // Zero denotes "no limit" maybe for ReadStream!(Row)
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos - 1);
    }

    /**
     * <p>
     * The message gives the name of the prepared statement, the name of portal,
     * and the values to use for any parameter values present in the prepared statement.
     * The supplied parameter set must match those needed by the prepared statement.
     * <p>
     * The response is either {@link BindComplete} or {@link ErrorResponse}.
     */
    void writeBind(Bind bind, string portal, List!(Variant) paramValues) {
        ensureBuffer();
        int pos = outBuffer.writerIndex();
        outBuffer.writeByte(BIND);
        outBuffer.writeInt(0);
        if (portal !is null) {
            outBuffer.writeCharSequence(portal, StandardCharsets.UTF_8);
        }
        outBuffer.writeByte(0);
        if (bind.statement == 0) {
            outBuffer.writeByte(0);
        } else {
            outBuffer.writeLong(bind.statement);
        }
        int paramLen = paramValues.size();
        outBuffer.writeShort(paramLen);
        // Parameter formats
        for (int c = 0;c < paramLen;c++) {
            // for now each format is Binary
            outBuffer.writeShort(bind.paramTypes[c].supportsBinary ? 1 : 0);
        }
        outBuffer.writeShort(paramLen);
        for (int c = 0;c < paramLen;c++) {
            Variant param = paramValues.get(c);
            if (!param.hasValue() || param == null) {
                // NULL value
                outBuffer.writeInt(-1);
            } else {
                DataTypeDesc dataType = bind.paramTypes[c];
                version(HUNT_DB_DEBUG_MORE) {
                    tracef("dataType: %s, param: type=%s, value=%s", 
                        dataType, param.type, param.toString());
                }

                if (dataType.supportsBinary) {
                    int idx = outBuffer.writerIndex();
                    outBuffer.writeInt(0); 
                    try {
                        DataTypeCodec.encodeBinary(cast(DataType)dataType.id, param, outBuffer);
                    } catch(Throwable ex) {
                        version(HUNT_DB_DEBUG_MORE) warning(ex);
                        else warning(ex.msg);
                        throw new DatabaseException(ex.msg);
                    }
                    outBuffer.setInt(idx, outBuffer.writerIndex() - idx - 4);
                } else {
                    DataTypeCodec.encodeText(cast(DataType)dataType.id, param, outBuffer);
                }
            }
        }

        // MAKE resultColumsn non null to avoid null check

        // Result columns are all in Binary format
        if (bind.resultColumns.length > 0) {
            outBuffer.writeShort(cast(int)bind.resultColumns.length);
            foreach (PgColumnDesc resultColumn; bind.resultColumns) {
                outBuffer.writeShort(resultColumn.dataType.supportsBinary ? 1 : 0);
            }
        } else {
            outBuffer.writeShort(1);
            outBuffer.writeShort(1);
        }
        outBuffer.setInt(pos + 1, outBuffer.writerIndex() - pos - 1);
    }

    private void ensureBuffer() {
        if (outBuffer is null) {
            outBuffer = Unpooled.buffer();
        }
    }
}
